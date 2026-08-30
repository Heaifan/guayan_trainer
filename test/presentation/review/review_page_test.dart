/// 审卦页 XYUI 工作台测试（R1 §22 A–H + UI-CORRECTION-R2 UI-04~08）。
///
/// 覆盖：神煞网格（A/UI-04）、四柱（B）、六行顺序（C）、
/// 阴阳爻象（D）、动爻矢量标记（E/UI-06）、世应（F）、
/// 焦点关系来自现有 RelationInstance（G）、最终卦盘标题、爻槽统一 24×6（UI-05）、
/// 文本不压爻（UI-07）、变卦爻槽+变卦世应同显（UI-08）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/presentation/review/review_case_adapter.dart';
import 'package:guayan_trainer/presentation/review/review_demo_data.dart';
import 'package:guayan_trainer/presentation/review/review_page.dart';
import 'package:guayan_trainer/presentation/review/review_page_state.dart';
import 'package:guayan_trainer/presentation/shared/moving_marker.dart';
import 'package:guayan_trainer/presentation/shared/yao_glyph.dart';

/// 真实卦例（无传统档案）：两组合（辰酉 / 午未）、一老阴动爻（三爻）。
HexagramCase realCase() => HexagramCase(
      id: 'real-1',
      question: '项目是否顺利？',
      lines: [
        LineState(position: 6, movementType: MovementType.shaoYin, branch: '未'),
        LineState(position: 5, movementType: MovementType.shaoYang, branch: '酉'),
        LineState(position: 4, movementType: MovementType.shaoYin, branch: '亥'),
        LineState(position: 3, movementType: MovementType.laoYin, branch: '申'),
        LineState(position: 2, movementType: MovementType.shaoYang, branch: '午'),
        LineState(position: 1, movementType: MovementType.shaoYin, branch: '辰'),
      ],
      createdAt: DateTime(2026, 1, 1, 9, 30),
      ruleContext: RuleExecutionContext(const [
        RuleVersionRef('sys.default', 3),
      ]),
    );

