import 'dart:io';

export 'knowledge_catalog_audit_model.dart';
export 'knowledge_catalog_audit_render.dart';
export 'knowledge_catalog_audit_builder.dart';

import 'knowledge_catalog_audit_builder.dart';
import 'knowledge_catalog_audit_render.dart';

void main() {
  final branch = _git('branch', '--show-current');
  final head = _git('rev-parse', 'HEAD');
  final generationTime = DateTime.now().toUtc().toIso8601String();
  final catalog = buildSystemKnowledgeCatalogAudit(
    branch: branch,
    head: head,
    generationTime: generationTime,
  );
  final outputDirectory = Directory('docs/knowledge')
    ..createSync(recursive: true);
  File(
    '${outputDirectory.path}/system-knowledge-catalog-v1-audit.json',
  ).writeAsStringSync('${renderAuditJson(catalog)}\n');
  File(
    '${outputDirectory.path}/system-knowledge-catalog-v1-audit.md',
  ).writeAsStringSync(renderAuditMarkdown(catalog));
  stdout.writeln(
    'Generated ${catalog.rows.length} rows; orphan=${catalog.baseline['orphanCount']}',
  );
}

String _git(String command, String argument) {
  final result = Process.runSync('git', [command, argument]);
  if (result.exitCode != 0) throw StateError(result.stderr.toString());
  return result.stdout.toString().trim();
}
