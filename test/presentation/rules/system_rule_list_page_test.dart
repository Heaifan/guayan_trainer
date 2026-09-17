import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/presentation/rules/system_rule_list_page.dart';

void main() {
  testWidgets('shows Chinese rule name, category, search and filters', (
    tester,
  ) async {
    final rules = CommonRuleCorpus.v1();
    final service = CustomRuleService(CustomRuleStore(), UserGovernanceState());

    await tester.pumpWidget(
      MaterialApp(
        home: SystemRuleListPage(service: service, systemRules: rules),
      ),
    );
    await tester.pump();

    expect(find.text('系统规则'), findsOneWidget);
    expect(find.text('旬空'), findsOneWidget);
    expect(find.text('common.line.1.xun_kong'), findsOneWidget);
    expect(find.text('状态'), findsWidgets);
    expect(find.text('查看'), findsWidgets);

    await tester.enterText(find.byType(TextField), '月生');
    await tester.pump();
    expect(find.text('月生'), findsWidgets);
    expect(find.text('旬空'), findsNothing);
  });
}
