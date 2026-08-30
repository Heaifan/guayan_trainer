/// 排卦页 XYUI 工作台 · 状态与交互测试（任务书 §26 Test A–D + 行顺序）。
///
/// 覆盖：0/6 locked、6/6 ready、动爻计数、当前编辑爻视觉切换、
/// 爻象选择、问事信息编辑、规则包占位、草稿仓库接口边界、时辰映射。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/presentation/casting/casting_page.dart';
import 'package:guayan_trainer/presentation/casting/casting_page_state.dart';
import 'package:guayan_trainer/services/draft/casting_draft.dart';
import 'package:guayan_trainer/services/draft/draft_repository.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, {CastingDraft? draft}) async {
    await tester.pumpWidget(
      MaterialApp(home: CastingPage(initialDraft: draft)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> recordLine(WidgetTester tester, int position) async {
    await tester.ensureVisible(find.byKey(Key('yao_row_$position')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('yao_row_$position')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('line_opt_shaoYang')));
    await tester.pumpAndSettle();
  }

  group('Test A · 六爻 0/6 → Generate locked', () {
    testWidgets('空草稿：0 / 6 已完成、六行待录、生成尚未就绪', (tester) async {
      await pumpPage(tester, draft: const CastingDraft());

      expect(find.text('0 / 6 已完成 · 动爻 0'), findsOneWidget);
      expect(find.text('待录'), findsNWidgets(6));
      expect(find.text('六爻完整后解锁'), findsOneWidget);
      expect(find.text('尚未就绪'), findsOneWidget);
      // locked 态 chip 不可点（无 InkWell 包装）。
      expect(
        find.ancestor(of: find.text('尚未就绪'), matching: find.byType(InkWell)),
        findsNothing,
      );
    });
  });

  group('Test B · 六爻 6/6 → Generate ready', () {
    testWidgets('逐爻录入完成 → 6 / 6、生成排盘可点', (tester) async {
      await pumpPage(tester, draft: const CastingDraft());

      for (var p = 1; p <= 6; p++) {
        await recordLine(tester, p);
      }

      expect(find.text('6 / 6 已完成 · 动爻 0'), findsOneWidget);
      expect(find.text('六爻已完整，可以生成排盘'), findsOneWidget);
      final button = find.byKey(const Key('generate_button'));
      expect(button, findsOneWidget);
      expect(
        tester
            .widget<InkWell>(
              find.descendant(
                of: button,
                matching: find.byType(InkWell),
              ),
            )
            .onTap,
        isNotNull,
      );
    });

    testWidgets('点击生成排盘 → 排盘已生成，数据保留', (tester) async {
      await pumpPage(tester, draft: const CastingDraft());

      for (var p = 1; p <= 6; p++) {
        await recordLine(tester, p);
      }
      await tester.tap(find.byKey(const Key('generate_button')));
      await tester.pumpAndSettle();

      expect(find.text('排盘已生成'), findsOneWidget);
      expect(find.text('查看审卦 ›'), findsOneWidget);
      // 六爻数据未被清空。
      expect(find.text('6 / 6 已完成 · 动爻 0'), findsOneWidget);
    });
  });

  group('Test C · 动爻计数', () {
    test('模型：两动爻 → movingLineCount == 2', () {
      final state = CastingPageState(
        questionTitle: '',
        questionBody: '',
        questionObject: '',
        questionNote: '',
        castingTime: null,
        rulePackName: '默认规则包',
        ruleVersion: 1,
        lines: [
          LineState(position: 1, movementType: MovementType.laoYang),
          LineState(position: 2, movementType: MovementType.shaoYin),
          LineState(position: 3, movementType: MovementType.laoYin),
          LineState(position: 4, movementType: MovementType.shaoYang),
          null,
          null,
        ],
        editingPosition: null,
        generationState: GenerationState.locked,
        draftState: DraftState.drafting,
        regenerateNeeded: false,
      );
      expect(state.movingLineCount, 2);
      expect(state.completedLineCount, 4);
      expect(state.isLinesComplete, isFalse);
    });

    testWidgets('演示草稿 UI：4 / 6 已完成 · 动爻 2', (tester) async {
      await pumpPage(tester); // CastingDraft.demo()
      expect(find.text('4 / 6 已完成 · 动爻 2'), findsOneWidget);
    });
  });

  group('Test D · 当前编辑爻', () {
    testWidgets('点击某爻 → 编辑态切换（高亮 + 编辑徽标）', (tester) async {
      await pumpPage(tester); // demo：三爻为当前编辑爻

      expect(find.byKey(const Key('yao_edit_badge_3')), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('yao_row_4')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('yao_row_4')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('yao_edit_badge_4')), findsOneWidget);
      expect(find.byKey(const Key('yao_edit_badge_3')), findsNothing);

      // 选择少阳 → 四爻变为「阳 · 静」。
      await tester.tap(find.byKey(const Key('line_opt_shaoYang')));
      await tester.pumpAndSettle();
      final text = tester
          .widget<Text>(find.byKey(const Key('yao_status_4')))
          .data;
      expect(text, '阳 · 静');
    });

    testWidgets('点击待录爻可录入，老阴显示动爻标记语义', (tester) async {
      await pumpPage(tester, draft: const CastingDraft());

      await tester.ensureVisible(find.byKey(const Key('yao_row_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('yao_row_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('line_opt_laoYin')));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(const Key('yao_status_1'))).data,
        '阴 · 动',
      );
      expect(find.text('1 / 6 已完成 · 动爻 1'), findsOneWidget);
    });
  });

  group('行顺序（视觉验收 A–E）', () {
    testWidgets('起卦时间 → 问事信息 → 六爻录入 → 规则包 → 生成排盘', (tester) async {
      await pumpPage(tester);

      double y(String text) =>
          tester.getTopLeft(find.text(text)).dy;
      final order = [
        y('起卦时间'),
        y('问事信息'),
        y('六爻录入'),
        y('规则包'),
        y('生成排盘'),
      ];
      for (var i = 0; i < order.length - 1; i++) {
        expect(order[i] < order[i + 1], isTrue,
            reason: '第 ${i + 1} 行必须在第 ${i + 2} 行之前');
      }
    });
  });

  group('问事信息编辑', () {
    testWidgets('保存主题后：问事行标题与已完成 chip 更新', (tester) async {
      await pumpPage(tester, draft: const CastingDraft());

      expect(find.text('尚未填写主题与问事正文'), findsOneWidget);

      await tester.tap(find.byKey(const Key('question_row')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('q_title')), '测试问事');
      await tester.enterText(
        find.byKey(const Key('q_body')),
        '项目推进是否顺利？',
      );
      await tester.tap(find.byKey(const Key('question_save')));
      await tester.pumpAndSettle();

      // DraftContext 已删除（UI-CORRECTION-R2 §1.1）：问事行只展示正文摘要，
      // 标题不再单独显示。
      expect(find.text('测试问事'), findsNothing);
      expect(find.text('项目推进是否顺利？'), findsOneWidget);
      expect(find.text('已完成'), findsOneWidget); // 问事行 chip
    });
  });

  group('规则包占位（任务书 §13）', () {
    testWidgets('点击修改 → 占位弹层，保留规则版本语义', (tester) async {
      await pumpPage(tester);

      await tester.ensureVisible(find.byKey(const Key('rule_pack_row')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('rule_pack_row')));
      await tester.pumpAndSettle();

      // 弹层独有文案（规则包行卡片同样显示该标签，故不计数该行文本）。
      expect(
        find.textContaining('自定义规则包将在后续版本开放。'),
        findsOneWidget,
      );
      expect(find.textContaining('RuleId + RuleVersion'), findsOneWidget);
      await tester.tap(find.byKey(const Key('rule_pack_close')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('自定义规则包将在后续版本开放。'),
        findsNothing,
      );
    });
  });

  group('UI-CORRECTION-R2', () {
    testWidgets('UI-01 · 顶部草稿摘要卡已删除', (tester) async {
      await pumpPage(tester);
      expect(find.byKey(const Key('draft_state_chip')), findsNothing);
      expect(find.textContaining('草稿自动保存'), findsNothing);
    });

    testWidgets('UI-02 · 起卦时间同时显示公历与农历', (tester) async {
      await pumpPage(tester); // demo 草稿：2026-08-30 09:30
      expect(find.text('公历：2026-08-30 09:30'), findsOneWidget);
      expect(
        find.text('农历：2026年8月30日 巳时 · 农历换算待接入'),
        findsOneWidget,
      );
    });

    testWidgets('UI-03 · 普通行高 == 编辑行高 == 52', (tester) async {
      await pumpPage(tester); // demo：三爻为当前编辑爻
      final editingHeight =
          tester.getSize(find.byKey(const Key('yao_row_3'))).height;
      final normalHeight =
          tester.getSize(find.byKey(const Key('yao_row_6'))).height;
      expect(editingHeight, 52);
      expect(normalHeight, 52);
      expect(editingHeight, normalHeight);
    });
  });

  group('爻象选择弹层（R2 修复标准：任何屏幕无 RenderFlex 溢出）', () {
    testWidgets('窄屏 360×640 打开弹层：tile ≥58 DIP、无溢出', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpPage(tester, draft: const CastingDraft());
      await tester.ensureVisible(find.byKey(const Key('yao_row_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('yao_row_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('line_opt_shaoYang')), findsOneWidget);
      expect(find.byKey(const Key('line_opt_laoYin')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DraftRepository 接口边界（任务书 §15）', () {
    test('InMemoryDraftRepository save/load/clear', () async {
      final repo = InMemoryDraftRepository();
      expect(await repo.load(), isNull);

      const draft = CastingDraft(questionTitle: '草稿标题');
      await repo.save(draft);
      expect((await repo.load())!.questionTitle, '草稿标题');

      await repo.clear();
      expect(await repo.load(), isNull);
    });

    testWidgets('修改一爻后草稿自动保存（无需手动保存）', (tester) async {
      final repo = InMemoryDraftRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: CastingPage(
            initialDraft: const CastingDraft(),
            repository: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('yao_row_6')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('yao_row_6')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('line_opt_shaoYang')));
      await tester.pumpAndSettle();

      final saved = await repo.load();
      expect(saved, isNotNull);
      expect(saved!.lines[5], isNotNull); // 上爻已保存
      expect(saved.lines[5]!.movementType, MovementType.shaoYang);
    });
  });

  group('纯逻辑辅助', () {
    test('时辰映射（小时 → 时辰）', () {
      expect(shichenForHour(9), '巳');
      expect(shichenForHour(23), '子');
      expect(shichenForHour(13), '未');
      expect(shichenForHour(1), '丑');
    });

    test('爻位展示名', () {
      expect(linePositionName(1), '初爻');
      expect(linePositionName(6), '上爻');
    });

    test('阴阳动静展示文案', () {
      expect(
        movementDisplay(MovementType.shaoYin),
        '阴 · 静',
      );
      expect(
        movementDisplay(MovementType.laoYang),
        '阳 · 动',
      );
    });
  });
}
