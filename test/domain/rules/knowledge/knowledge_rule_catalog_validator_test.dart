import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/knowledge/knowledge_rule_catalog_validator.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_category_catalog.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_rule_catalog.dart';

void main() {
  test(
    'system catalog passes identity, reference, and coverage validation',
    () {
      final issues = KnowledgeRuleCatalogValidator.validate(
        SystemKnowledgeRuleCatalog.rules,
        SystemKnowledgeRuleCatalog.systemExecutionRules
            .map((rule) => rule.ruleId.id)
            .toList(),
      );

      expect(issues, isEmpty);
    },
  );

  test('system catalog rejects a missing or orphaned primary category', () {
    final rule = SystemKnowledgeRuleCatalog.rules.first;
    final invalid = rule.copyWith(
      primaryCategoryId: 'knowledge.category.missing',
    );

    final issues = KnowledgeRuleCatalogValidator.validate(
      [invalid, ...SystemKnowledgeRuleCatalog.rules.skip(1)],
      SystemKnowledgeRuleCatalog.systemExecutionRules
          .map((rule) => rule.ruleId.id)
          .toList(),
      categoryIds: SystemKnowledgeCategoryCatalog.categories
          .map((category) => category.id)
          .toSet(),
    );

    expect(issues, contains('invalid primary category: ${rule.id}'));
  });
}
