import 'knowledge_rule.dart';
import 'knowledge_rule_category.dart';
import 'rule_variant.dart';
import 'system_knowledge_category_catalog.dart';

class KnowledgeRuleCatalogValidator {
  static List<String> validate(
    List<KnowledgeRule> rules,
    List<String> systemExecutionRuleIds, {
    Set<String>? categoryIds,
  }) {
    final issues = <String>[];
    final systemIds = systemExecutionRuleIds.toSet();
    final knowledgeIds = <String>{};
    final variantIds = <String>{};
    final mappedIds = <String>{};
    final validCategoryIds = categoryIds ?? SystemKnowledgeCategoryCatalog.ids;

    for (final rule in rules) {
      if (!knowledgeIds.add(rule.id)) {
        issues.add('duplicate knowledge rule: ${rule.id}');
      }
      if (rule.name.trim().isEmpty) {
        issues.add('empty knowledge rule name: ${rule.id}');
      }
      if (!KnowledgeRuleCategory.ids.contains(rule.categoryId)) {
        issues.add('invalid category: ${rule.id}');
      }
      if (rule.primaryCategoryId == null ||
          !validCategoryIds.contains(rule.primaryCategoryId)) {
        issues.add('invalid primary category: ${rule.id}');
      }
      if (rule.variants.isEmpty) {
        issues.add('knowledge rule has no variant: ${rule.id}');
      }
      for (final variant in rule.variants) {
        _validateVariant(
          variant,
          rule,
          systemIds,
          knowledgeIds,
          variantIds,
          mappedIds,
          issues,
        );
      }
    }

    for (final systemId in systemIds) {
      if (!mappedIds.contains(systemId)) {
        issues.add('orphan system rule: $systemId');
      }
    }
    return issues;
  }

  static void _validateVariant(
    RuleVariant variant,
    KnowledgeRule rule,
    Set<String> systemIds,
    Set<String> knowledgeIds,
    Set<String> variantIds,
    Set<String> mappedIds,
    List<String> issues,
  ) {
    if (!variantIds.add(variant.id)) {
      issues.add('duplicate variant: ${variant.id}');
    }
    if (variant.knowledgeRuleId != rule.id) {
      issues.add('variant owner mismatch: ${variant.id}');
    }
    if (!knowledgeIds.contains(variant.knowledgeRuleId) &&
        variant.knowledgeRuleId != rule.id) {
      issues.add('unknown knowledge rule owner: ${variant.id}');
    }
    if (variant.executionRules.isEmpty) {
      issues.add('variant has no execution refs: ${variant.id}');
    }
    final refs = <String>{};
    for (final ref in variant.executionRules) {
      if (!refs.add(ref.ruleId)) {
        issues.add('duplicate ref in variant: ${ref.ruleId}');
      }
      if (!systemIds.contains(ref.ruleId)) {
        issues.add('unknown system ref: ${ref.ruleId}');
      }
      if (!mappedIds.add(ref.ruleId)) {
        issues.add('system ref mapped more than once: ${ref.ruleId}');
      }
    }
  }
}
