/// 关系笔记绑定存储：纯内存 + JSON 导入导出，保持 storage-agnostic。
///
/// 绑定语义：(caseId, RelationKey) → RelationNote。
/// 关系实例每次重算都是新对象，笔记通过 RelationKey 自动挂回，
/// 不依赖任何实例临时 id 与列表顺序。
///
/// 持久化实现（SQLite/Drift/JSON 文件）由后续阶段正式决定，
/// 本类只证明「序列化 → 反序列化 → 重算 → 重新绑定」链条成立。
library;

import 'relation_key.dart';
import 'relation_note.dart';

class RelationNoteStore {
  RelationNoteStore();

  final Map<String, Map<RelationKey, RelationNote>> _byCase = {};

  /// 写入/更新某卦例某条关系的笔记（同一关系一条，upsert 语义）。
  void upsertNote({
    required String caseId,
    required RelationKey relationKey,
    required String content,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();
    final byKey = _byCase.putIfAbsent(caseId, () => {});
    final existing = byKey[relationKey];
    byKey[relationKey] = existing == null
        ? RelationNote(
            caseId: caseId,
            relationKey: relationKey,
            content: content,
            createdAt: t,
            updatedAt: t,
          )
        : existing.copyWith(content: content, updatedAt: t);
  }

  /// 按 (caseId, RelationKey) 取回笔记；无则返回 null。
  RelationNote? noteFor({
    required String caseId,
    required RelationKey relationKey,
  }) =>
      _byCase[caseId]?[relationKey];

  /// 某卦例的全部笔记，按创建时间升序。
  List<RelationNote> notesForCase(String caseId) {
    final notes = _byCase[caseId]?.values.toList() ?? const <RelationNote>[];
    notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return notes;
  }

  /// 当前笔记总数（便于测试断言）。
  int get count =>
      _byCase.values.fold(0, (total, byKey) => total + byKey.length);

  Map<String, Object?> toJson() => {
        'notes': _byCase.values
            .expand((byKey) => byKey.values)
            .map((n) => n.toJson())
            .toList(),
      };

  factory RelationNoteStore.fromJson(Map<String, Object?> json) {
    final store = RelationNoteStore();
    for (final e in json['notes'] as List<Object?>? ?? const []) {
      final note = RelationNote.fromJson(e as Map<String, Object?>);
      store._byCase.putIfAbsent(note.caseId, () => {})[note.relationKey] =
          note;
    }
    return store;
  }
}
