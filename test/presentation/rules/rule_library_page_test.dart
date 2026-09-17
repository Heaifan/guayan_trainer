import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
