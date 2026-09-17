import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/knowledge/execution_rule_ref.dart';
import 'package:guayan_trainer/domain/rules/knowledge/knowledge_rule.dart';
import 'package:guayan_trainer/domain/rules/knowledge/rule_variant.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_category_catalog.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_rule_catalog.dart';
import 'knowledge_catalog_audit_model.dart';

KnowledgeCatalogAudit buildSystemKnowledgeCatalogAudit({
  required String branch,
  required String head,
  required String generationTime,
}) {
  final rules = SystemKnowledgeRuleCatalog.systemExecutionRules;
  final rulesById = {for (final rule in rules) rule.ruleId.id: rule};
  final coverage = SystemKnowledgeRuleCatalog.validateCoverage();
  final rows = <KnowledgeCatalogAuditRow>[];
  final anomalies = <String>[...coverage.validationIssues];

  for (final knowledgeRule in SystemKnowledgeRuleCatalog.rules) {
    for (final variant in knowledgeRule.variants) {
      for (final ref in variant.executionRules) {
        final executionRule = rulesById[ref.ruleId];
        if (executionRule == null) {
          anomalies.add('ExecutionRule not found: ${ref.ruleId}');
          continue;
        }
        rows.add(_row(knowledgeRule, variant, ref, executionRule));
      }
    }
  }

  final missingKnowledgeNames = rows
      .where((row) => row.knowledgeRuleDisplayName == 'MISSING')
      .length;
  final missingVariantNames = rows
      .where((row) => row.ruleVariantDisplayName == 'MISSING')
      .length;
  final missingVersions = rows.where((row) => row.version == 'MISSING').length;
  final missingBindingNames = rows
      .expand((row) => row.bindingTargets)
      .where((binding) => binding['displayName'] == 'MISSING')
      .length;

  return KnowledgeCatalogAudit(
    baseline: {
      'branch': branch,
      'head': head,
      'generationTime': generationTime,
      'systemExecutionRuleCount': rules.length,
      'catalogRowCount': rows.length,
      'knowledgeRuleCount': SystemKnowledgeRuleCatalog.rules.length,
      'ruleVariantCount': SystemKnowledgeRuleCatalog.rules
          .expand((rule) => rule.variants)
          .length,
      'uniqueExecutionRuleCount': rows
          .map((row) => row.executionRuleId)
          .toSet()
          .length,
      'orphanCount': coverage.orphanExecutionRuleIds.length,
      'missingKnowledgeRuleDisplayNameCount': missingKnowledgeNames,
      'missingRuleVariantDisplayNameCount': missingVariantNames,
      'missingVersionCount': missingVersions,
      'missingBindingDisplayNameCount': missingBindingNames,
      'missingSourceCount': 0,
      'categoryCount': SystemKnowledgeCategoryCatalog.categories.length,
    },
    categories: SystemKnowledgeCategoryCatalog.categories
        .map((category) => category.toJson())
        .toList(),
    rows: rows,
    objectiveAnomalies: anomalies,
  );
}

KnowledgeCatalogAuditRow _row(
  KnowledgeRule knowledgeRule,
  RuleVariant variant,
  ExecutionRuleRef ref,
  RuleDefinition rule,
) {
  final bindings = rule.bindings.map<Map<String, String>>((binding) {
    final targetId = binding.selector is DirectSelector
        ? (binding.selector as DirectSelector).target
        : 'UNDEFINED';
    final displayName = targetId == 'line/${ref.order}'
        ? ref.displayName
        : 'MISSING';
    return {
      'name': binding.name,
      'targetId': targetId,
      'displayName': displayName,
    };
  }).toList();
  return KnowledgeCatalogAuditRow(
    executionRuleId: rule.ruleId.id,
    knowledgeRuleId: knowledgeRule.id,
    knowledgeRuleDisplayName: knowledgeRule.name,
    primaryCategoryId: knowledgeRule.primaryCategoryId!,
    primaryCategoryDisplayName: SystemKnowledgeCategoryCatalog.byId(
      knowledgeRule.primaryCategoryId!,
    ).displayName,
    tags: knowledgeRule.tags,
    ruleVariantId: variant.id,
    ruleVariantDisplayName: variant.name,
    version: rule.version.version,
    variantVersion: variant.version,
    bindingTargets: bindings,
    technicalType:
        '${rule.stage.name}/${rule.condition.runtimeType}/${rule.actions.map((a) => a.runtimeType).join('+')}',
    sources: {
      'executionRule': _executionSource(rule.ruleId.id),
      'knowledgeRule': _catalogSource,
      'ruleVariant': _catalogSource,
      'mapping': _catalogSource,
    },
    runtimeSystem: rule.origin.name,
    auditNote: 'None',
  );
}

const _catalogSource =
    'lib/domain/rules/knowledge/system_knowledge_rule_catalog.dart:SystemKnowledgeRuleCatalog.rules';

String _executionSource(String ruleId) {
  if (ruleId.startsWith('common.')) {
    return 'lib/domain/rules/corpus/common_rule_factory.dart:CommonRuleFactory.buildLineRules';
  }
  if (ruleId.contains('.role.')) {
    return 'lib/domain/rules/topics/exam/exam_role_rule_factory.dart:ExamRoleRuleFactory.buildRoleRules';
  }
  return 'lib/domain/rules/topics/exam/exam_common_tag_rule_factory.dart:ExamCommonTagRuleFactory.buildCommonTagRules';
}
