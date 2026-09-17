import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/corpus/common_rule_corpus.dart';
import 'package:guayan_trainer/presentation/rules/rule_detail_page.dart';

void main() {
  testWidgets('shows read-only metadata, sections and formatted DSL', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RuleDetailPage(rule: CommonRuleCorpus.v1().first)),
    );

    expect(find.text('旬空'), findsOneWidget);
    expect(find.text('系统规则 · 状态 · v1.0.0'), findsOneWidget);
    expect(find.text('规则说明'), findsOneWidget);
    expect(find.text('规则绑定'), findsOneWidget);
    expect(find.text('规则条件'), findsOneWidget);
    expect(find.text('规则动作'), findsOneWidget);
    expect(find.text('规则内容（中文 DSL）'), findsOneWidget);
    expect(find.text('编辑规则'), findsNothing);
    expect(find.text('common.line.1.xun_kong'), findsOneWidget);
  });
}
