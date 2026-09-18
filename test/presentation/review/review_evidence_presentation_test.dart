import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_trace.dart';
import 'package:guayan_trainer/domain/rules/evidence/derived_evidence.dart';
import 'package:guayan_trainer/domain/rules/evidence/evidence_id.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/presentation/review/review_page.dart';

HexagramCase _case() {
  final evidence = DerivedEvidence(
    id: const EvidenceId('e1'),
    caseId: 'case-1',
    ruleId: const RuleId('custom.road'),
    ruleVersion: RuleVersion('1.0.0'),
    ruleOrigin: RuleOrigin.CUSTOM,
    actionType: 'TagAction',
    category: 'image',
    value: '有路冲家',
    targetKind: ActionTargetKind.relation,
    targetRefs: const [
      SemanticRef('line', '2'),
      SemanticRef('line', '3'),
    ],
    relationId: 'branch_clashes',
    supports: const [EvidenceId('support')],
    ruleRunId: 'run-1',
    traceRef: 'trace-1',
  );
  return HexagramCase(
    id: 'case-1',
    question: '道路',
    createdAt: DateTime.utc(2026, 9, 18),
    lines: [
      for (var position = 1; position <= 6; position++)
        LineState(position: position, movementType: MovementType.shaoYin),
    ],
    ruleRuns: [
      RuleRun(
        id: 'run-1',
        executedAt: DateTime.utc(2026, 9, 18),
        ruleContext: const RuleExecutionContext.empty(),
        result: const {'matched': 1},
        evidence: [evidence.toJson()],
        derivedEvidence: [evidence],
        traces: const [
          RuleTrace(
            kind: RuleTraceKind.rule,
            label: '有路冲家',
            status: RuleTraceStatus.matched,
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('review page presents evidence and rule runs', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ReviewPage(initialCase: _case(), useDemoFallback: false),
    ));
    expect(find.text('取象'), findsOneWidget);
    expect(find.textContaining('规则运行'), findsOneWidget);
    expect(find.text('有路冲家'), findsOneWidget);
  });
}
