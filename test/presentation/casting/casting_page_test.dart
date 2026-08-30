/// 排卦页纵向流程轨 · 工作流状态测试。
///
/// 覆盖：初始状态、逐步骤推进、生成步骤 Locked/Ready/Completed、
/// 生成后修改触发 Warning（需重新生成）、Context Strip（探针/已完成计数）、
/// 组件级状态渲染（节点 Current/Pending/Complete/Warning/Locked）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/presentation/casting/casting_page.dart';
import 'package:guayan_trainer/presentation/casting/casting_page_state.dart';
import 'package:guayan_trainer/presentation/casting/widgets/casting_context_strip.dart';
import 'package:guayan_trainer/presentation/casting/widgets/casting_step_node.dart';

void main() {
  Future<void> pumpCasting(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CastingPage()),
    );
    await tester.pumpAndSettle();
  }

  group('初始状态', () {
    testWidgets('流程轨默认：步骤 1 Current，其余 Pending，生成 Locked', (tester) async {
      await pumpCasting(tester);

      expect(find.text('CASTING FLOW'), findsOneWidget);
      expect(find.text('排卦流程轨'), findsOneWidget);
      expect(find.text('1 / 5'), findsOneWidget);

      // 步骤 1 当前：CTA「立即填写」；其余待录入；生成「尚未就绪」。
      expect(find.text('立即填写'), findsOneWidget);
      expect(find.text('待录入'), findsNWidgets(3));
      expect(find.text('尚未就绪'), findsOneWidget);

      // Context Strip：探针 0、已完成 0/5。
      expect(find.byType(CastingContextStrip), findsOneWidget);
      expect(find.text('0 / 5'), findsOneWidget);
    });
  });

  group('步骤推进', () {
    testWidgets('完成步骤 1 → 显示摘要，步骤 2 成为 Current，Header 变 2/5', (tester) async {
      await pumpCasting(tester);

      await tester.tap(find.text('立即填写'));
      await tester.pumpAndSettle();

      expect(find.text('已完成'), findsNWidgets(2)); // 步骤徽标 + Context Strip 标签
      expect(find.text('2026-08-30 · 巳时'), findsOneWidget); // 摘要
      expect(find.text('2 / 5'), findsOneWidget);
      expect(find.text('待录入'), findsNWidgets(2));
    });

    testWidgets('完成前四步 → 生成步骤 Ready（起卦信息完整，可以生成排盘）', (tester) async {
      await pumpCasting(tester);

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('立即填写'));
        await tester.pumpAndSettle();
      }

      expect(find.text('5 / 5'), findsOneWidget); // Header 当前步骤
      expect(find.text('起卦信息完整，可以生成排盘'), findsOneWidget);
      expect(find.byKey(const Key('casting_generate_button')), findsOneWidget);
    });

    testWidgets('点击生成排盘 → Completed：本卦/变卦摘要 + 已完成 5/5', (tester) async {
      await pumpCasting(tester);

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('立即填写'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('casting_generate_button')));
      await tester.pumpAndSettle();

      expect(find.text('排盘已生成'), findsOneWidget);
      expect(find.text('本卦：乾为天'), findsOneWidget);
      expect(find.text('变卦：天风姤'), findsOneWidget);
      expect(find.text('查看排盘'), findsOneWidget);
      expect(find.text('重新生成'), findsOneWidget);
      // Context Strip 已完成 5/5（生成步骤计入完成）。
      expect(find.text('5 / 5'), findsNWidgets(2));
    });
  });

  group('生成后修改（Warning 语义）', () {
    testWidgets('生成后重新进入已完成步骤 → 生成步骤标记需重新生成', (tester) async {
      await pumpCasting(tester);

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('立即填写'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('casting_generate_button')));
      await tester.pumpAndSettle();

      // 点击「起卦时间」步骤卡片主体（重新进入修改）。
      await tester.ensureVisible(find.text('起卦时间'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('起卦时间'));
      await tester.pumpAndSettle();

      expect(find.text('关键信息已修改 · 需重新生成'), findsOneWidget);
      expect(find.text('重新生成'), findsOneWidget);
      // 该步骤回到 Current（可重新填写）。
      expect(find.text('立即填写'), findsOneWidget);
      // Context Strip 已完成 3/5（3 步完成 + 生成步骤处于需重新生成）。
      expect(find.text('3 / 5'), findsOneWidget);
    });
  });

  group('Context Strip 探针（§35 状态保持）', () {
    testWidgets('点击探针值递增', (tester) async {
      await pumpCasting(tester);

      String probeValue() => tester
          .widget<Text>(find.byKey(const Key('casting_probe_value')))
          .data!;

      expect(probeValue(), '0');
      await tester.ensureVisible(find.byKey(const Key('casting_probe_value')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('casting_probe_value')));
      await tester.pumpAndSettle();
      expect(probeValue(), '1');
    });
  });

  group('组件级状态渲染（CastingStepNode）', () {
    Widget nodeFor(CastingStepState state, {int index = 1}) {
      return CastingStepNode(
        data: CastingStepData(
          id: CastingStepId.time,
          index: index,
          title: '起卦时间',
          description: '记录起卦日期、时辰与来源',
          state: state,
        ),
      );
    }

    testWidgets('Current 显示序号（放大节点）', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: SizedBox()))),
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: nodeFor(CastingStepState.current)))),
      );
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Pending 显示序号', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: nodeFor(CastingStepState.pending, index: 3)))),
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Warning 显示感叹号', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: nodeFor(CastingStepState.warning)))),
      );
      expect(find.text('!'), findsOneWidget);
    });

    testWidgets('Completed 与 Locked 使用矢量图形（无 Unicode 占位）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                nodeFor(CastingStepState.completed),
                nodeFor(CastingStepState.locked),
              ],
            ),
          ),
        ),
      );
      // 对勾与锁为矢量图形（无文本序号 / 感叹号占位）。
      expect(find.byKey(const Key('node-check')), findsOneWidget);
      expect(find.byKey(const Key('node-lock')), findsOneWidget);
      expect(find.text('!'), findsNothing);
    });
  });
}
