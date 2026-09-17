import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_rule_catalog.dart';

void main() {
  test('xun_kong has one six-line system variant in line order', () {
    final rule = SystemKnowledgeRuleCatalog.rules.singleWhere(
      (item) => item.id == 'knowledge.xun_kong',
    );
    final variant = rule.variants.single;

    expect(rule.name, '旬空');
    expect(rule.categoryId, 'voidTombGrowth');
    expect(variant.name, '通用判法');
    expect(variant.executionRules.map((ref) => ref.ruleId), [
      'common.line.1.xun_kong',
      'common.line.2.xun_kong',
      'common.line.3.xun_kong',
      'common.line.4.xun_kong',
      'common.line.5.xun_kong',
      'common.line.6.xun_kong',
    ]);
    expect(variant.executionRules.map((ref) => ref.displayName), [
      '初爻',
      '二爻',
      '三爻',
      '四爻',
      '五爻',
      '上爻',
    ]);
  });

  test(
    'catalog has explicit system coverage for every loadable corpus rule',
    () {
      final report = SystemKnowledgeRuleCatalog.validateCoverage();

      expect(report.systemExecutionRuleCount, 60);
      expect(report.mappedExecutionRuleCount, 60);
      expect(report.orphanExecutionRuleIds, isEmpty);
    },
  );
}
