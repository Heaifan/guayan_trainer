import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_trace.dart';
import 'package:guayan_trainer/domain/rules/evidence/derived_evidence.dart';
import 'package:guayan_trainer/domain/rules/evidence/evidence_id.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

void main() {
  test('RuleRun reload preserves historical evidence and trace provenance', () {
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
      supports: const [EvidenceId('branch-2')],
      ruleRunId: 'run-1',
      traceRef: 'trace-1',
    );
    final run = RuleRun(
      id: 'run-1',
      executedAt: DateTime.utc(2026, 9, 18),
      ruleContext: RuleExecutionContext([
        const RuleVersionRef('custom.road', 1),
      ]),
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
    );

    final restored = RuleRun.fromJson(run.toJson());
    expect(restored.derivedEvidence.single, evidence);
    expect(restored.traces.single.status, RuleTraceStatus.matched);
    expect(restored.ruleContext.versionFor('custom.road'), 1);
  });

  test('old RuleRun JSON without structured evidence remains readable', () {
    final old = RuleRun.original(
      executedAt: DateTime.utc(2026, 9, 18),
      ruleContext: const RuleExecutionContext.empty(),
      result: const {'legacy': true},
      evidence: const [],
    );
    final restored = RuleRun.fromJson(old.toJson()..remove('derivedEvidence')..remove('traces'));
    expect(restored.derivedEvidence, isEmpty);
    expect(restored.traces, isEmpty);
  });
}
