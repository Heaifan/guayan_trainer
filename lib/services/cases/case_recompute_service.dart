import '../../domain/cases/rule_run.dart';
import '../../domain/rule_execution_context.dart';
import 'case_repository.dart';
import '../../domain/rules/engine/engine_types.dart';

/// 对同一 Case 追加新的规则观察，不创建 Case、不修改 Snapshot。
class CaseRecomputeService {
  CaseRecomputeService(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final CaseRepository _repository;
  final DateTime Function() _clock;

  Future<void> recompute({
    required String caseId,
    required RuleExecutionContext ruleContext,
    required Map<String, Object?> result,
    required List<Map<String, Object?>> evidence,
  }) async {
    final record = await _repository.read(caseId);
    if (record == null) throw StateError('Unknown Case: $caseId');
    final run = RuleRun(
      id: 'recompute-${record.ruleRuns.length}',
      executedAt: _clock(),
      ruleContext: ruleContext,
      result: Map<String, Object?>.unmodifiable(result),
      evidence: List.unmodifiable([
        for (final item in evidence) Map<String, Object?>.unmodifiable(item),
      ]),
    );
    await _repository.update(record.copyWith(
      ruleRuns: [...record.ruleRuns, run],
      updatedAt: _clock(),
    ));
  }

  Future<void> recomputeAnalysis({
    required String caseId,
    required RuleExecutionContext ruleContext,
    required AnalysisRun analysis,
  }) async {
    final record = await _repository.read(caseId);
    if (record == null) throw StateError('Unknown Case: $caseId');
    final run = RuleRun.fromAnalysis(
      id: 'recompute-${record.ruleRuns.length}',
      executedAt: _clock(),
      ruleContext: ruleContext,
      analysis: analysis,
    );
    await _repository.update(record.copyWith(
      ruleRuns: [...record.ruleRuns, run],
      updatedAt: _clock(),
    ));
  }
}
