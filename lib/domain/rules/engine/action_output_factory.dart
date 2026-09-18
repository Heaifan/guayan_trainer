import '../ast/rule_action.dart';
import '../facts/fact_record.dart';
import '../facts/rule_value.dart';
import '../facts/semantic_ref.dart';
import '../core/rule_definition.dart';
import 'binding_resolver.dart';

class BuiltActionOutput {
  final FactRecord? output;
  final String conclusion;
  final String kind;
  const BuiltActionOutput({this.output, this.conclusion = '', this.kind = 'fact'});
}

class ActionOutputFactory {
  static BuiltActionOutput build(RuleAction action, RuleDefinition rule, BindingContext context) {
    if (action is DeriveAction) {
      final ref = context.get(action.targetBinding);
      if (ref != null) {
        return BuiltActionOutput(
          output: FactRecord(
            factId: 'derived_${rule.ruleId.id}_${ref.kind}_${ref.key}_${action.factKey}',
            subject: ref,
            predicateId: 'derive',
            value: RuleValue.string(action.factKey),
            origin: FactOrigin.derived,
          ),
          conclusion: 'derive ${action.factKey} on ${action.targetBinding}',
        );
      }
    } else if (action is TagAction) {
      final subjectBinding = action.subjectBinding ?? action.target?.sourceBinding;
      final ref = subjectBinding != null ? context.get(subjectBinding) : const SemanticRef('global', 'scope');
      if (ref != null) {
        return BuiltActionOutput(
          output: FactRecord(
            factId: 'tag_${rule.ruleId.id}_${ref.kind}_${ref.key}_${action.categoryId}_${action.tagId}',
            subject: ref,
            predicateId: 'has_tag_${action.categoryId}',
            value: RuleValue.string(action.tagId),
            origin: FactOrigin.derived,
          ),
          conclusion: 'tag ${action.categoryId}.${action.tagId} on ${action.subjectBinding ?? "global"}',
          kind: 'tag',
        );
      }
    } else if (action is StructureAction) {
      final refs = action.memberBindings.map((b) => context.get(b)).where((r) => r != null).toList();
      return BuiltActionOutput(
        output: FactRecord(
          factId: 'structure_${rule.ruleId.id}_${action.structureId}',
          subject: SemanticRef('structure', action.structureId),
          predicateId: 'contains',
          value: RuleValue.string(refs.map((r) => '${r!.kind}/${r.key}').join(',')),
          origin: FactOrigin.derived,
        ),
        conclusion: 'structure ${action.structureId}',
        kind: 'structure',
      );
    } else if (action is RecordAction) {
      return BuiltActionOutput(
        output: FactRecord(
          factId: 'record_${rule.ruleId.id}_${action.recordType}',
          subject: SemanticRef('record', action.recordType),
          predicateId: 'data',
          value: RuleValue.string(action.content.keys.join(',')),
          origin: FactOrigin.derived,
        ),
        conclusion: 'record ${action.recordType}',
        kind: 'record',
      );
    }
    return const BuiltActionOutput();
  }
}
