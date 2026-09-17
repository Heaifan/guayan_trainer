import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/presentation/rules/rule_editor_page.dart';

void main() {
  testWidgets('new rule editor defaults to CUSTOM and exposes three entries', (
    tester,
  ) async {
    final service = CustomRuleService(CustomRuleStore(), UserGovernanceState());
    await tester.pumpWidget(
      MaterialApp(home: RuleEditorPage(service: service)),
    );

    expect(find.text('CUSTOM'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('编辑条件'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('编辑绑定'), findsOneWidget);
    expect(find.text('编辑条件'), findsOneWidget);
    expect(find.text('编辑动作'), findsOneWidget);
    expect(find.text('规则预览（中文 DSL）'), findsOneWidget);
    expect(find.text('预览规则'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });
}
