class KnowledgeRuleCatalogCoverage {
  const KnowledgeRuleCatalogCoverage({
    required this.systemExecutionRuleCount,
    required this.mappedExecutionRuleCount,
    required this.orphanExecutionRuleIds,
    required this.validationIssues,
  });

  final int systemExecutionRuleCount;
  final int mappedExecutionRuleCount;
  final List<String> orphanExecutionRuleIds;
  final List<String> validationIssues;
}
