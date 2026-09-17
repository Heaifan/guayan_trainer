import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/knowledge/knowledge_rule_catalog_validator.dart';
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
}
