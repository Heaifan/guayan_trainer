import '../core/rule_definition.dart';
import '../evidence/evidence_id.dart';
import '../evidence/rule_hit.dart';
import '../evidence/evidence_node.dart';
import '../evidence/evidence_edge.dart';
import '../facts/fact_record.dart';
import 'binding_resolver.dart';
import 'evidence_emitter.dart';
import 'engine_types.dart';
import 'action_output_factory.dart';

/// 执行规则动作并生成新的推导事实和 Evidence
class ActionExecutor {
  const ActionExecutor();

  /// 执行 actions，返回新产生的事实和对应的 RuleHit。
  ActionExecutionResult execute(
    RuleDefinition rule,
    BindingContext context,
    List<EvidenceId> supports,
  ) {
    final derivedFacts = <FactRecord>[];
    final derivedStates = <FactRecord>[];
    final tags = <FactRecord>[];
    final structures = <FactRecord>[];
    final records = <FactRecord>[];
    final ruleHits = <RuleHit>[];
    final evidenceNodes = <EvidenceNode>[];
    final evidenceEdges = <EvidenceEdge>[];

    for (final action in rule.actions) {
      final res = ActionOutputFactory.build(action, rule, context);
      final newFact = res.output;

      if (newFact != null) {
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
    );
  }
}
