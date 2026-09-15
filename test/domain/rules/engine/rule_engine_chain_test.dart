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
    test('T7 - Golden Chain', () {
      final rule1 = buildRule(
        'r1',
        RuleStage.derivedState,
        [
          const RuleBinding(name: 'A', selector: DirectSelector('line/2')),
          const RuleBinding(name: 'M', selector: DirectSelector('month/M')),
        ],
        AllExpr([
          PredicateExpr(
            operatorId: ConditionId.relative,
            operands: [
              BindingRefOperand('A'),
              LiteralOperand(RuleValue.string('parent')),
            ],
          ),
          PredicateExpr(
            operatorId: ConditionId.generate,
            operands: [BindingRefOperand('M'), BindingRefOperand('A')],
          ),
        ]),
        [const DeriveAction(targetBinding: 'A', factKey: 'parent_supported')],
      );
      final rule2 = buildRule(
        'r2',
        RuleStage.tag,
        [const RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        AllExpr([
          PredicateExpr(
            operatorId: ConditionId.nayinIs,
            operands: [
              BindingRefOperand('A'),
              LiteralOperand(RuleValue.string('nayin.tian_he_shui')),
            ],
          ),
          PredicateExpr(
            operatorId: 'derive_is',
            operands: [
              BindingRefOperand('A'),
              LiteralOperand(RuleValue.string('parent_supported')),
            ],
          ),
        ]),
        [
          const TagAction(
            subjectBinding: 'A',
            categoryId: 'xiang',
            tagId: 'exam',
          ),
        ],
      );
      final engine = RuleEngine();
      engine.registry.register(
        const BinaryLiteralOperator('derive_is', 'derive'),
      );
      final run = engine.execute([rule1, rule2], createInitialSnapshot());
      expect(run.derivedFacts.length, 1, reason: 'Rule1 output exists');
      expect(run.tags.length, 1, reason: 'Rule2 Tag exists');
      final derivedFact = run.derivedFacts.first;
      expect(createInitialSnapshot().getFact(derivedFact.factId), isNull, reason: 'Rule1 output did not exist in original input');
      final tag = run.tags.first;
      expect(createInitialSnapshot().getFact(tag.factId), isNull, reason: 'Rule2 Tag did not exist in original input');
      final hit1 = run.ruleHits.firstWhere((h) => h.ruleId.id == 'r1', orElse: () => throw Exception('RuleHit-1 missing'));
      final hit2 = run.ruleHits.firstWhere((h) => h.ruleId.id == 'r2', orElse: () => throw Exception('RuleHit-2 missing'));
      expect(hit1, isNotNull, reason: 'RuleHit-1 exists');
      expect(hit2, isNotNull, reason: 'RuleHit-2 exists');
      // Rule2 support contains Rule1 derived evidence
      final hit2Node = run.evidenceNodes.firstWhere((n) => n.id == hit2.hitId);
      final supportsHit2 = run.evidenceEdges.where((e) => e.targetId == hit2Node.id && e.relationType == 'supports').map((e) => e.sourceId).toList();
      final derivedFactNode = run.evidenceNodes.firstWhere((n) => n.type == 'fact' && n.label.contains('parent_supported'));
      expect(supportsHit2.contains(derivedFactNode.id), isTrue, reason: 'Rule2 support contains Rule1 derived evidence');
    });
  });
}
