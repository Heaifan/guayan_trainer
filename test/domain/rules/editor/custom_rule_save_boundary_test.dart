import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';

RuleDefinition _legalRule({
  required String id,
  required String namespace,
  required String categoryId,
}) {
  return RuleDefinition(
    ruleId: RuleId(id),
    version: RuleVersion('1.0.0'),
    origin: RuleOrigin.CUSTOM,
    namespace: namespace,
    categoryId: categoryId,
    stage: RuleStage.tag,
    title: 'Save boundary fixture',
    description: '',
    provenance: '',
    bindings: [RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
    condition: PredicateExpr(
      operatorId: 'relative',
      operands: [
        BindingRefOperand('A'),
        LiteralOperand(RuleValue.string('fuMu')),
      ],
    ),
    actions: [
      TagAction(categoryId: categoryId, tagId: 'save_ok', subjectBinding: 'A'),
    ],
  );
}

CustomRuleService _service() =>
    CustomRuleService(CustomRuleStore(), UserGovernanceState());

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('R5-FIX-01 · COMMON Custom Rule Save Boundary', () {
    test('COMMON 合法规则 → save 成功并可从 store 读回', () async {
      final service = _service();
      await service.load();
      final rule = _legalRule(
        id: 'custom.common.save_ok',
        namespace: 'common',
        categoryId: 'common',
      );

      await service.save(rule, const []);

      expect(service.store.getAll(), hasLength(1));
      expect(service.store.getAll().first.ruleId.id, rule.ruleId.id);
      expect(service.store.getAll().first.namespace, 'common');
      expect(service.store.getAll().first.categoryId, 'common');

      final reloaded = CustomRuleStore();
      await reloaded.load();
      expect(reloaded.getAll(), hasLength(1));
      expect(reloaded.getAll().first.ruleId.id, rule.ruleId.id);
    });

    test('topic.exam 合法规则 → save 成功', () async {
      final service = _service();
      await service.load();
      final rule = _legalRule(
        id: 'custom.exam.save_ok',
        namespace: 'topic.exam',
        categoryId: 'exam',
      );

      await service.save(rule, const []);

      expect(service.store.getAll(), hasLength(1));
      expect(service.store.getAll().first.namespace, 'topic.exam');
      expect(service.store.getAll().first.categoryId, 'exam');
    });

    test('topic.exam + categoryId 错误 → save 失败', () async {
      final service = _service();
      await service.load();
      final rule = _legalRule(
        id: 'custom.exam.bad_category',
        namespace: 'topic.exam',
        categoryId: 'common',
      );

      await expectLater(service.save(rule, const []), throwsStateError);
      expect(service.store.getAll(), isEmpty);
    });

    test('非法 namespace → save 失败', () async {
      final service = _service();
      await service.load();
      final rule = _legalRule(
        id: 'custom.unknown.ns',
        namespace: 'wealth',
        categoryId: 'wealth',
      );

      await expectLater(service.save(rule, const []), throwsStateError);
      expect(service.store.getAll(), isEmpty);
    });
  });
}
