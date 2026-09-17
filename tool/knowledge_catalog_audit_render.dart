import 'dart:convert';

import 'knowledge_catalog_audit_model.dart';

String renderAuditJson(KnowledgeCatalogAudit catalog) {
  return const JsonEncoder.withIndent('  ').convert({
    'baseline': catalog.baseline,
    'rules': catalog.rows.map((row) => row.toJson()).toList(),
    'objectiveAnomalies': catalog.objectiveAnomalies,
  });
}

String renderAuditMarkdown(KnowledgeCatalogAudit catalog) {
  final buffer = StringBuffer()
    ..writeln('# SYSTEM Knowledge Catalog V1 Audit')
    ..writeln()
    ..writeln('> 本文件由 `tool/knowledge_catalog_audit.dart` 从当前运行时真实规则生成。')
    ..writeln()
    ..writeln('## Baseline')
    ..writeln()
    ..writeln('```text');
  for (final entry in catalog.baseline.entries) {
    buffer.writeln('${entry.key}: ${entry.value}');
  }
  buffer
    ..writeln('```')
    ..writeln()
    ..writeln('## Complete Catalog (60 rows)')
    ..writeln()
    ..writeln(
      '| # | ExecutionRule | KnowledgeRule | 中文名 | Variant | Variant 中文名 | Version | Variant Version | Binding Targets | Technical Type | Runtime/System | Audit Note |',
    )
    ..writeln('|---:|---|---|---|---|---|---|---|---|---|---|---|');
  for (var index = 0; index < catalog.rows.length; index++) {
    final row = catalog.rows[index];
    final bindings = row.bindingTargets
        .map(
          (binding) =>
              '${binding['name']}=${binding['targetId']} (${binding['displayName']})',
        )
        .join('<br>');
    buffer.writeln(
      '| ${index + 1} | `${row.executionRuleId}` | `${row.knowledgeRuleId}` | ${row.knowledgeRuleDisplayName} | `${row.ruleVariantId}` | ${row.ruleVariantDisplayName} | ${row.version} | ${row.variantVersion} | $bindings | `${row.technicalType}` | ${row.runtimeSystem} | ${row.auditNote} |',
    );
  }
  buffer
    ..writeln()
    ..writeln('## Sources')
    ..writeln()
    ..writeln('| ExecutionRule | KnowledgeRule | RuleVariant | Mapping |')
    ..writeln('|---|---|---|---|');
  for (final row in catalog.rows) {
    buffer.writeln(
      '| `${row.executionRuleId}`: ${row.sources['executionRule']} | ${row.sources['knowledgeRule']} | ${row.sources['ruleVariant']} | ${row.sources['mapping']} |',
    );
  }
  buffer
    ..writeln()
    ..writeln('## Objective Anomalies')
    ..writeln();
  if (catalog.objectiveAnomalies.isEmpty) {
    buffer.writeln('None');
  } else {
    for (final anomaly in catalog.objectiveAnomalies) {
      buffer.writeln('- $anomaly');
    }
  }
  return buffer.toString();
}
