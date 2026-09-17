import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/knowledge/execution_rule_ref.dart';
import 'package:guayan_trainer/domain/rules/knowledge/rule_variant.dart';

void main() {
  test('ExecutionRuleRef preserves explicit display name and order', () {
    const ref = ExecutionRuleRef(
      ruleId: 'common.line.6.xun_kong',
      displayName: '上爻',
      order: 6,
    );

    expect(ref.ruleId, 'common.line.6.xun_kong');
    expect(ref.displayName, '上爻');
    expect(ref.order, 6);
  });

  test(
    'RuleVariant exposes every referenced execution rule without selection',
    () {
      const variant = RuleVariant(
        id: 'variant.xun_kong.common',
        knowledgeRuleId: 'knowledge.xun_kong',
        name: '通用判法',
        origin: 'system',
        version: '1.0.0',
        executionRules: [
          ExecutionRuleRef(
            ruleId: 'common.line.1.xun_kong',
            displayName: '初爻',
            order: 1,
          ),
          ExecutionRuleRef(
            ruleId: 'common.line.2.xun_kong',
            displayName: '二爻',
            order: 2,
          ),
        ],
      );

      expect(variant.executionRules, hasLength(2));
      expect(variant.executionRules.map((ref) => ref.order), [1, 2]);
    },
  );
}
