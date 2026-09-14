import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/engine/action_executor.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/evidence/evidence_id.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

RuleDefinition buildRule({required RuleId id, required RuleStage stage, required List<RuleAction> actions}) {
  return RuleDefinition(ruleId: id, version: RuleVersion('1.0.0'), origin: RuleOrigin.SYSTEM, namespace: 'test', categoryId: 'test', title: 'test', description: 'test', provenance: 'test', stage: stage, bindings: [], condition: PredicateExpr(operatorId: 'noop', operands: []), actions: actions);
}

void main() {
  group('ActionExecutor', () {
    late ActionExecutor executor;
    late BindingContext context;

    setUp(() {
      executor = const ActionExecutor();
      context = BindingContext();
      context.add('A', const SemanticRef('line', '2'));
      context.add('B', const SemanticRef('line', '3'));
    });

    test('DeriveAction', () {
      final rule = buildRule(id: const RuleId('test_rule'), stage: RuleStage.derivedState, actions: [const DeriveAction(targetBinding: 'A', factKey: 'state.parent_supported')]);
      final res = executor.execute(rule, context, [const EvidenceId('sup1')]);
      expect(res.derivedFacts.length, 1);
      expect(res.derivedFacts[0].predicateId, 'derive');
    });

    test('TagAction', () {
      final rule = buildRule(id: const RuleId('test_rule'), stage: RuleStage.tag, actions: [const TagAction(subjectBinding: 'A', categoryId: 'shensha', tagId: 'custom')]);
      final res = executor.execute(rule, context, []);
      expect(res.derivedFacts[0].predicateId, 'has_tag_shensha');
    });

    test('StructureAction', () {
      final rule = buildRule(id: const RuleId('test_rule'), stage: RuleStage.structure, actions: [const StructureAction(structureId: 'pair', memberBindings: ['A', 'B'])]);
      final res = executor.execute(rule, context, []);
      expect(res.derivedFacts[0].subject.kind, 'structure');
    });

    test('RecordAction', () {
      final rule = buildRule(id: const RuleId('test_rule'), stage: RuleStage.tag, actions: [RecordAction(recordType: 'summary', content: {'k': RuleValue.string("v")})]);
      final res = executor.execute(rule, context, []);
      expect(res.derivedFacts[0].subject.kind, 'record');
    });

    test('Multi-action Rule', () {
      final rule = buildRule(id: const RuleId('test_rule'), stage: RuleStage.derivedState, actions: [const DeriveAction(targetBinding: 'A', factKey: 'x'), const TagAction(subjectBinding: 'A', categoryId: 'y', tagId: 'z')]);
      final res = executor.execute(rule, context, []);
      expect(res.ruleHits.length, 2);
    });
  });
}
