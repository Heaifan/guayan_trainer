/// Stable Relation Identity · 重算绑定测试（Test C / D / E + 计算器基础）。
///
/// Test C：写笔记 → 销毁实例 → 重算 → 新实例同 key → 笔记自动挂回。
/// Test D：两条相似但语义不同的关系，笔记不得互相串绑。
/// Test E：关系列表顺序变化，不影响 key 与笔记绑定。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_note_store.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

import 'domain_test_utils.dart';

void main() {
  group('计算器基础', () {
    test('同输入重复计算得到完全一致的 RelationKey 序列（Test A 实例级）', () {
      final c = buildDemoCase();
      final round1 = calculateRelations(c);
      final round2 = calculateRelations(c);
      expect(
        round1.map((r) => r.key.canonical).toList(),
        round2.map((r) => r.key.canonical).toList(),
      );
      expect(round1, hasLength(2));
    });

    test('演示卦例产出 动变(三爻) 与 六冲(三爻↔上爻)', () {
      final instances = calculateRelations(buildDemoCase());
      final types = instances.map((r) => r.type).toSet();
      expect(types, contains(RelationType.dongBian));
      expect(types, contains(RelationType.liuChong));
      final dongBian =
          instances.firstWhere((r) => r.type == RelationType.dongBian);
      expect(dongBian.source.semanticId, 'original-3');
      expect(dongBian.target.semanticId, 'changed-3');
    });
  });

  group('Test C · 重算恢复笔记', () {
    test('写笔记 → 销毁实例 → 重算 → 新实例同 key → 笔记自动挂回', () {
      final c = buildDemoCase();
      final store = RelationNoteStore();

      // Round 1：生成关系实例 A，并给「动变」写笔记。
      final round1 = calculateRelations(c);
      final instanceA =
          round1.firstWhere((r) => r.type == RelationType.dongBian);
      store.upsertNote(
        caseId: c.id,
        relationKey: instanceA.key,
        content: '印证成绩得生',
        now: DateTime.utc(2026, 8, 27, 21, 0),
      );
      expect(store.count, 1);

      // 销毁 Round 1 全部实例（模拟重新打开 / 重新排盘）。
      // Round 2：从原始 Case 状态重新计算，生成全新实例 B。
      final round2 = calculateRelations(c);
      final instanceB =
          round2.firstWhere((r) => r.type == RelationType.dongBian);

      // A != B 运行时对象，但 stableKey 完全一致。
      expect(identical(instanceA, instanceB), isFalse);
      expect(instanceA.key, instanceB.key);

      // 原 RelationNote 成功恢复并绑定到 B。
      final note = store.noteFor(caseId: c.id, relationKey: instanceB.key);
      expect(note, isNotNull);
      expect(note!.content, '印证成绩得生');
    });
  });

  group('Test D · 不能串笔记', () {
    test('两条相似关系的笔记各自回到各自的关系', () {
      final c = buildDemoCase();
      final store = RelationNoteStore();
      final round1 = calculateRelations(c);

      final a = round1.firstWhere((r) => r.type == RelationType.dongBian);
      final b = round1.firstWhere((r) => r.type == RelationType.liuChong);
      expect(a.key, isNot(b.key), reason: '两条关系 key 必须不同');

      store.upsertNote(caseId: c.id, relationKey: a.key, content: 'note-A');
      store.upsertNote(caseId: c.id, relationKey: b.key, content: 'note-B');

      final round2 = calculateRelations(c);
      final a2 = round2.firstWhere((r) => r.key == a.key);
      final b2 = round2.firstWhere((r) => r.key == b.key);

      expect(store.noteFor(caseId: c.id, relationKey: a2.key)!.content, 'note-A');
      expect(store.noteFor(caseId: c.id, relationKey: b2.key)!.content, 'note-B');
    });

    test('相同关系 key 在不同卦例中笔记互不干扰（caseId 作用域）', () {
      final case1 = buildDemoCase(id: 'case-1');
      final case2 = buildDemoCase(id: 'case-2');
      final store = RelationNoteStore();
      final key1 = calculateRelations(case1).first.key;
      final key2 = calculateRelations(case2).first.key;
      expect(key1, key2, reason: '内容相同的卦例产生相同的关系 key');

      store.upsertNote(caseId: 'case-1', relationKey: key1, content: '甲卦笔记');
      store.upsertNote(caseId: 'case-2', relationKey: key2, content: '乙卦笔记');

      expect(
        store.noteFor(caseId: 'case-1', relationKey: key1)!.content,
        '甲卦笔记',
      );
      expect(
        store.noteFor(caseId: 'case-2', relationKey: key2)!.content,
        '乙卦笔记',
      );
    });
  });

  group('Test E · 序列变化不影响', () {
    test('实例列表顺序反转后，key 与笔记绑定不变', () {
      final c = buildDemoCase();
      final store = RelationNoteStore();
      final instances = calculateRelations(c);

      for (final r in instances) {
        store.upsertNote(
          caseId: c.id,
          relationKey: r.key,
          content: 'n:${r.key.type.machineName}',
        );
      }

      // 模拟输出顺序变化：[B, A]。
      final reversed = instances.reversed.toList();
      expect(
        reversed.map((r) => r.key.canonical).toList(),
        isNot(instances.map((r) => r.key.canonical).toList()),
      );

      for (final r in reversed) {
        final note = store.noteFor(caseId: c.id, relationKey: r.key);
        expect(note, isNotNull);
        expect(note!.content, 'n:${r.key.type.machineName}');
      }
      expect(store.count, instances.length);
    });
  });
}
