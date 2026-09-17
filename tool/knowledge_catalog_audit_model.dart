class KnowledgeCatalogAudit {
  const KnowledgeCatalogAudit({
    required this.baseline,
    required this.rows,
    required this.objectiveAnomalies,
  });

  final Map<String, Object?> baseline;
  final List<KnowledgeCatalogAuditRow> rows;
  final List<String> objectiveAnomalies;
}

class KnowledgeCatalogAuditRow {
  const KnowledgeCatalogAuditRow({
    required this.executionRuleId,
    required this.knowledgeRuleId,
    required this.knowledgeRuleDisplayName,
    required this.ruleVariantId,
    required this.ruleVariantDisplayName,
    required this.version,
    required this.variantVersion,
    required this.bindingTargets,
    required this.technicalType,
    required this.sources,
    required this.runtimeSystem,
    required this.auditNote,
  });

  final String executionRuleId;
  final String knowledgeRuleId;
  final String knowledgeRuleDisplayName;
  final String ruleVariantId;
  final String ruleVariantDisplayName;
  final String version;
  final String variantVersion;
  final List<Map<String, String>> bindingTargets;
  final String technicalType;
  final Map<String, String> sources;
  final String runtimeSystem;
  final String auditNote;

  Map<String, Object?> toJson() => {
    'executionRuleId': executionRuleId,
    'knowledgeRuleId': knowledgeRuleId,
    'knowledgeRuleDisplayName': knowledgeRuleDisplayName,
    'ruleVariantId': ruleVariantId,
    'ruleVariantDisplayName': ruleVariantDisplayName,
    'version': version,
    'variantVersion': variantVersion,
    'bindingTargets': bindingTargets,
    'technicalType': technicalType,
    'sources': sources,
    'runtimeSystem': runtimeSystem,
    'auditNote': auditNote,
  };
}
