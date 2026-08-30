/// 审卦页 XYUI 工作台测试（任务书 §22 Test A–H + 适配器/焦点关系）。
///
/// 覆盖：神煞网格无溢出（A）、四柱完整（B）、六行顺序与数量（C）、
/// 阴阳爻象（D）、动爻矢量标记（E）、世应位置（F）、
/// 焦点关系来自现有 RelationInstance（G）、演示数据与真实数据双路径。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/presentation/casting/widgets/yao_glyph.dart';
import 'package:guayan_trainer/presentation/review/review_case_adapter.dart';
import 'package:guayan_trainer/presentation/review/review_demo_data.dart';
import 'package:guayan_trainer/presentation/review/review_page.dart';
import 'package:guayan_trainer/presentation/review/review_page_state.dart';

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
    testWidgets('Wrap 无溢出、全部 16 项可见', (tester) async {
      await pumpDemo(tester);

      expect(find.byType(Wrap), findsWidgets);
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
    testWidgets('阴爻断线（少阴/老阴）、阳爻实线（少阳/老阳）语义', (tester) async {
      await pumpDemo(tester);

      MovementType glyphAt(int p) => tester
          .widget<YaoGlyph>(find.byKey(Key('yao_glyph_$p')))
          .movementType;
      expect(glyphAt(6), MovementType.shaoYin); // 阴
      expect(glyphAt(4), MovementType.shaoYang); // 阳
      expect(glyphAt(3), MovementType.laoYin); // 阴 · 动
      expect(glyphAt(2), MovementType.laoYang); // 阳 · 动

      // 行模型阴阳语义。
      final line2 = ReviewDemoData.hexagramCase().lineAt(2);
      expect(line2.movementType.isMoving, isTrue);
      expect(
        ReviewLineView(
          position: 2,
          movementType: MovementType.laoYang,
        ).isYang,
        isTrue,
      );
      expect(
        ReviewLineView(
          position: 1,
          movementType: MovementType.shaoYin,
        ).isYang,
        isFalse,
      );
    });
  });

  group('Test E · 动爻标记', () {
    testWidgets('老阴/老阳行有矢量动爻标记，静爻无', (tester) async {
      await pumpDemo(tester);

      expect(find.byKey(const Key('moving_arrow_3')), findsOneWidget); // 老阴
      expect(find.byKey(const Key('moving_arrow_2')), findsOneWidget); // 老阳
      for (final p in [1, 4, 5, 6]) {
        expect(find.byKey(Key('moving_arrow_$p')), findsNothing);
      }
      // 变卦爻象同样为矢量绘制。
      expect(find.byKey(const Key('changed_yao_glyph_3')), findsOneWidget);
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

      // 焦点爻 = 首个动爻（三爻）。
      expect(state.focusedLine, 3);
      expect(state.focusedRelations, hasLength(1));
      final rel = state.focusedRelations.first;
      expect(rel.type, RelationType.dongBian);
      // 稳定身份来自 Domain：有向 三爻→变三爻。
      expect(
        rel.key.canonical,
        'dong_bian|sys.dong_bian|v1|-|original-3->changed-3',
      );
      // 规则版本随卦例上下文（replay 契约）。
      expect(state.rulePackId, 'sys.default');
      expect(state.ruleVersion, 3);
    });

    test('适配器：演示卦例六行升序、六神/世应档案正确', () {
      final state = ReviewCaseAdapter.adapt(
        ReviewDemoData.hexagramCase(),
        profile: ReviewDemoData.profile(),
      );

      expect(state.lines, hasLength(6));
      expect(state.lines.first.position, 1);
      expect(state.displayLines.first.position, 6); // 上爻最先展示
      expect(state.lineAt(6).sixSpirit, '青龙');
      expect(state.lineAt(3).shiYing, '世');
      expect(state.lineAt(1).changedShiYing, '世');
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

  group('基本信息与排盘头', () {
    testWidgets('方式 / 事项 / 阳历 / 阴历 / 已生成 chip', (tester) async {
      await pumpDemo(tester);

      expect(find.text('铜钱手动'), findsOneWidget);
      expect(find.text('我的正缘什么时候出现？'), findsOneWidget);
      expect(find.text('阳历：2026-08-30 17:59'), findsOneWidget);
      expect(find.text('阴历：二零二六年七月十八日 酉时'), findsOneWidget);
      expect(find.text('已生成'), findsOneWidget);
    });

    testWidgets('主卦 / 变卦标题与完整排盘 chip', (tester) async {
      await pumpDemo(tester);

      expect(find.text('兑4 · 泽山咸'), findsOneWidget);
      expect(find.text('兑2 · 泽水困 · 六合卦'), findsOneWidget);
      expect(find.text('完整排盘'), findsOneWidget);
    });

    testWidgets('真实卦例：传统字段显式置空（GAP 不伪造）', (tester) async {
      await pumpReal(tester);

      expect(find.text('—'), findsWidgets);
      expect(find.text('阴历：—'), findsOneWidget);
      expect(find.text('方式'), findsOneWidget);
    });
  });

  group('页面结构（任务书 §3）', () {
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
