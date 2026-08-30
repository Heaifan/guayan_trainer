/// 审卦页一屏版测试（审卦一屏总基准）。
///
/// 覆盖：神煞 4×4（A/UI-04）、四柱（B）、六行顺序（C）、阴阳爻象（D）、
/// 动爻标记（E/UI-06）、世应（F）、关系来自 Domain（G）、
/// 最终卦盘标题、爻槽统一 24×6（UI-05）、文本不压爻（UI-07）、
/// 变卦爻槽+变卦世应同显（UI-08）、点爻弹层（关系列表/规则依据/进入关系页）、
/// 窄屏无溢出。
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
  Future<void> pumpDemo(WidgetTester tester, {VoidCallback? onOpenRelations}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReviewPage(
          initialCase: ReviewDemoData.hexagramCase(),
          initialProfile: ReviewDemoData.profile(),
          onOpenRelations: onOpenRelations,
        ),
      ),
    );
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
      final row2dy = tester.getTopLeft(find.byKey(const Key('shensha_桃花'))).dy;
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

      for (final text in ['丙午年', '丙申月', '丙子日', '丁酉时', '申酉空']) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      final order = [
        tester.getTopLeft(find.text('丙午年')).dx,
        tester.getTopLeft(find.text('丙申月')).dx,
        tester.getTopLeft(find.text('丙子日')).dx,
        tester.getTopLeft(find.text('丁酉时')).dx,
        tester.getTopLeft(find.text('申酉空')).dx,
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
      expect(kindAt(6), YaoKind.yin);
      expect(kindAt(5), YaoKind.voidYao); // 酉 空亡
      expect(kindAt(4), YaoKind.yang);
      expect(kindAt(3), YaoKind.voidYao); // 申 空亡
      expect(kindAt(2), YaoKind.yang); // 老阳 → 阳
      expect(kindAt(1), YaoKind.yin);
    });
  });

  group('Test E · 动爻标记', () {
    testWidgets('老阴 ○ / 老阳 × 矢量标记，静爻无', (tester) async {
      await pumpDemo(tester);

      expect(find.byKey(const Key('moving_marker_3')), findsOneWidget);
      expect(find.byKey(const Key('moving_marker_2')), findsOneWidget);
      for (final p in [1, 4, 5, 6]) {
        expect(find.byKey(Key('moving_marker_$p')), findsNothing);
      }
      expect(
        tester
            .widget<MovingMarker>(find.byKey(const Key('moving_marker_3')))
            .isYin,
        isTrue,
      );
      expect(
        tester
            .widget<MovingMarker>(find.byKey(const Key('moving_marker_2')))
            .isYin,
        isFalse,
      );
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

  group('Test G · 关系（状态层，来自 Domain）', () {
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

    test('适配器：allRelations + relationsInvolving 按爻过滤', () {
      final state = ReviewCaseAdapter.adapt(
        ReviewDemoData.hexagramCase(),
        profile: ReviewDemoData.profile(),
      );

      // 全部关系：动变×2（二/三爻）+ 六合×2（辰酉 1-5、午未 2-6）。
      expect(state.allRelations, hasLength(4));
      expect(state.relationsInvolving(3), hasLength(1)); // 动变三爻→变三爻
      expect(state.relationsInvolving(6), hasLength(1)); // 六合二爻—六爻
      // 关系标签由实例生成。
      expect(
        ReviewCaseAdapter.relationLabel(state.relationsInvolving(3).first),
        '动变：三爻→变三爻',
      );
    });

    test('适配器：演示卦例伏神两列 + 空亡档案正确', () {
      final state = ReviewCaseAdapter.adapt(
        ReviewDemoData.hexagramCase(),
        profile: ReviewDemoData.profile(),
      );

      expect(state.lineAt(6).hiddenSpirit1, '财寅木');
      expect(state.lineAt(6).hiddenSpirit2, '父未土');
      expect(state.lineAt(5).isVoid, isTrue);
      expect(state.lineAt(3).isVoid, isTrue);
      expect(state.lineAt(3).shiYing, '世');
      expect(state.lineAt(1).changedShiYing, '世');
      expect(state.lineAt(5).changed!.isVoid, isTrue);
      expect(state.lineAt(3).changed!.isVoid, isFalse);
    });
  });

  group('最终卦盘（一屏版）', () {
    testWidgets('内嵌主/变卦标题：无重复 Header、卦名正确', (tester) async {
      await pumpDemo(tester);

      expect(find.text('【主卦】'), findsOneWidget);
      expect(find.text('兑4 · 泽山咸'), findsOneWidget);
      expect(find.text('【变卦】'), findsOneWidget);
      expect(find.text('兑2 · 泽水困 · 六合卦'), findsOneWidget);
      expect(find.text('点击任一爻查看关系、规则依据与关系备注'), findsOneWidget);
    });

    testWidgets('UI-05 · 爻槽统一 24×6：阳/阴/空亡尺寸一致', (tester) async {
      await pumpDemo(tester);

      final sizes = [
        tester.getSize(find.byKey(const Key('yao_glyph_6'))), // 阴
        tester.getSize(find.byKey(const Key('yao_glyph_4'))), // 阳
        tester.getSize(find.byKey(const Key('yao_glyph_5'))), // 空亡
        tester.getSize(find.byKey(const Key('changed_yao_glyph_5'))),
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

    testWidgets('UI-07 · 超长纳音文本不覆盖爻槽、无省略号', (tester) async {
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

      expect(tester.takeException(), isNull);
      // 爻槽固定 24×6。
      final yaoRect = tester.getRect(find.byKey(const Key('yao_glyph_6')));
      expect(yaoRect.width, 24);
      expect(yaoRect.height, 6);
      // 六亲地支行（line1）右缘不越过爻槽左缘；纳音行（line2）无省略号。
      final line1 = tester.getRect(find.text('父母丁未土').first);
      expect(line1.right <= yaoRect.left, isTrue);
      final line2Text = tester.widget<Text>(find.text(longExtra).first);
      expect(line2Text.overflow, isNot(TextOverflow.ellipsis));
    });

    testWidgets('UI-08 · 变卦爻槽与变卦世应同时可见、顺序正确', (tester) async {
      await pumpDemo(tester);

      final changedYao1 =
          tester.getRect(find.byKey(const Key('changed_yao_glyph_1')));
      final changedShi1 =
          tester.getRect(find.byKey(const Key('changed_shi_ying_1')));
      expect(changedShi1.width, greaterThan(0));
      expect(changedYao1.right <= changedShi1.left, isTrue);

      final changedYao4 =
          tester.getRect(find.byKey(const Key('changed_yao_glyph_4')));
      final changedShi4 =
          tester.getRect(find.byKey(const Key('changed_shi_ying_4')));
      expect(changedShi4.width, greaterThan(0));
      expect(changedYao4.right <= changedShi4.left, isTrue);
    });
  });

  group('基本信息（一屏版）', () {
    testWidgets('问事 / 公历 / 农历 / meta / 方式 chip', (tester) async {
      await pumpDemo(tester);

      expect(find.text('事业发展 · 项目推进是否顺利？'), findsOneWidget);
      expect(find.text('2026-08-30 09:30'), findsOneWidget); // 公历
      expect(find.text('七月十八 · 巳时'), findsOneWidget); // 农历
      expect(find.text('默认规则包 v1'), findsOneWidget);
      expect(find.text('手动起卦'), findsOneWidget);
      expect(find.text('排盘已生成'), findsOneWidget);
      expect(find.text('铜钱手动'), findsOneWidget); // 方式 chip
    });

    testWidgets('真实卦例：传统字段显式置空（GAP 不伪造）', (tester) async {
      await pumpReal(tester);

      expect(find.text('—'), findsWidgets);
      expect(find.text('手动起卦'), findsNothing); // castingMethod 为空
    });
  });

  group('点爻弹层（一屏版交互）', () {
    testWidgets('点击某爻 → 高亮 + 弹层展示关系列表', (tester) async {
      await pumpDemo(tester);

      await tester.ensureVisible(find.byKey(const Key('review_line_3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('review_line_3')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('line_detail_sheet')), findsOneWidget);
      expect(find.text('关系列表'), findsOneWidget);
      expect(find.text('动变：三爻→变三爻'), findsOneWidget);
      expect(find.byKey(const Key('sheet_rule_entry')), findsOneWidget);
      expect(find.byKey(const Key('sheet_note_entry')), findsOneWidget);
    });

    testWidgets('弹层「进入关系页」回调 App Shell 切换', (tester) async {
      var opened = false;
      await pumpDemo(tester, onOpenRelations: () => opened = true);

      await tester.ensureVisible(find.byKey(const Key('review_line_6')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('review_line_6')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sheet_open_relations')));
      await tester.pumpAndSettle();

      expect(opened, isTrue);
      expect(find.byKey(const Key('line_detail_sheet')), findsNothing);
    });
  });

  group('页面结构', () {
    testWidgets('主体为纵向滚动，无内部横向出界', (tester) async {
      await pumpDemo(tester);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('窄屏 360 DIP 无 RenderFlex 溢出', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpDemo(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('硬门禁 · 六爻六行 + 表尾在首屏完整显示（430×932）', (tester) async {
      // 模拟常见真机逻辑尺寸（430×932，含底部导航 56 DIP）。
      tester.view.physicalSize = const Size(430 * 3, 932 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpDemo(tester);
      expect(tester.takeException(), isNull);

      // 六行（上爻 6 → 初爻 1）底缘必须在导航区之上完整可见。
      final navTop = 932 - 56;
      for (var p = 1; p <= 6; p++) {
        final bottom =
            tester.getBottomLeft(find.byKey(Key('review_line_$p'))).dy;
        expect(bottom <= navTop, isTrue,
            reason: 'review_line_$p 底缘 $bottom 超过导航区 $navTop');
      }
      // 初爻（朱雀）与表尾提示文字同屏可见。
      expect(
        tester.getBottomLeft(find.text('朱雀')).dy <= navTop,
        isTrue,
      );
      expect(
        tester.getBottomLeft(find.text('点击任一爻查看关系、规则依据与关系备注')).dy <=
            navTop,
        isTrue,
      );
    });

    test('阳历格式化', () {
      expect(formatSolar(DateTime(2026, 8, 30, 9, 30)), '2026-08-30 09:30');
      expect(formatSolar(DateTime(2026, 1, 5, 9, 5)), '2026-01-05 09:05');
    });
  });
}
