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
      // R4 之后「焦点关系」不再只有 1 条（五行事实关系也会触及三爻），
      // 因此按契约断言：非空、且焦点关系里的动变仍是那条本体→变体。
      expect(state.focusedRelations, isNotEmpty);
      final rel = state.focusedRelations
          .firstWhere((r) => r.type == RelationType.dongBian);
      expect(
        rel.key.canonical,
        'dong_bian|sys.dong_bian|v1|-|yao:original:3->yao:changed:3',
      );
      expect(state.rulePackId, 'sys.default');
      expect(state.ruleVersion, 3);
    });

    test('适配器：allRelations + relationsInvolving 按爻过滤', () {
      final state = ReviewCaseAdapter.adapt(
        ReviewDemoData.hexagramCase(),
        profile: ReviewDemoData.profile(),
      );

      // R4 是「事实账本」：五行相生/相克（C(6,2) 对）也进账，
      // 总数不再等于 4，因此按**类型**断言，并额外要求新家族确实产出。
      final all = state.allRelations;
      expect(all.where((r) => r.type == RelationType.dongBian), hasLength(2));
      expect(all.where((r) => r.type == RelationType.liuHe), hasLength(2));
      expect(all.where((r) => r.type == RelationType.sheng), isNotEmpty);
      expect(all.where((r) => r.type == RelationType.ke), isNotEmpty);
      // 按爻过滤只命中「爻端点」的关系（月/日端点不会被点爻命中）。
      expect(
        state.relationsInvolving(3).any((r) => r.type == RelationType.dongBian),
        isTrue,
      );
      expect(
        state.relationsInvolving(6).any((r) => r.type == RelationType.liuHe),
        isTrue,
      );
      // 关系标签由实例生成。
      expect(
        ReviewCaseAdapter.relationLabel(
          state.relationsInvolving(3)
              .firstWhere((r) => r.type == RelationType.dongBian),
        ),
        '动变：三爻→变三爻',
      );
    });

    test('适配器：演示卦例伏神两列 + 空亡档案正确', () {
      final state = ReviewCaseAdapter.adapt(
        ReviewDemoData.hexagramCase(),
        profile: ReviewDemoData.profile(),
      );

      expect(state.lineAt(6).hiddenSpirit1, '财丙寅');
      expect(state.lineAt(3).hiddenSpirit1, '兄弟丙申金');
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

    testWidgets('UI-07 · 超长纳音不侵占爻槽、无省略号（任意缩放）',
        (tester) async {
      const longExtra = '超长纳音文本超长纳音文本超长纳音文本超长纳音文本';
      const profile = ReviewTraditionalProfile(
        lineTraditional: {
          6: ReviewLineTraditional(
            sixSpirit: '青龙',
            hiddenSpirit1: '财丙寅',
            sixRelative: '父母丁未土',
            displayExtra: longExtra,
            shiYing: '应',
            changed: ReviewChangedLine(
              sixRelative: '父母丁未土',
              displayExtra: longExtra,
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
      // 布局空间（设计坐标）爻槽恒为 24×6；绘制尺寸随 FittedBox(contain)
      // 缩放而变，不作为像素契约（见 3c00187「自适应全宽」定稿）。
      final yaoSize = tester.getSize(find.byKey(const Key('yao_glyph_6')));
      expect(yaoSize.width, 24);
      expect(yaoSize.height, 6);
      // 绘制空间列契约（同缩放系比较，缩放因子约去）：
      // 主卦文本列（正文与纳音）右缘 ≤ 主卦爻槽左缘。
      final mainYaoRect = tester.getRect(find.byKey(const Key('yao_glyph_6')));
      final mainPrimary = tester.getRect(find.text('父母丁未土').first);
      expect(mainPrimary.right <= mainYaoRect.left, isTrue,
          reason: '主卦正文压爻槽');
      final mainNaYin = tester.getRect(find.text(longExtra).first);
      expect(mainNaYin.right <= mainYaoRect.left, isTrue,
          reason: '主卦纳音压爻槽');
      // 变卦纳音列右缘 ≤ 变卦爻槽左缘。
      final changedYaoRect =
          tester.getRect(find.byKey(const Key('changed_yao_glyph_6')));
      final changedNaYin = tester.getRect(find.text(longExtra).at(1));
      expect(changedNaYin.right <= changedYaoRect.left, isTrue,
          reason: '变卦纳音压变卦爻槽');
      // 超长文本在列缘裁剪，不出现省略号。
      for (final t in tester.widgetList<Text>(find.text(longExtra))) {
        expect(t.overflow, isNot(TextOverflow.ellipsis));
      }
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
    testWidgets('问事 / 公历 / 农历 / meta / 方式 chip（合并行，信息不丢）',
        (tester) async {
      await pumpDemo(tester);

      expect(find.text('问事'), findsOneWidget);
      expect(find.text('事业发展 · 项目推进是否顺利？'), findsOneWidget);
      expect(find.text('铜钱手动'), findsOneWidget); // 方式 chip
      // 3c00187 起公历/农历合并为单行、meta 合并为单行（结构紧凑化），
      // 业务信息必须全部在场，但不再绑定拆分的 Widget 结构。
      expect(find.textContaining('公历 2026-08-30 09:30'), findsOneWidget);
      expect(find.textContaining('农历 七月十八 · 巳时'), findsOneWidget);
      expect(find.textContaining('默认规则包 v1'), findsOneWidget);
      expect(find.textContaining('手动起卦'), findsOneWidget);
      expect(find.textContaining('排盘已生成'), findsOneWidget);
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

  group('基线对齐与神煞网格（R5 契约收口）', () {
    testWidgets('R5 · 行内基线数学锁定：同类文本共享基线、六行一致', (tester) async {
      await pumpDemo(tester);

      // 不绑定绝对坐标（SVG 迭代会移动基线值），锁定三条视觉契约：
      // 1) 同样式文本在全部六行中共享同一基线值（列水平对齐的数学保证）；
      // 2) 正文 / 神系 / 纳音三条基线带互不相同；
      // 3) 基线值都在行高 48 内。
      final signatureToBaselines = <String, Set<double>>{};
      for (var p = 1; p <= 6; p++) {
        final rowBaselines = tester.widgetList<Baseline>(find.descendant(
          of: find.byKey(Key('review_line_$p')),
          matching: find.byType(Baseline),
        ));
        expect(rowBaselines, isNotEmpty, reason: 'review_line_$p 无 Baseline');
        for (final b in rowBaselines) {
          final text = b.child as Text;
          final s = text.style!;
          final signature = '${s.fontSize}|${s.fontWeight}|${s.color}';
          signatureToBaselines
              .putIfAbsent(signature, () => <double>{})
              .add(b.baseline);
        }
      }
      for (final e in signatureToBaselines.entries) {
        expect(e.value, hasLength(1),
            reason: '样式 ${e.key} 的基线在六行间不一致：${e.value}');
        expect(e.value.single, allOf(greaterThan(0), lessThan(48)),
            reason: '样式 ${e.key} 基线超出行高 48');
      }
      expect(signatureToBaselines.values.map((v) => v.single).toSet(),
          hasLength(3),
          reason: '应恰有 3 条基线带（正文/神系/纳音）');
    });

    testWidgets('R4 · 神煞固定 4×4：16 格无溢出、第 4 行在卡内', (tester) async {
      await pumpDemo(tester);

      final chips = tester.widgetList<Container>(find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Container),
      ));
      expect(chips.length, 16);
      // 第 1 列（卦身 / 金舆）同列；第 4 行（羊刃）与第 1 行同列间距为 3 列。
      expect(
        tester.getTopLeft(find.byKey(const Key('shensha_卦身'))).dx,
        tester.getTopLeft(find.byKey(const Key('shensha_金舆'))).dx,
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('shensha_卦身'))).dx,
        lessThan(tester.getTopLeft(find.byKey(const Key('shensha_羊刃'))).dx),
      );
      expect(
        tester.getBottomLeft(find.byKey(const Key('shensha_羊刃'))).dy,
        lessThan(932),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('R5 · 神煞按实际数据渲染：不足 16 项不留空占位', (tester) async {
      const profile = ReviewTraditionalProfile(
        shenShaItems: [
          ReviewShenShaItem(name: '卦身', value: '申'),
          ReviewShenShaItem(name: '香闺', value: '寅卯'),
          ReviewShenShaItem(name: '驿马', value: '寅'),
          ReviewShenShaItem(name: '桃花', value: '酉'),
        ],
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

      // 3c00187 定稿：按实际数据渲染，恰好 4 格（无 12 个强制空占位）。
      final cells = tester.widgetList<Container>(find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Container),
      ));
      expect(cells.length, 4);
      expect(
        tester.widgetList<SizedBox>(find.descendant(
          of: find.byType(GridView),
          matching: find.byType(SizedBox),
        )),
        isEmpty,
        reason: '不得保留空占位格',
      );
      // 4 项仍按 4 列几何占满一行。
      final dys = ['卦身', '香闺', '驿马', '桃花']
          .map((n) => tester.getTopLeft(find.byKey(Key('shensha_$n'))).dy)
          .toSet();
      expect(dys, hasLength(1), reason: '4 项必须在同一行');
      expect(tester.takeException(), isNull);
    });
  });

  group('页面结构', () {
    testWidgets('主体为纵向滚动，无内部横向出界', (tester) async {
      await pumpDemo(tester);
      // 允许工具栏等内部存在横向滚动
      expect(find.byType(SingleChildScrollView), findsWidgets);
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
      // 初爻（朱雀）与底部关系工具栏可见。
      expect(
        tester.getBottomLeft(find.text('朱雀')).dy <= navTop,
        isTrue,
      );
      expect(
        tester.getBottomLeft(find.text('关系').first).dy <=
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
