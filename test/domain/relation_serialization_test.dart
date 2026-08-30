/// T8 · 序列化 → 反序列化 → 重算 → 重新绑定 全链测试。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_note_store.dart';

import 'domain_test_utils.dart';

void main() {
  group('T8 · 序列化 / 重载链', () {
    test('Case JSON round-trip 后重算，RelationKey 序列不变', () {
      final original = buildDemoCase();
      final round1 = calculateRelations(original);

      final restored = HexagramCase.fromJson(original.toJson());
      final round2 = calculateRelations(restored);

      expect(restored.id, original.id);
      expect(
        round1.map((r) => r.key.canonical).toList(),
        round2.map((r) => r.key.canonical).toList(),
      );
    });

    test('Note 存储 JSON round-trip 后，重算实例仍能重新绑定', () {
      final c = buildDemoCase();
      final store = RelationNoteStore();
      final target = calculateRelations(c).first;
      store.upsertNote(
        caseId: c.id,
        relationKey: target.key,
        content: '印证成绩得生',
        now: DateTime.utc(2026, 8, 27, 21, 0),
      );

      // 持久化 → 重启（反序列化新存储）。
      final restored = RelationNoteStore.fromJson(store.toJson());
      expect(restored.count, 1);

      // 重算得到全新实例，笔记凭 key 挂回。
      final round2 = calculateRelations(c);
      final fresh = round2.firstWhere((r) => r.key == target.key);
      expect(
        restored.noteFor(caseId: c.id, relationKey: fresh.key)!.content,
        '印证成绩得生',
      );
    });

    test('编辑笔记（upsert 更新）不破坏绑定', () {
      final c = buildDemoCase();
      final store = RelationNoteStore();
      final key = calculateRelations(c).first.key;

      store.upsertNote(
        caseId: c.id,
        relationKey: key,
        content: '初稿',
        now: DateTime.utc(2026, 8, 27, 21, 0),
      );
      store.upsertNote(
        caseId: c.id,
        relationKey: key,
        content: '修改后',
        now: DateTime.utc(2026, 8, 27, 22, 0),
      );

      final round2 = calculateRelations(c);
      final fresh = round2.firstWhere((r) => r.key == key);
      final note = store.noteFor(caseId: c.id, relationKey: fresh.key);
      expect(note!.content, '修改后');
      expect(note.createdAt.isBefore(note.updatedAt), isTrue);
      expect(store.count, 1);
    });
  });
}
