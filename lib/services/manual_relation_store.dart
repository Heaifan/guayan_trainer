import '../domain/relation_endpoint.dart';
import '../domain/relations/relation_record.dart';

class ManualRelationStore {
  ManualRelationStore({this.onChanged});

  final void Function()? onChanged;
  final Map<String, List<RelationRecord>> _records = {};

  RelationRecord create({
    required String caseId,
    required String id,
    required RelationEndpoint from,
    required RelationEndpoint to,
    required String title,
    String? note,
  }) {
    final record = RelationRecord.userRelation(
      id: id, fromRef: from, toRef: to, title: title, note: note,
    );
    _records.putIfAbsent(caseId, () => []).add(record);
    onChanged?.call();
    return record;
  }

  List<RelationRecord> recordsFor(String caseId) =>
      List.unmodifiable(_records[caseId] ?? const []);

  Map<String, Object?> toJson() => {
    'records': [
      for (final entry in _records.entries)
        for (final record in entry.value)
          {
            'caseId': entry.key,
            'id': record.id,
            'from': record.fromRef?.toJson(),
            'to': record.toRef?.toJson(),
            'title': record.title,
            'note': record.note,
          },
    ],
  };

  factory ManualRelationStore.fromJson(Map<String, Object?> json) {
    final store = ManualRelationStore();
    for (final raw in json['records'] as List<Object?>? ?? const []) {
      final item = (raw as Map).cast<String, Object?>();
      store.create(
        caseId: item['caseId'] as String,
        id: item['id'] as String,
        from: RelationEndpoint.fromJson(
          (item['from'] as Map).cast<String, Object?>(),
        ),
        to: RelationEndpoint.fromJson(
          (item['to'] as Map).cast<String, Object?>(),
        ),
        title: item['title'] as String,
        note: item['note'] as String?,
      );
    }
    return store;
  }
}
