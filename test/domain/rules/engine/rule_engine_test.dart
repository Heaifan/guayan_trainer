import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/structural_operators.dart';

RuleDefinition buildRule(String id, RuleStage stage, List<RuleBinding> bindings, RuleExpr condition, List<RuleAction> actions) {
  return RuleDefinition(ruleId: RuleId(id), version: RuleVersion('1.0.0'), origin: RuleOrigin.SYSTEM, namespace: 'test', categoryId: 'test', title: 'test', description: 'test', provenance: 'test', stage: stage, bindings: bindings, condition: condition, actions: actions);
}

void main() {
  group('RuleEngine', () {
    late FactSnapshot initialSnapshot;

    setUp(() {
      initialSnapshot = FactSnapshot.build([
        FactRecord(factId: 'f1', subject: SemanticRef('line', '2'), predicateId: 'relative', value: RuleValue.string('parent'), origin: FactOrigin.baseRelation),
        FactRecord(factId: 'f2', subject: SemanticRef('month', 'M'), predicateId: 'relation.generate', value: RuleValue.string('line/2'), origin: FactOrigin.baseRelation),
        FactRecord(factId: 'f3', subject: SemanticRef('line', '2'), predicateId: 'nayin', value: RuleValue.string('tian_he_shui'), origin: FactOrigin.baseRelation),
      ]);
    });

    test('T7 - Golden Chain', () {
      final rule1 = buildRule('r1', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2')), const RuleBinding(name: 'M', selector: DirectSelector('month/M'))],
        AllExpr([PredicateExpr(operatorId: ConditionId.relative, operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('parent'))]), PredicateExpr(operatorId: ConditionId.generate, operands: [BindingRefOperand('M'), BindingRefOperand('A')])]),
        [const DeriveAction(targetBinding: 'A', factKey: 'parent_supported')]);

      final rule2 = buildRule('r2', RuleStage.tag, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        AllExpr([PredicateExpr(operatorId: ConditionId.nayinIs, operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('tian_he_shui'))]), PredicateExpr(operatorId: 'derive_is', operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('parent_supported'))])]),
        [const TagAction(subjectBinding: 'A', categoryId: 'xiang', tagId: 'exam')]);

      final engine = RuleEngine();
      engine.registry.register(const BinaryLiteralOperator('derive_is', 'derive'));
      final run = engine.execute([rule1, rule2], initialSnapshot);

      expect(run.derivedFacts.length, 2);
    });

    test('T8 - Order Invariance & Idempotence', () {
      final rA = buildRule('rA', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))], PredicateExpr(operatorId: ConditionId.relative, operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('parent'))]), [const DeriveAction(targetBinding: 'A', factKey: 'stateA')]);
      final rB = buildRule('rB', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))], PredicateExpr(operatorId: 'derive_is', operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('stateA'))]), [const DeriveAction(targetBinding: 'A', factKey: 'stateB')]);

      final engine = RuleEngine();
      engine.registry.register(const BinaryLiteralOperator('derive_is', 'derive'));
      final run1 = engine.execute([rA, rB], initialSnapshot);
      final run2 = engine.execute([rB, rA], initialSnapshot);

      expect(run1.derivedFacts.length, run2.derivedFacts.length);
    });

    test('T9 - Immutable Input', () {
      final rA = buildRule('rA', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))], PredicateExpr(operatorId: ConditionId.relative, operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('parent'))]), [const DeriveAction(targetBinding: 'A', factKey: 'stateA')]);
      RuleEngine().execute([rA], initialSnapshot);
      expect(initialSnapshot.facts.length, 3);
    });

    test('T11 - Convergent Cycle', () {
      final rX = buildRule('rX', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))], AnyExpr([PredicateExpr(operatorId: ConditionId.relative, operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('parent'))]), PredicateExpr(operatorId: 'derive_is', operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('stateY'))])]), [const DeriveAction(targetBinding: 'A', factKey: 'stateX')]);
      final rY = buildRule('rY', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))], PredicateExpr(operatorId: 'derive_is', operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('stateX'))]), [const DeriveAction(targetBinding: 'A', factKey: 'stateY')]);

      final engine = RuleEngine();
      engine.registry.register(const BinaryLiteralOperator('derive_is', 'derive'));
      final run = engine.execute([rX, rY], initialSnapshot);
      expect(run.derivedFacts.length, 2);
    });

    test('T12 - Non-Convergence Guard', () {
      final rA = buildRule('rA', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))], PredicateExpr(operatorId: ConditionId.relative, operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('parent'))]), [const DeriveAction(targetBinding: 'A', factKey: 'stateA')]);
      final rB = buildRule('rB', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))], PredicateExpr(operatorId: 'derive_is', operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('stateA'))]), [const DeriveAction(targetBinding: 'A', factKey: 'stateB')]);

      final engine = RuleEngine(maxIterationsPerStage: 1);
      engine.registry.register(const BinaryLiteralOperator('derive_is', 'derive'));
      expect(() => engine.execute([rA, rB], initialSnapshot), throwsA(isA<RuleEngineNonConvergence>()));
    });
  });
}
