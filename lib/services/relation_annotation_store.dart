class RelationAnnotation {
  const RelationAnnotation({required this.note, this.labels = const []});

  final String note;
  final List<String> labels;
}

class RelationAnnotationStore {
  RelationAnnotationStore({this.onChanged});

  final void Function()? onChanged;
  final Map<String, Map<String, RelationAnnotation>> _items = {};

  void upsert({
    required String caseId,
    required String recordId,
    String note = '',
    List<String> labels = const [],
  }) {
    _items.putIfAbsent(caseId, () => {})[recordId] = RelationAnnotation(
      note: note,
      labels: List.unmodifiable(labels),
    );
    onChanged?.call();
  }

  RelationAnnotation? annotationFor({
    required String caseId,
    required String recordId,
  }) => _items[caseId]?[recordId];

  Map<String, Object?> toJson() => {
    'items': [
      for (final caseEntry in _items.entries)
        for (final entry in caseEntry.value.entries)
          {
            'caseId': caseEntry.key,
            'recordId': entry.key,
            'note': entry.value.note,
            'labels': entry.value.labels,
          },
    ],
  };

  factory RelationAnnotationStore.fromJson(Map<String, Object?> json) {
    final store = RelationAnnotationStore();
    for (final raw in json['items'] as List<Object?>? ?? const []) {
      final item = (raw as Map).cast<String, Object?>();
      store.upsert(
        caseId: item['caseId'] as String,
        recordId: item['recordId'] as String,
        note: item['note'] as String? ?? '',
        labels: [
          for (final label in item['labels'] as List<Object?>? ?? const [])
            label as String,
        ],
      );
    }
    return store;
  }
}
