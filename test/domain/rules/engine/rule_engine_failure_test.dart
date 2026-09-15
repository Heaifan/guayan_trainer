import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'rule_engine_test_fixture.dart';

void main() {
  group('RuleEngine', () {
    test('T1 - Restore Fail Closed (Throws on Unknown Operator)', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: 'unknown_operator',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('parent')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );

      expect(() => RuleEngine().execute([rA], createInitialSnapshot()), throwsA(isA<Exception>()));
    });

  });
}
