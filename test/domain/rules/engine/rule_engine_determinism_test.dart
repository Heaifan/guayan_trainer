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
    test('T8 - Order Invariance & Idempotence', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: ConditionId.relative,
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('parent')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );
      final rB = buildRule(
        'rB',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: 'derive_is',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('stateA')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateB')],
      );

      final engine = RuleEngine();
      engine.registry.register(
        const BinaryLiteralOperator('derive_is', 'derive'),
      );
      // Run 1: rA then rB
      final run1 = engine.execute([rA, rB], createInitialSnapshot());
      // Run 2: rB then rA
      final run2 = engine.execute([rB, rA], createInitialSnapshot());
      // Run 3: rA then rB again (Idempotence)
      final run3 = engine.execute([rA, rB], createInitialSnapshot());

      void compareRuns(AnalysisRun a, AnalysisRun b) {
        expect(a.derivedFacts.map((f) => '${f.predicateId}:${f.value}').toSet(),
               b.derivedFacts.map((f) => '${f.predicateId}:${f.value}').toSet());
        expect(a.ruleHits.map((h) => h.ruleId).toSet(),
               b.ruleHits.map((h) => h.ruleId).toSet());
        expect(a.evidenceNodes.map((n) => n.type).toSet(),
               b.evidenceNodes.map((n) => n.type).toSet());
      }

      // T7 Order Invariance
      compareRuns(run1, run2);

      // T8 Idempotence
      compareRuns(run1, run3);
    });

  });
}
