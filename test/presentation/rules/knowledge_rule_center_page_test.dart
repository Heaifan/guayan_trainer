import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/domain/rules/knowledge/knowledge_rule.dart';
import 'package:guayan_trainer/domain/rules/knowledge/rule_variant.dart';
import 'package:guayan_trainer/domain/rules/knowledge/execution_rule_ref.dart';
import 'package:guayan_trainer/presentation/rules/system_rule_list_page.dart';

void main() {
  testWidgets(
    'SYSTEM page shows ten knowledge rules and dynamic variant groups',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SystemRuleListPage(
            service: _service(),
            systemRules: CommonRuleCorpus.v1(),
          ),
        ),
      );

      expect(find.text('共 10 个知识规则'), findsOneWidget);
      expect(find.text('通用判法'), findsOneWidget);
      expect(find.text('旬空'), findsOneWidget);
      expect(find.text('common.line.1.xun_kong'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();
      expect(find.text('考试取象'), findsOneWidget);
    },
  );

  testWidgets('search matches variant names and opens KnowledgeRule detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SystemRuleListPage(
          service: _service(),
          systemRules: CommonRuleCorpus.v1(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '考试取象');
    await tester.pump();
    expect(find.text('父母'), findsOneWidget);
    expect(find.text('官鬼'), findsOneWidget);
    expect(find.text('旬空'), findsNothing);

    await tester.enterText(find.byType(TextField), '旬空');
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, '旬空'));
    await tester.pumpAndSettle();
    expect(find.text('规则变体'), findsWidgets);
    expect(find.textContaining('执行规则 6 条'), findsOneWidget);
    await tester.tap(find.text('通用判法'));
    await tester.pumpAndSettle();
    expect(find.text('初爻'), findsOneWidget);
    expect(find.text('common.line.1.xun_kong'), findsNothing);
  });

  testWidgets('future second variant creates another dynamic group', (
    tester,
  ) async {
    const rule = KnowledgeRule(
      id: 'knowledge.future',
      name: '未来规则',
      categoryId: 'other',
      summary: '测试多变体',
      variants: [
        RuleVariant(
          id: 'variant.future.a',
          knowledgeRuleId: 'knowledge.future',
          name: '通用判法',
          origin: 'system',
          version: '1.0.0',
          executionRules: [
            ExecutionRuleRef(ruleId: 'future.a', displayName: '初爻', order: 1),
          ],
        ),
        RuleVariant(
          id: 'variant.future.b',
          knowledgeRuleId: 'knowledge.future',
          name: '未来判法',
          origin: 'system',
          version: '1.0.0',
          executionRules: [
            ExecutionRuleRef(ruleId: 'future.b', displayName: '初爻', order: 1),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SystemRuleListPage(
          service: _service(),
          systemRules: CommonRuleCorpus.v1(),
          knowledgeRules: const [rule],
        ),
      ),
    );

    expect(find.text('未来判法'), findsOneWidget);
    expect(find.text('未来规则'), findsNWidgets(2));
  });
}

CustomRuleService _service() =>
    CustomRuleService(CustomRuleStore(), UserGovernanceState());
