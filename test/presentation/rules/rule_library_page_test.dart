import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guayan_trainer/presentation/rules/rule_library_page.dart';

void main() {
  testWidgets('shows Scheme A entry cards in the frozen order', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RuleLibraryPage()));

    expect(find.text('规则库'), findsOneWidget);
    expect(find.text('系统规则'), findsWidgets);
    expect(find.text('规则包'), findsOneWidget);
    expect(find.text('自定义规则'), findsOneWidget);
    expect(find.text('最近使用'), findsOneWidget);
    expect(find.text('搜索规则、规则包或关键词'), findsOneWidget);
  });

  testWidgets('SYSTEM entry reaches the KnowledgeRule catalog only', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: RuleLibraryPage()));

    await tester.tap(find.text('系统规则').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('共 10 个知识规则'), findsOneWidget);
    expect(find.text('旬空'), findsOneWidget);
    expect(find.text('common.line.1.xun_kong'), findsNothing);
  });

  testWidgets('custom entry does not expose the SYSTEM execution list', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: RuleLibraryPage()));

    await tester.tap(find.text('自定义规则').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('自定义规则'), findsOneWidget);
    expect(find.text('还没有自定义规则'), findsOneWidget);
    expect(find.text('common.line.1.xun_kong'), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