void main() {
  Future<void> pumpDemo(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReviewPage()));
    await tester.pumpAndSettle();
  }

  Future<void> pumpReal(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ReviewPage(initialCase: realCase())),
    );
    await tester.pumpAndSettle();
  }

  group('Test A · 神煞网格', () {
    testWidgets('全部 16 项可见、无溢出', (tester) async {
      await pumpDemo(tester);

      for (final label in [
        '卦身：申', '香闺：寅卯', '床帐：子亥', '驿马：寅',
        '桃花：酉', '华盖：辰', '贵人：酉亥', '天喜：酉',
        '天医：未', '文昌：申', '劫煞：巳', '灾煞：午',
        '金舆：未', '亡神：亥', '将星：子', '羊刃：午',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('UI-04 · 首屏 4 列：前 4 项同行、第 5 项换行', (tester) async {
      await pumpDemo(tester);

      final row1 = [
        tester.getTopLeft(find.byKey(const Key('shensha_卦身'))).dy,
        tester.getTopLeft(find.byKey(const Key('shensha_香闺'))).dy,
        tester.getTopLeft(find.byKey(const Key('shensha_床帐'))).dy,
        tester.getTopLeft(find.byKey(const Key('shensha_驿马'))).dy,
      ];
      for (final dy in row1) {
        expect(dy, row1.first);
      }
      final row2dy =
          tester.getTopLeft(find.byKey(const Key('shensha_桃花'))).dy;
      expect(row2dy > row1.first, isTrue);
    });

    testWidgets('真实卦例无神煞数据 → 空态提示（不伪造）', (tester) async {
      await pumpReal(tester);
      expect(find.text('暂无神煞数据（排盘引擎接入后展示）'), findsOneWidget);
    });
  });

  group('Test B · 四柱', () {
    testWidgets('年 月 日 时 旬空 完整且顺序固定', (tester) async {
      await pumpDemo(tester);

      for (final text in ['丙午年', '丙申月', '丙子日', '丁酉时', '(申酉空)']) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      final order = [
        tester.getTopLeft(find.text('丙午年')).dx,
        tester.getTopLeft(find.text('丙申月')).dx,
        tester.getTopLeft(find.text('丙子日')).dx,
        tester.getTopLeft(find.text('丁酉时')).dx,
        tester.getTopLeft(find.text('(申酉空)')).dx,
      ];
      for (var i = 0; i < order.length - 1; i++) {
        expect(order[i] < order[i + 1], isTrue, reason: '第 $i 列顺序错误');
      }
    });
  });

  group('Test C · 六爻六行', () {
    testWidgets('恰好 6 行：上爻在最上、初爻在最下', (tester) async {
      await pumpDemo(tester);

      for (var p = 1; p <= 6; p++) {
        expect(find.byKey(Key('review_line_$p')), findsOneWidget);
      }
      expect(find.byKey(const Key('review_line_7')), findsNothing);

      final ys = <double>[];
      for (var p = 6; p >= 1; p--) {
        ys.add(tester.getTopLeft(find.byKey(Key('review_line_$p'))).dy);
      }
      for (var i = 0; i < ys.length - 1; i++) {
        expect(ys[i] < ys[i + 1], isTrue,
            reason: '第 $i 行必须在其下一行之上');
      }
    });
  });

  group('Test D · 阴阳爻象', () {
    testWidgets('主卦爻槽：阴/阳/空亡 语义正确', (tester) async {
      await pumpDemo(tester);

      YaoKind kindAt(int p) =>
          tester.widget<YaoGlyph>(find.byKey(Key('yao_glyph_$p'))).kind;
      expect(kindAt(6), YaoKind.yin); // 上爻 阴
      expect(kindAt(5), YaoKind.voidYao); // 五爻 酉 空亡
      expect(kindAt(4), YaoKind.yang); // 四爻 阳
      expect(kindAt(3), YaoKind.voidYao); // 三爻 申 空亡
      expect(kindAt(2), YaoKind.yang); // 二爻 老阳 → 阳
      expect(kindAt(1), YaoKind.yin); // 初爻 阴

      // 行模型阴阳语义。
      expect(
        ReviewLineView(position: 2, movementType: MovementType.laoYang).isYang,
        isTrue,
      );
      expect(
        ReviewLineView(position: 1, movementType: MovementType.shaoYin).isYang,
        isFalse,
      );
    });

    testWidgets('变卦爻槽同样支持空亡（五爻变卦 酉 空亡）', (tester) async {
      await pumpDemo(tester);

      final kind = tester
          .widget<YaoGlyph>(find.byKey(const Key('changed_yao_glyph_5')))
          .kind;
      expect(kind, YaoKind.voidYao);
      final kind3 = tester
          .widget<YaoGlyph>(find.byKey(const Key('changed_yao_glyph_3')))
          .kind;
      expect(kind3, YaoKind.yin); // 官鬼戊午火 不空 → 阴
    });
  });

  group('Test E · 动爻标记', () {
    testWidgets('老阴 ○ / 老阳 × 矢量标记，静爻无', (tester) async {
      await pumpDemo(tester);

      expect(find.byKey(const Key('moving_marker_3')), findsOneWidget); // 老阴
      expect(find.byKey(const Key('moving_marker_2')), findsOneWidget); // 老阳
      for (final p in [1, 4, 5, 6]) {
        expect(find.byKey(Key('moving_marker_$p')), findsNothing);
      }
      final yin = tester
          .widget<MovingMarker>(find.byKey(const Key('moving_marker_3')));
      expect(yin.isYin, isTrue);
      final yang = tester
          .widget<MovingMarker>(find.byKey(const Key('moving_marker_2')));
      expect(yang.isYin, isFalse);
    });
  });

  group('Test F · 世应', () {
    testWidgets('世应贴对应爻行（主卦/变卦侧）', (tester) async {
      await pumpDemo(tester);

      String markerText(String key) =>
          tester.widget<Text>(find.byKey(Key(key))).data!;
      expect(markerText('shi_ying_6'), '应');
      expect(markerText('shi_ying_3'), '世');
      expect(markerText('changed_shi_ying_4'), '应');
      expect(markerText('changed_shi_ying_1'), '世');
      expect(find.text('世'), findsNWidgets(2));
      expect(find.text('应'), findsNWidgets(2));
    });
  });

  group('Test G · 关系焦点', () {
    test('适配器：焦点关系来自 Domain 计算（RelationInstance），非字符串重算', () {
      final state = ReviewCaseAdapter.adapt(realCase());

      expect(state.focusedLine, 3);
      expect(state.focusedRelations, hasLength(1));
      final rel = state.focusedRelations.first;
      expect(rel.type, RelationType.dongBian);
      expect(
        rel.key.canonical,
        'dong_bian|sys.dong_bian|v1|-|original-3->changed-3',
      );
      expect(state.rulePackId, 'sys.default');
      expect(state.ruleVersion, 3);
    });

    test('适配器：演示卦例伏神两列 + 空亡档案正确', () {
      final state = ReviewCaseAdapter.adapt(
        ReviewDemoData.hexagramCase(),
        profile: ReviewDemoData.profile(),
      );

      expect(state.lines, hasLength(6));
      expect(state.lines.first.position, 1);
      expect(state.displayLines.first.position, 6);
      expect(state.lineAt(6).sixSpirit, '青龙');
      expect(state.lineAt(6).hiddenSpirit1, '财丙寅');
      expect(state.lineAt(6).hiddenSpirit2, '父丁未');
      expect(state.lineAt(5).isVoid, isTrue); // 酉 空亡
      expect(state.lineAt(3).isVoid, isTrue); // 申 空亡
      expect(state.lineAt(3).shiYing, '世');
      expect(state.lineAt(1).changedShiYing, '世');
      expect(state.lineAt(5).changed!.isVoid, isTrue);
      expect(state.lineAt(3).changed!.isVoid, isFalse);
      expect(state.focusedLine, 3);
      expect(state.focusedRelations, isNotEmpty);
    });

    testWidgets('演示：焦点摘要与入口 chips 可见', (tester) async {
      await pumpDemo(tester);

      expect(
        find.text('世爻发动，化官鬼午火；当前建议优先继续查看：'),
        findsOneWidget,
      );
      for (final label in ['世应关系', '生克关系', '回头生回头克', '查看规则依据 ›']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('真实卦例：焦点摘要由 RelationInstance 生成', (tester) async {
      await pumpReal(tester);
      expect(
        find.text('焦点关系：动变三爻→变三爻；可点下方入口继续查看。'),
        findsOneWidget,
      );
    });
  });

  group('最终卦盘（UI-CORRECTION-R2）', () {
    testWidgets('内嵌主/变卦标题：无重复 Header、卦名正确', (tester) async {
      await pumpDemo(tester);

      expect(find.text('【主卦】'), findsOneWidget);
      expect(find.text('兑4 · 泽山咸'), findsOneWidget);
      expect(find.text('【变卦】'), findsOneWidget);
      expect(find.text('兑2 · 泽水困 · 六合卦'), findsOneWidget);
      // 旧 Header 的「完整排盘」chip 已随 Header 删除。
      expect(find.text('完整排盘'), findsNothing);
    });

    testWidgets('UI-05 · 爻槽统一 24×6：阳/阴/空亡尺寸一致', (tester) async {
      await pumpDemo(tester);

      final sizes = [
        tester.getSize(find.byKey(const Key('yao_glyph_6'))), // 阴
        tester.getSize(find.byKey(const Key('yao_glyph_4'))), // 阳
        tester.getSize(find.byKey(const Key('yao_glyph_5'))), // 空亡
        tester.getSize(find.byKey(const Key('changed_yao_glyph_5'))), // 变卦空亡
      ];
      for (final s in sizes) {
        expect(s.width, 24, reason: 'width');
        expect(s.height, 6, reason: 'height');
      }
    });

    testWidgets('UI-06 · 动爻标记 12×12：○ 与 × 一致', (tester) async {
      await pumpDemo(tester);

      final yinSize = tester.getSize(find.byKey(const Key('moving_marker_3')));
      final yangSize = tester.getSize(find.byKey(const Key('moving_marker_2')));
      expect(yinSize.width, 12);
      expect(yinSize.height, 12);
      expect(yangSize.width, 12);
      expect(yangSize.height, 12);
    });

    testWidgets('UI-07 · 超长纳音文本不覆盖爻槽', (tester) async {
      final longExtra = '超长纳音文本超长纳音文本超长纳音文本超长纳音文本';
      final profile = ReviewTraditionalProfile(
        lineTraditional: {
          6: const ReviewLineTraditional(
            sixSpirit: '青龙',
            hiddenSpirit1: '财丙寅',
            hiddenSpirit2: '父丁未',
            sixRelative: '父母丁未土',
            displayExtra: '超长纳音文本超长纳音文本超长纳音文本超长纳音文本',
            shiYing: '应',
            changed: ReviewChangedLine(
              sixRelative: '父母丁未土',
              displayExtra: '超长纳音文本超长纳音文本超长纳音文本超长纳音文本',
              movementType: MovementType.shaoYin,
            ),
          ),
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewPage(
            initialCase: ReviewDemoData.hexagramCase(),
            initialProfile: profile,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 无溢出异常。
      expect(tester.takeException(), isNull);
      // 爻槽仍在固定位置、尺寸不变。
      final yaoRect = tester.getRect(find.byKey(const Key('yao_glyph_6')));
      expect(yaoRect.width, 24);
      expect(yaoRect.height, 6);
      // 主卦文字框右缘不越过爻槽左缘（文本被裁剪，不覆盖爻槽）。
      // 主卦/变卦文字相同，取第一个（主卦侧）。
      final textRect =
          tester.getRect(find.text('父母丁未土($longExtra)').first);
      expect(textRect.right <= yaoRect.left, isTrue);
    });

    testWidgets('UI-08 · 变卦爻槽与变卦世应同时可见、顺序正确', (tester) async {
      await pumpDemo(tester);

      final changedYao1 = tester.getRect(find.byKey(const Key('changed_yao_glyph_1')));
      final changedShi1 = tester.getRect(find.byKey(const Key('changed_shi_ying_1')));
      expect(changedShi1.width, greaterThan(0));
      expect(changedYao1.right <= changedShi1.left, isTrue);

      final changedYao4 = tester.getRect(find.byKey(const Key('changed_yao_glyph_4')));
      final changedShi4 = tester.getRect(find.byKey(const Key('changed_shi_ying_4')));
      expect(changedShi4.width, greaterThan(0));
      expect(changedYao4.right <= changedShi4.left, isTrue);

      // 表尾说明可见。
      expect(
        find.text('阳爻 / 阴爻 / 空亡爻统一 24 × 6 DIP，只改变内部填充。'),
        findsOneWidget,
      );
    });
  });

  group('基本信息与页面结构', () {
    testWidgets('方式 / 事项 / 阳历 / 阴历 / 已生成 chip', (tester) async {
      await pumpDemo(tester);

      expect(find.text('铜钱手动'), findsOneWidget);
      expect(find.text('我的正缘什么时候出现？'), findsOneWidget);
      expect(find.text('阳历：2026-08-30 17:59'), findsOneWidget);
      expect(find.text('阴历：二零二六年七月十八日 酉时'), findsOneWidget);
      expect(find.text('已生成'), findsOneWidget);
    });

    testWidgets('真实卦例：传统字段显式置空（GAP 不伪造）', (tester) async {
      await pumpReal(tester);

      expect(find.text('—'), findsWidgets);
      expect(find.text('阴历：—'), findsOneWidget);
    });

    testWidgets('主体为纵向滚动，无内部横向出界', (tester) async {
      await pumpDemo(tester);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('阳历格式化', () {
      expect(formatSolar(DateTime(2026, 8, 30, 17, 59)), '2026-08-30 17:59');
      expect(formatSolar(DateTime(2026, 1, 5, 9, 5)), '2026-01-05 09:05');
    });
  });
}
