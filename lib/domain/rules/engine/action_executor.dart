import '../core/rule_definition.dart';
import '../evidence/evidence_id.dart';
import '../evidence/rule_hit.dart';
import '../evidence/evidence_node.dart';
import '../evidence/evidence_edge.dart';
import '../facts/fact_record.dart';
import '../facts/semantic_ref.dart';
import 'binding_resolver.dart';
import 'evidence_emitter.dart';
import 'engine_types.dart';
import 'action_output_factory.dart';
import 'rule_trace.dart';
import '../ast/rule_action.dart';
import '../evidence/derived_evidence.dart';
import '../editor/rule_tag_catalog.dart';

/// 执行规则动作并生成新的推导事实和 Evidence
class ActionExecutor {
  const ActionExecutor();

  /// 执行 actions，返回新产生的事实和对应的 RuleHit。
  ActionExecutionResult execute(
    RuleDefinition rule,
    BindingContext context,
    List<EvidenceId> supports,
    {
    String caseId = 'preview',
    String ruleRunId = 'in-memory',
    String traceRef = 'action',
    RuleTrace? conditionTrace,
    }
  ) {
    final derivedFacts = <FactRecord>[];
    final derivedStates = <FactRecord>[];
    final tags = <FactRecord>[];
    final structures = <FactRecord>[];
    final records = <FactRecord>[];
    final ruleHits = <RuleHit>[];
    final evidenceNodes = <EvidenceNode>[];
    final evidenceEdges = <EvidenceEdge>[];
    final actionTraces = <RuleTrace>[];
    final derivedEvidence = <DerivedEvidence>[];

    for (var actionIndex = 0; actionIndex < rule.actions.length; actionIndex++) {
      final action = rule.actions[actionIndex];
      final res = ActionOutputFactory.build(action, rule, context);
      final newFact = res.output;

      if (newFact == null) {
        actionTraces.add(RuleTrace(
          kind: RuleTraceKind.action,
          label: action.runtimeType.toString(),
          status: RuleTraceStatus.error,
          reason: 'Action 无法解析 subject 或输出',
        ));
        continue;
      }
      actionTraces.add(RuleTrace(
        kind: RuleTraceKind.action,
        label: _actionLabel(action, res.conclusion),
        status: RuleTraceStatus.success,
        resolvedObjects: [newFact.subject],
      ));
      final target = _targetFor(action);
      for (final targetRefs in _targetRefs(target, context, conditionTrace)) {
        final evidenceId = _evidenceId(
          rule: rule,
          value: action is TagAction ? action.tagId : res.conclusion,
          target: target,
          targetRefs: targetRefs,
          supports: supports,
        );
        derivedEvidence.add(DerivedEvidence(
          id: evidenceId,
          caseId: caseId,
          ruleId: rule.ruleId,
          ruleVersion: rule.version,
          ruleOrigin: rule.origin,
          actionType: action.runtimeType.toString(),
          category: action is TagAction ? action.categoryId : rule.categoryId,
          value: action is TagAction ? action.tagId : res.conclusion,
          targetKind: target.kind,
          targetRefs: targetRefs,
          relationId: target.relationId,
          supports: supports,
          ruleRunId: ruleRunId,
          traceRef: '$traceRef:$actionIndex',
        ));
      }

      {
        if (res.kind == 'fact') {
          derivedFacts.add(newFact);
        } else if (res.kind == 'tag') {
          tags.add(newFact);
        } else if (res.kind == 'structure') {
          structures.add(newFact);
        } else if (res.kind == 'record') {
          records.add(newFact);
        }

        final hit = const EvidenceEmitter().emitHit(
          rule: rule,
          context: context,
          conclusion: res.conclusion,
          supports: supports,
        );
        ruleHits.add(hit);

        evidenceNodes.add(
          EvidenceNode(id: hit.hitId, label: res.conclusion, type: 'rule'),
        );
        final outId = EvidenceId(newFact.factId);
        evidenceNodes.add(
          EvidenceNode(id: outId, label: res.conclusion, type: res.kind),
        );
        evidenceEdges.add(
          EvidenceEdge(
            sourceId: hit.hitId,
            targetId: outId,
            relationType: 'derives_to',
          ),
        );
        for (final s in supports) {
          evidenceEdges.add(
            EvidenceEdge(
              sourceId: s,
              targetId: hit.hitId,
              relationType: 'supports',
            ),
          );
        }
      }
    }

    return ActionExecutionResult(
      derivedFacts,
      derivedStates,
      tags,
      structures,
      records,
      ruleHits,
      evidenceNodes,
      evidenceEdges,
      actionTraces,
      derivedEvidence,
    );
  }

  ActionTarget _targetFor(RuleAction action) {
    if (action is TagAction && action.target != null) return action.target!;
    if (action is TagAction && action.subjectBinding != null) {
      return ActionTarget.object(subjectBinding: action.subjectBinding!);
    }
    return const ActionTarget.caseTarget();
  }

  String _actionLabel(RuleAction action, String fallback) {
    if (action case TagAction(:final categoryId, :final tagId)) {
      if (categoryId == 'image') {
        return '取象「${RuleTagCatalog.display(tagId)}」';
      }
    }
    return fallback;
  }

  List<List<SemanticRef>> _targetRefs(
    ActionTarget target,
    BindingContext context,
    RuleTrace? conditionTrace,
  ) {
    if (target.kind == ActionTargetKind.relation &&
        target.sourceBinding == null &&
        target.targetBinding == null) {
      return [
        for (final trace in _flatten(conditionTrace))
          if (trace.kind == RuleTraceKind.predicate &&
              trace.status == RuleTraceStatus.matched &&
              trace.operatorId == target.relationId &&
              trace.resolvedObjects.length >= 2)
            trace.resolvedObjects.take(2).toList(),
      ];
    }
    final refs = [
      for (final binding in [
        target.subjectBinding,
        target.sourceBinding,
        target.targetBinding,
      ])
        if (binding != null && context.get(binding) != null) context.get(binding)!,
    ];
    return [refs];
  }

  Iterable<RuleTrace> _flatten(RuleTrace? trace) sync* {
    if (trace == null) return;
    yield trace;
    for (final child in trace.children) {
      yield* _flatten(child);
    }
  }

  EvidenceId _evidenceId({
    required RuleDefinition rule,
    required String value,
    required ActionTarget target,
    required List<SemanticRef> targetRefs,
    required List<EvidenceId> supports,
  }) => EvidenceId.canonical(
        ruleId: rule.ruleId.id,
        version: rule.version.version,
        bindings: {
          for (var i = 0; i < targetRefs.length; i++)
            'target$i': targetRefs[i],
        },
        conclusion: '${target.kind.name}:${target.relationId ?? value}:$value',
        supports: supports,
      );
}
