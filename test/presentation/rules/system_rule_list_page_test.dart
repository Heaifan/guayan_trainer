import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/presentation/rules/system_rule_list_page.dart';

void main() {
  testWidgets('shows KnowledgeRule names, dynamic groups and search', (
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

    expect(find.text('系统规则'), findsWidgets);
    expect(find.text('共 10 个知识规则'), findsOneWidget);
    expect(find.text('旬空'), findsOneWidget);
    expect(find.text('通用判法'), findsOneWidget);
    expect(find.text('common.line.1.xun_kong'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    expect(find.text('考试取象'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '月生');
    await tester.pump();
    expect(find.text('月生'), findsWidgets);
    expect(find.text('旬空'), findsNothing);
  });
}
