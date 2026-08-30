/// T2 · Rule Version Replay Contract：旧卦例重算必须复现历史 RuleVersion，
/// 系统规则升级不能让历史卦例失忆。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_note_store.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';

import 'domain_test_utils.dart';

void main() {
  group('T2 · Rule Version Replay', () {
    test('Case 保存 v1 上下文 → 系统升级 v2 → reload 旧 Case → replay 仍 v1 → 笔记恢复', () {
      // 历史卦例：计算时 sys.liu_chong 为 v1。
      final oldCase = buildDemoCase(
        id: 'case-v1',
        ruleContext: RuleExecutionContext(const [
          RuleVersionRef(SystemRuleIds.liuChong, 1),
        ]),
      );
      final store = RelationNoteStore();
      final round1 = calculateRelations(oldCase);
      final chong1 = round1.firstWhere((r) => r.type == RelationType.liuChong);
      expect(chong1.key.canonical, contains('v1'));
      store.upsertNote(
        caseId: oldCase.id,
        relationKey: chong1.key,
        content: '卯酉冲 · 印证成绩得生',
        now: DateTime.utc(2026, 8, 27, 21, 0),
      );

      // 持久化旧卦例（含 v1 规则上下文）。
      final savedCaseJson = oldCase.toJson();
      final savedNotesJson = store.toJson();

      // 模拟系统升级：新卦例使用 v2。
      final newCase = buildDemoCase(
        id: 'case-v2',
        ruleContext: RuleExecutionContext(const [
          RuleVersionRef(SystemRuleIds.liuChong, 2),
        ]),
      );
      final roundNew = calculateRelations(newCase);
      final chongNew =
          roundNew.firstWhere((r) => r.type == RelationType.liuChong);
      expect(chongNew.key.canonical, contains('v2'));
      expect(chongNew.key, isNot(chong1.key), reason: 'v2 与 v1 的 key 必须不同');

      // 重新打开旧卦例：上下文保留 v1，replay 复现 v1 key。
      final reloaded = HexagramCase.fromJson(savedCaseJson);
      expect(
        reloaded.ruleContext.versionFor(SystemRuleIds.liuChong),
        1,
        reason: 'reload 后必须保留 v1 规则上下文',
      );
      final round2 = calculateRelations(reloaded);
      final chong2 =
          round2.firstWhere((r) => r.type == RelationType.liuChong);
      expect(chong2.key, chong1.key, reason: 'replay 后 RelationKey 必须仍是 v1');

      // 旧笔记凭 v1 key 恢复。
      final restored = RelationNoteStore.fromJson(savedNotesJson);
      final note = restored.noteFor(caseId: 'case-v1', relationKey: chong2.key);
      expect(note, isNotNull);
      expect(note!.content, '卯酉冲 · 印证成绩得生');
    });

    test('无规则上下文的 Case 回退默认版本 v1（向后兼容）', () {
      final c = buildDemoCase();
      expect(c.ruleContext, const RuleExecutionContext.empty());
      final chong =
          calculateRelations(c).firstWhere((r) => r.type == RelationType.liuChong);
      expect(chong.key.canonical, contains('|v1|'));
    });

    test('规则上下文可 JSON 持久化且 round-trip 保真', () {
      final ctx = RuleExecutionContext(const [
        RuleVersionRef(SystemRuleIds.liuChong, 1),
        RuleVersionRef(SystemRuleIds.dongBian, 2),
      ]);
      final restored = RuleExecutionContext.fromJson(ctx.toJson());
      expect(restored, ctx);
      expect(restored.versionFor(SystemRuleIds.liuChong), 1);
      expect(restored.versionFor(SystemRuleIds.dongBian), 2);
      expect(restored.versionFor('sys.unknown'), isNull);
    });

    test('规则上下文拒绝重复 ruleId 与非法版本', () {
      expect(
        () => RuleExecutionContext(const [
          RuleVersionRef('sys.a', 1),
          RuleVersionRef('sys.a', 2),
        ]),
        throwsArgumentError,
      );
      expect(
        () => RuleExecutionContext(const [RuleVersionRef('sys.a', 0)]),
        throwsArgumentError,
      );
    });
  });
}
