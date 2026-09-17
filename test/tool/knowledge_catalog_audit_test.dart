import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import '../../tool/knowledge_catalog_audit.dart';

void main() {
  test(
    'audit catalog exports every real SYSTEM execution rule exactly once',
    () {
      final catalog = buildSystemKnowledgeCatalogAudit(
        branch: 'feat/guayan-2.0',
        head: '0478bbd',
        generationTime: '2026-09-17T00:00:00Z',
      );

      expect(catalog.rows, hasLength(60));
      expect(
        catalog.rows.map((row) => row.executionRuleId).toSet(),
        hasLength(60),
      );
      expect(catalog.baseline['orphanCount'], 0);
      expect(
        catalog.rows.every((row) => row.runtimeSystem == 'SYSTEM'),
        isTrue,
      );
    },
  );

  test('JSON and Markdown are rendered from the same 60-row source', () {
    final catalog = buildSystemKnowledgeCatalogAudit(
      branch: 'feat/guayan-2.0',
      head: '0478bbd',
      generationTime: '2026-09-17T00:00:00Z',
    );
    final jsonRows =
        (jsonDecode(renderAuditJson(catalog)) as Map<String, dynamic>)['rules']
            as List<dynamic>;
    final markdown = renderAuditMarkdown(catalog);

    expect(jsonRows, hasLength(catalog.rows.length));
    for (final row in catalog.rows) {
      expect(markdown, contains(row.executionRuleId));
    }
  });
}
