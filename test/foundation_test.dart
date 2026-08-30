import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/app/app.dart';
import 'package:guayan_trainer/app/navigation/guayan_main_tab_bar.dart';

/// 卦眼 2.0 Foundation + 排卦页 XYUI 改造基础验收测试。
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const GuayanApp());
    await tester.pumpAndSettle();
  }

  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  group('App Shell 五主导航', () {
    testWidgets('默认进入排卦（Index 0，XYUI TopBar + 流程轨）', (tester) async {
      await pumpApp(tester);

      // 排卦页无全局 AppBar，使用 XYUI CastingTopBar（标题「排卦」）。
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('排卦流程轨'), findsOneWidget);

      final bar = tester.widget<GuayanMainTabBar>(
        find.byType(GuayanMainTabBar),
      );
      expect(bar.selectedIndex, 0);
    });

    testWidgets('五个主入口存在且顺序固定', (tester) async {
      await pumpApp(tester);

      final labels = tester
          .widgetList<Text>(find.descendant(
            of: find.byType(GuayanMainTabBar),
            matching: find.byType(Text),
          ))
          .map((t) => t.data)
          .toList();
      expect(labels, ['排卦', '审卦', '关系', '卦例', '训练']);
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

    testWidgets('点击关系显示关系页面', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.descendant(
        of: find.byType(GuayanMainTabBar),
        matching: find.text('关系'),
      ));
      await tester.pumpAndSettle();

      expect(inAppBar('关系'), findsOneWidget);
      expect(find.text('关系工作台'), findsOneWidget);
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
          expect(find.text('排卦流程轨'), findsOneWidget);
        } else {
          expect(inAppBar(label), findsOneWidget);
        }
      }
    });
  });

  group('状态保持（§35，探针保留在 Context Strip）', () {
    testWidgets('IndexedStack 切换后页面状态不丢失', (tester) async {
      await pumpApp(tester);

      // 排卦页 Context Strip 探针初始 0。
      String probeValue() => tester
          .widget<Text>(find.byKey(const Key('casting_probe_value')))
          .data!;
      expect(probeValue(), '0');
      await tester.ensureVisible(find.byKey(const Key('casting_probe_value')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('casting_probe_value')));
      await tester.pumpAndSettle();
      expect(probeValue(), '1');

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

      // 状态仍保持为 1，说明页面未被销毁重建。
      expect(probeValue(), '1');
    });
  });

  group('更多入口（§34，XYUI 三点触发）', () {
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

      // 规则库 Skeleton：三类规则入口卡片。
      expect(find.text('自定义规则'), findsOneWidget);
      expect(find.text('规则包'), findsOneWidget);
      expect(find.text('系统规则'), findsOneWidget);
      expect(find.text('后续开放'), findsNWidgets(3));

      // 返回后恢复原主页面。
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('排卦流程轨'), findsOneWidget);
    });

    testWidgets('点击关于进入关于页并可返回', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byKey(const Key('casting_more_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('关于'));
      await tester.pumpAndSettle();

      expect(find.text('六爻结构化工作台'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('排卦流程轨'), findsOneWidget);
    });
  });
}
