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
import 'rule_engine_test_fixture.dart';

void main() {
  group('RuleEngine', () {
    test('T9 - Immutable Input', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: ConditionId.relative,
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('fuMu')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );

      final preSnapshot = createInitialSnapshot().facts.map((f) => '${f.factId}|${f.subject.kind}/${f.subject.key}|${f.predicateId}|${f.value.toString()}|${f.origin}').toList();

      RuleEngine().execute([rA], createInitialSnapshot());

      final postSnapshot = createInitialSnapshot().facts.map((f) => '${f.factId}|${f.subject.kind}/${f.subject.key}|${f.predicateId}|${f.value.toString()}|${f.origin}').toList();

      expect(postSnapshot, equals(preSnapshot));
    });

    test('T10 - AnalysisRun Immutability', () {
      final rA = buildRule(
        'rA',
        RuleStage.derivedState,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        PredicateExpr(
          operatorId: ConditionId.relative,
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('fuMu')),
          ],
        ),
        [const DeriveAction(targetBinding: 'A', factKey: 'stateA')],
      );
      final run = RuleEngine().execute([rA], createInitialSnapshot());

      expect(() => run.derivedFacts.add(createInitialSnapshot().facts.first), throwsUnsupportedError);
      expect(() => run.tags.clear(), throwsUnsupportedError);
      expect(() => run.ruleHits.removeLast(), throwsUnsupportedError);
    });

  });
}
