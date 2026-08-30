import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/app/app.dart';
import 'package:guayan_trainer/app/navigation/guayan_main_tab_bar.dart';
import 'package:guayan_trainer/app/navigation/main_tabs.dart';
import 'package:guayan_trainer/presentation/casting/casting_tokens.dart';

/// 卦眼 2.0 App Shell + 排卦页 XYUI 工作台基础验收测试。
///
/// 覆盖：五主导航（Test E）、排卦艮卦图标（Test F）、
/// IndexedStack 状态保持、更多菜单入口。
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GuayanApp());
    await tester.pumpAndSettle();
  }

  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  group('App Shell 五主导航（Test E）', () {
    testWidgets('默认进入排卦（无全局 AppBar，XYUI 顶栏）', (tester) async {
      await pumpApp(tester);

      expect(find.byType(AppBar), findsNothing);
      expect(find.text('卦眼'), findsOneWidget);
      expect(find.text('排卦'), findsWidgets); // 顶栏副标题 + 底部 tab
      expect(find.text('起卦时间'), findsOneWidget); // 排卦工作台第一行

      final bar = tester.widget<GuayanMainTabBar>(
        find.byType(GuayanMainTabBar),
      );
      expect(bar.selectedIndex, 0);
    });

    testWidgets('五个主入口存在且顺序固定（含训练）', (tester) async {
      await pumpApp(tester);

      final labels = tester
          .widgetList<Text>(find.descendant(
            of: find.byType(GuayanMainTabBar),
            matching: find.byType(Text),
          ))
          .map((t) => t.data)
          .toList();
      expect(labels, ['排卦', '审卦', '关系', '卦例', '训练']);
      expect(mainTabs.length, 5);
      expect(mainTabs.map((t) => t.title).toList(),
          ['排卦', '审卦', '关系', '卦例', '训练']);
    });

    testWidgets('点击训练显示训练页面', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.descendant(
        of: find.byType(GuayanMainTabBar),
        matching: find.text('训练'),
      ));
      await tester.pumpAndSettle();

      expect(inAppBar('训练'), findsOneWidget);
      expect(
        find.text('旧卦眼的学习与训练能力将在后续阶段统一迁移到这里。'),
        findsOneWidget,
      );
    });

    testWidgets('五个页面可循环切换', (tester) async {
      await pumpApp(tester);

      for (final label in ['审卦', '关系', '卦例', '训练', '排卦']) {
        await tester.tap(find.descendant(
          of: find.byType(GuayanMainTabBar),
          matching: find.text(label),
        ));
        await tester.pumpAndSettle();
        if (label == '排卦') {
          expect(find.text('起卦时间'), findsOneWidget);
        } else {
          expect(inAppBar(label), findsOneWidget);
        }
      }
    });
  });

  group('排卦图标（Test F · 艮卦矢量）', () {
    test('GuayanTabIcons.cast 返回 GenTrigramPainter', () {
      final painter = GuayanTabIcons.cast(CastingTokens.accent);
      expect(painter, isA<GenTrigramPainter>());
    });

    test('mainTabs[0] 使用艮卦图标且标题为排卦', () {
      expect(mainTabs[0].title, '排卦');
      expect(
        mainTabs[0].iconBuilder(CastingTokens.accent),
        isA<GenTrigramPainter>(),
      );
      // 不是旧「四条爻线」图标。
      expect(
        mainTabs[0].iconBuilder(CastingTokens.accent).runtimeType.toString(),
        'GenTrigramPainter',
      );
    });
  });

  group('状态保持（IndexedStack）', () {
    testWidgets('录入一爻后切走再切回不丢失', (tester) async {
      await pumpApp(tester);

      // 二爻（demo 草稿中待录）录入少阳。
      await tester.ensureVisible(find.byKey(const Key('yao_row_2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('yao_row_2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('line_opt_shaoYang')));
      await tester.pumpAndSettle();

      // 切到审卦再切回排卦。
      await tester.tap(find.descendant(
        of: find.byType(GuayanMainTabBar),
        matching: find.text('审卦'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(GuayanMainTabBar),
        matching: find.text('排卦'),
      ));
      await tester.pumpAndSettle();

      final text = tester
          .widget<Text>(find.byKey(const Key('yao_status_2')))
          .data;
      expect(text, '阳 · 静');
    });
  });

  group('更多入口（XYUI 三点触发）', () {
    testWidgets('更多菜单包含规则库/设置/关于', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byKey(const Key('casting_more_button')));
      await tester.pumpAndSettle();

      expect(find.text('规则库'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
      expect(find.text('关于'), findsOneWidget);
    });

    testWidgets('点击规则库进入 Skeleton 并可返回', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byKey(const Key('casting_more_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('规则库'));
      await tester.pumpAndSettle();

      expect(find.text('自定义规则'), findsOneWidget);
      expect(find.text('规则包'), findsOneWidget);
      expect(find.text('系统规则'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('起卦时间'), findsOneWidget);
    });
  });
}
