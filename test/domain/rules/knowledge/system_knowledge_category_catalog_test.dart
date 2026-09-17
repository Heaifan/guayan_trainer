import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_category_catalog.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_rule_catalog.dart';

void main() {
  test(
    'SYSTEM knowledge category catalog has exactly twelve ordered categories',
    () {
      final categories = SystemKnowledgeCategoryCatalog.categories;

      expect(categories, hasLength(12));
      expect(categories.map((category) => category.id).toSet(), hasLength(12));
      expect(categories.map((category) => category.displayName), hasLength(12));
      expect(
        categories.map((category) => category.order),
        orderedEquals(List<int>.generate(12, (index) => index + 1)),
      );
    },
  );

  test('all SYSTEM KnowledgeRules have valid primary category and tags', () {
    final categoryIds = SystemKnowledgeCategoryCatalog.categories
        .map((category) => category.id)
        .toSet();

    expect(SystemKnowledgeRuleCatalog.rules, hasLength(10));
    for (final rule in SystemKnowledgeRuleCatalog.rules) {
      expect(rule.primaryCategoryId, isNotNull);
      expect(categoryIds, contains(rule.primaryCategoryId));
      expect(rule.tags, isNotEmpty);
    }
  });

  test('current ten SYSTEM KnowledgeRules use the frozen V1 mappings', () {
    final expected = <String, String>{
      'knowledge.xun_kong': 'knowledge.category.state',
      'knowledge.in_tomb': 'knowledge.category.state',
      'knowledge.yue_po': 'knowledge.category.calendar_influence',
      'knowledge.ri_po': 'knowledge.category.calendar_influence',
      'knowledge.month_generate': 'knowledge.category.calendar_influence',
      'knowledge.day_generate': 'knowledge.category.calendar_influence',
      'knowledge.fu_mu': 'knowledge.category.six_relatives',
      'knowledge.guan_gui': 'knowledge.category.six_relatives',
      'knowledge.fu_mu_xun_kong': 'knowledge.category.six_relatives',
      'knowledge.fu_mu_month_generate': 'knowledge.category.six_relatives',
    };

    final actual = {
      for (final rule in SystemKnowledgeRuleCatalog.rules)
        rule.id: rule.primaryCategoryId,
    };
    expect(actual, expected);
    expect(
      SystemKnowledgeRuleCatalog.rules
          .singleWhere((rule) => rule.id == 'knowledge.fu_mu_xun_kong')
          .tags,
      ['父母', '六亲', '旬空', '状态', '考试', '组合规则'],
    );
  });
}
