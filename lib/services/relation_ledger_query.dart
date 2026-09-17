import '../domain/relations/relation_record.dart';
import 'relation_annotation_store.dart';

abstract final class RelationLedgerQuery {
  static List<RelationRecord> search(
    Iterable<RelationRecord> records,
    String keyword, {
    RelationAnnotationStore? store,
    String? caseId,
  }) {
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) return records.toList();
    return [
      for (final record in records)
        if (_searchText(record, store, caseId).contains(query)) record,
    ];
  }

  static List<RelationRecord> filter(
    Iterable<RelationRecord> records, {
    RelationKind? kind,
    int? position,
    String? category,
    String keyword = '',
    RelationAnnotationStore? store,
    String? caseId,
  }) {
    final candidates = search(
      records,
      keyword,
      store: store,
      caseId: caseId,
    );
    return [
      for (final record in candidates)
        if ((kind == null || record.kind == kind) &&
            (category == null || record.category == category) &&
            (position == null || _hasPosition(record, position)))
          record,
    ];
  }

  static bool _hasPosition(RelationRecord record, int position) => record
      .participants
      .any((endpoint) => endpoint.semanticId.endsWith(':$position'));

  static String _searchText(
    RelationRecord record,
    RelationAnnotationStore? store,
    String? caseId,
  ) {
    final annotation = store == null || caseId == null
        ? null
        : store.annotationFor(caseId: caseId, recordId: record.id);
    return [
      record.title,
      record.subtitle,
      record.category,
      record.ruleId,
      record.knowledgeRuleId,
      record.ruleVariantId,
      ...record.participants.map((e) => e.semanticId),
      ...record.labels,
      ...record.keywords,
      ...record.evidence,
      record.note,
      annotation?.note,
      ...(annotation?.labels ?? const <String>[]),
    ].whereType<String>().join(' ').toLowerCase();
  }
}
