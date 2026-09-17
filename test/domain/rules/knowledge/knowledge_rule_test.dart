import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/knowledge/knowledge_rule.dart';
import 'package:guayan_trainer/domain/rules/knowledge/rule_variant.dart';
import 'package:guayan_trainer/domain/rules/knowledge/execution_rule_ref.dart';

void main() {
  test('KnowledgeRule keeps stable identity and allows multiple variants', () {
    const common = RuleVariant(
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
      ],
    );
    const testVariant = RuleVariant(
      id: 'variant.xun_kong.test',
      knowledgeRuleId: 'knowledge.xun_kong',
      name: '测试判法',
      origin: 'test',
      version: '0.0.1',
      executionRules: [
        ExecutionRuleRef(
          ruleId: 'test.xun_kong',
          displayName: '测试规则',
          order: 1,
        ),
      ],
    );

    const rule = KnowledgeRule(
      id: 'knowledge.xun_kong',
      name: '旬空',
      categoryId: 'voidTombGrowth',
      summary: '判断某爻是否处于旬空状态。',
      variants: [common, testVariant],
    );

    expect(rule.id, 'knowledge.xun_kong');
    expect(rule.variants.map((variant) => variant.id), [
      'variant.xun_kong.common',
      'variant.xun_kong.test',
    ]);
    expect(rule.variants, hasLength(2));
  });
}
