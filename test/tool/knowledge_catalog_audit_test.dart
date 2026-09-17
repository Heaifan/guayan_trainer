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

  test('JSON and Markdown expose the same primary category and tags', () {
    final catalog = buildSystemKnowledgeCatalogAudit(
      branch: 'feat/guayan-2.0',
      head: '0478bbd',
      generationTime: '2026-09-17T00:00:00Z',
    );
    final json = jsonDecode(renderAuditJson(catalog)) as Map<String, dynamic>;
    expect(json['categories'], hasLength(12));
    final jsonRule =
        (json['rules'] as List<dynamic>).firstWhere(
              (row) => row['knowledgeRuleId'] == 'knowledge.xun_kong',
            )
            as Map<String, dynamic>;

    expect(jsonRule['primaryCategory'], {
      'id': 'knowledge.category.state',
      'displayName': '状态体系',
    });
    expect(jsonRule['tags'], ['旬空', '空墓', '状态']);
    expect(catalog.rows.first.primaryCategoryId, 'knowledge.category.state');
    expect(catalog.rows.first.tags, ['旬空', '空墓', '状态']);
    expect(renderAuditMarkdown(catalog), contains('Primary Category'));
    expect(renderAuditMarkdown(catalog), contains('knowledge.category.state'));
    expect(renderAuditMarkdown(catalog), contains('状态体系'));
    expect(renderAuditMarkdown(catalog), contains('旬空, 空墓, 状态'));
  });
}
