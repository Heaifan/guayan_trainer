import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/presentation/rules/rule_editor_page.dart';
import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/domain/cases/casting_snapshot.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/services/cases/case_query.dart';
import 'package:guayan_trainer/services/cases/case_repository.dart';

class _MemoryCaseRepository implements CaseRepository {
  _MemoryCaseRepository(this.records);
  final List<CaseRecord> records;
  int writes = 0;

  @override
  Future<void> create(CaseRecord record) async => writes++;
  @override
  Future<CaseRecord?> read(String id) async => records.where((r) => r.id == id).firstOrNull;
  @override
  Future<CasePage> list(CaseQuery query) async => CasePage(items: records, hasMore: false);
  @override
  Future<void> update(CaseRecord record) async => writes++;
  @override
  Future<void> softDelete(String id) async => writes++;
  @override
  Future<void> restore(String id) async => writes++;
  @override
  Future<void> permanentlyDelete(String id) async => writes++;
  @override
  Future<void> setFavorite(String id, bool value) async => writes++;
  @override
  Future<String> metadataJsonForTest(String id) async => '{}';
}

CaseRecord _record() {
  const movements = [
    MovementType.shaoYin,
    MovementType.shaoYang,
    MovementType.laoYin,
    MovementType.shaoYang,
    MovementType.laoYang,
    MovementType.shaoYin,
  ];
  final chart = CastingEngine.cast(movements);
  return CaseRecord.create(
    id: 'editor-case',
    snapshot: CastingSnapshot(
      castingTime: DateTime(2026, 9, 18, 10, 18),
      subject: '问工作',
      lines: [
        for (final line in chart.lines)
          LineState(
            position: line.position,
            movementType: movements[line.position - 1],
            branch: line.branch.label,
          ),
      ],
      originalHexagramName: chart.original.name,
      movingPositions: chart.movingPositions,
    ),
    createdAt: DateTime(2026, 9, 18, 10, 18),
    originalRuleRun: RuleRun.original(
      executedAt: DateTime(2026, 9, 18, 10, 18),
      ruleContext: const RuleExecutionContext.empty(),
      result: const {},
      evidence: const [],
    ),
  );
}

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

  testWidgets('test rule opens runtime result without portable schema error', (
    tester,
  ) async {
    final service = CustomRuleService(CustomRuleStore(), UserGovernanceState());
    await tester.pumpWidget(
      MaterialApp(
        home: RuleEditorPage(
          service: service,
          caseRepository: _MemoryCaseRepository(const []),
        ),
      ),
    );

    await tester.tap(find.text('测试规则'));
    await tester.pumpAndSettle();

    expect(find.text('暂无可用于测试的卦例'), findsOneWidget);
    expect(find.textContaining('规则测试需要真实卦象事实'), findsOneWidget);
  });

  testWidgets('no context selects a Case and remembers it for the next test', (
    tester,
  ) async {
    final repository = _MemoryCaseRepository([_record()]);
    final service = CustomRuleService(CustomRuleStore(), UserGovernanceState());
    await tester.pumpWidget(MaterialApp(
      home: RuleEditorPage(service: service, caseRepository: repository),
    ));

    await tester.tap(find.text('测试规则'));
    await tester.pumpAndSettle();
    expect(find.text('选择测试卦例'), findsOneWidget);
    await tester.tap(find.text('问工作'));
    await tester.pumpAndSettle();
    expect(find.textContaining('测试卦例：'), findsOneWidget);
    expect(repository.writes, 0);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('测试规则'));
    await tester.pumpAndSettle();
    expect(find.text('选择测试卦例'), findsNothing);
    expect(find.textContaining('测试卦例：'), findsOneWidget);
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
