import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/presentation/rules/rule_editor_page.dart';

void main() {
  testWidgets('new rule editor opens the AST token editor', (tester) async {
    final service = CustomRuleService(CustomRuleStore(), UserGovernanceState());
    await tester.pumpWidget(
      MaterialApp(home: RuleEditorPage(service: service)),
    );

    expect(find.text('规则编辑器'), findsOneWidget);
    expect(find.text('可视化规则'), findsOneWidget);
    expect(find.text('五爻'), findsOneWidget);
    expect(find.text('六神'), findsOneWidget);
    expect(find.text('白虎'), findsOneWidget);
    expect(find.text('若'), findsOneWidget);
    expect(find.text('则'), findsOneWidget);
    expect(find.text('添加条件'), findsOneWidget);
    expect(find.text('删除条件'), findsOneWidget);
    expect(find.text('添加结果'), findsOneWidget);
    expect(find.text('删除结果'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.data_object), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });

  testWidgets('result token opens result choices', (tester) async {
    final service = CustomRuleService(CustomRuleStore(), UserGovernanceState());
    await tester.pumpWidget(
      MaterialApp(home: RuleEditorPage(service: service)),
    );

    await tester.tap(find.text('取象').last);
    await tester.pumpAndSettle();
    expect(find.text('选择结果类型'), findsOneWidget);
    expect(find.text('记录结果'), findsOneWidget);
  });

  testWidgets('condition add action opens the closed condition catalog', (
    tester,
  ) async {
    final service = CustomRuleService(CustomRuleStore(), UserGovernanceState());
    await tester.pumpWidget(
      MaterialApp(home: RuleEditorPage(service: service)),
    );
    await tester.tap(find.text('添加条件'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '旬空');
    await tester.pumpAndSettle();
    expect(find.text('旬空'), findsNWidgets(2));
  });

  testWidgets('condition picker exposes every user-facing runtime condition', (
    tester,
  ) async {
    final service = CustomRuleService(CustomRuleStore(), UserGovernanceState());
    await tester.pumpWidget(
      MaterialApp(home: RuleEditorPage(service: service)),
    );
    await tester.tap(find.text('添加条件'));
    await tester.pumpAndSettle();
    expect(find.text('生'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '有标签');
    await tester.pumpAndSettle();
    expect(find.text('有标签'), findsNWidgets(2));
    expect(find.text('空亡'), findsNothing);
  });
}
