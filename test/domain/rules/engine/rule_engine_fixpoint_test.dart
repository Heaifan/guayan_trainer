import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/structural_operators.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/fact_operators.dart';
import 'rule_engine_test_fixture.dart';

void main() {
  group('RuleEngine', () {
    test('T11 - Convergent Cycle', () {
      final rX = buildRule('rX', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        AnyExpr([
          PredicateExpr(operatorId: ConditionId.relative, operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('fuMu'))]),
          PredicateExpr(operatorId: 'derive_is', operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('stateY'))]),
        ]),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateX')],
      );
      final rY = buildRule('rY', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(operatorId: 'derive_is', operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('stateX'))]),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateY')],
      );
      final engine = RuleEngine();
      engine.registry.register(const BinaryLiteralOperator('derive_is', 'derive'));
      final run = engine.execute([rX, rY], createInitialSnapshot());
      expect(run.derivedFacts.length, 2);
    });

    test('T12 - Non-Convergence Guard', () {
      final r1 = buildRule('r1', RuleStage.derivedState, [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(operatorId: ConditionId.relative, operands: [BindingRefOperand('A'), LiteralOperand(RuleValue.string('fuMu'))]),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );
      final engine = RuleEngine(maxIterationsPerStage: 1);
      engine.registry.register(const BinaryLiteralOperator('derive_is', 'derive'));
      expect(() => engine.execute([r1], createInitialSnapshot()), throwsA(isA<RuleEngineNonConvergence>()));
    });
  });
}
