library;

import '../ast/rule_action.dart';
import '../facts/fact_record.dart';
import '../facts/rule_value.dart';
import '../facts/semantic_ref.dart';
import '../evidence/evidence_id.dart';
import '../evidence/rule_hit.dart';
import '../core/rule_definition.dart';
import 'binding_resolver.dart';
import 'evidence_emitter.dart';

import 'engine_types.dart';

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
    final ruleHits = <RuleHit>[];

    for (final action in rule.actions) {
      FactRecord? newFact;
      String conclusion = '';

      if (action is DeriveAction) {
        final ref = context.get(action.targetBinding);
        if (ref != null) {
          newFact = FactRecord(
            factId: 'derived_${rule.ruleId.id}_${ref.kind}_${ref.key}_${action.factKey}',
            subject: ref,
            predicateId: 'derive',
            value: RuleValue.string(action.factKey),
            origin: FactOrigin.derived,
          );
          conclusion = 'derive ${action.factKey} on ${action.targetBinding}';
        }
      } else if (action is TagAction) {
        final ref = action.subjectBinding != null ? context.get(action.subjectBinding!) : const SemanticRef('global', 'scope');
        if (ref != null) {
          newFact = FactRecord(
            factId: 'tag_${rule.ruleId.id}_${ref.kind}_${ref.key}_${action.categoryId}_${action.tagId}',
            subject: ref,
            predicateId: 'has_tag_${action.categoryId}',
            value: RuleValue.string(action.tagId),
            origin: FactOrigin.derived,
          );
          conclusion = 'tag ${action.categoryId}.${action.tagId} on ${action.subjectBinding ?? "global"}';
        }
      } else if (action is StructureAction) {
        final refs = action.memberBindings.map((b) => context.get(b)).where((r) => r != null).toList();
        newFact = FactRecord(
          factId: 'structure_${rule.ruleId.id}_${action.structureId}',
          subject: SemanticRef('structure', action.structureId),
          predicateId: 'contains',
          value: RuleValue.string(refs.map((r) => '${r!.kind}/${r.key}').join(',')),
          origin: FactOrigin.derived,
        );
        conclusion = 'structure ${action.structureId}';
      } else if (action is RecordAction) {
        newFact = FactRecord(
          factId: 'record_${rule.ruleId.id}_${action.recordType}',
          subject: SemanticRef('record', action.recordType),
          predicateId: 'data',
          value: RuleValue.string(action.content.keys.join(',')),
          origin: FactOrigin.derived,
        );
        conclusion = 'record ${action.recordType}';
      }

      if (newFact != null) {
        derivedFacts.add(newFact);

        final hit = const EvidenceEmitter().emitHit(
          rule: rule,
          context: context,
          conclusion: conclusion,
          supports: supports,
        );
        ruleHits.add(hit);
      }
    }

    return ActionExecutionResult(derivedFacts, ruleHits);
  }
}
