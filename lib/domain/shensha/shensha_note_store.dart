/// 卦例级神煞备注存储。
library;

class ShenShaNoteStore {
  ShenShaNoteStore({this.onChanged});

  final void Function(Map<String, Object?> json)? onChanged;

  final Map<String, Map<String, String>> _notes = {};

  String? noteFor({required String caseId, required String shenShaId}) =>
      _notes[caseId]?[shenShaId];

  void save({
    required String caseId,
    required String shenShaId,
    required String content,
  }) {
    final text = content.trim();
    final byShenSha = _notes.putIfAbsent(caseId, () => {});
    if (text.isEmpty) {
      byShenSha.remove(shenShaId);
      if (byShenSha.isEmpty) _notes.remove(caseId);
      onChanged?.call(toJson());
      return;
    }
    byShenSha[shenShaId] = text;
    onChanged?.call(toJson());
  }

  Map<String, Object?> toJson() => {
    'notes': [
      for (final caseEntry in _notes.entries)
        for (final noteEntry in caseEntry.value.entries)
          {
            'caseId': caseEntry.key,
            'shenShaId': noteEntry.key,
            'content': noteEntry.value,
          },
    ],
  };

  factory ShenShaNoteStore.fromJson(Map<String, Object?> json) {
    final store = ShenShaNoteStore();
    for (final raw in json['notes'] as List<Object?>? ?? const []) {
      final item = raw as Map<String, Object?>;
      store.save(
        caseId: item['caseId'] as String,
        shenShaId: item['shenShaId'] as String,
        content: item['content'] as String,
      );
    }
    return store;
  }
}
