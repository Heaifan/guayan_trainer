import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/knowledge/system_knowledge_rule_catalog.dart';
import 'package:guayan_trainer/presentation/rules/knowledge_rule_detail_page.dart';

void main() {
  testWidgets('detail keeps variants and execution instances secondary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: KnowledgeRuleDetailPage(
          rule: SystemKnowledgeRuleCatalog.rules.first,
        ),
      ),
    );

    expect(find.text('旬空'), findsOneWidget);
    expect(find.text('系统规则'), findsOneWidget);
    expect(find.text('规则变体'), findsWidgets);
    expect(find.text('通用判法'), findsOneWidget);
    expect(find.text('版本'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('执行范围'), findsOneWidget);
    expect(find.text('六爻'), findsOneWidget);
    expect(find.textContaining('执行规则 6 条'), findsOneWidget);
    expect(find.text('common.line.1.xun_kong'), findsNothing);

    await tester.tap(find.text('通用判法'));
    await tester.pumpAndSettle();
    expect(find.text('初爻'), findsOneWidget);
    expect(find.text('上爻'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    expect(find.byType(Radio), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(Switch), findsNothing);

    await tester.tap(find.text('高级信息'));
    await tester.pumpAndSettle();
    expect(find.text('common.line.1.xun_kong'), findsOneWidget);
  });
}
