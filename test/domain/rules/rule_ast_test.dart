import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';

void main() {
  group('T2 Golden Contract Test', () {
    test('手工构建规则：父母得月生', () {
      // 本测试证�?Canonical Model 能完整表达：
      // �?A 为二爻，M 为月�?
      // �?A之六亲为父母 �?A临青�?�?M生A �?A非旬�?
      // �?A得「父母有力�? A取象「文书�?

      final bindings = [
        RuleBinding(name: 'A', selector: DirectSelector('line/2')),
        RuleBinding(name: 'M', selector: DirectSelector('calendar/month')),
      ];

      final condition = AllExpr([
        PredicateExpr(
          operatorId: 'relative',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('relative.parent')),
          ],
        ),
        PredicateExpr(
          operatorId: 'spirit',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('spirit.azure_dragon')),
          ],
        ),
        PredicateExpr(
          operatorId: 'generate',
          operands: [
            BindingRefOperand('M'),
            BindingRefOperand('A'),
          ],
        ),
        NotExpr(
          PredicateExpr(
            operatorId: 'empty',
            operands: [
              BindingRefOperand('A'),
            ],
          ),
        ),
      ]);

      final actions = [
        DeriveAction(targetBinding: 'A', factKey: 'state.parent.strong'),
        TagAction(categoryId: 'exam', tagId: 'document', subjectBinding: 'A'),
      ];

      final rule = RuleDefinition(
        ruleId: RuleId('exam.document.parent.azure_dragon'),
        version: RuleVersion('1.0.0'),
        origin: RuleOrigin.SYSTEM,
        namespace: 'core',
        categoryId: 'exam',
        stage: RuleStage.derivedState,
        title: '父母得月�?,
        description: '父母临青龙得月建生，不空，为文书有利之象�?,
        provenance: '《增删卜易�?,
        bindings: bindings,
        condition: condition,
        actions: actions,
      );

      expect(rule.ruleId.id, 'exam.document.parent.azure_dragon');
      expect(rule.actions.length, 2);
      expect(rule.bindings.length, 2);
      expect((rule.condition as AllExpr).nodes.length, 4);
    });
  });
}
