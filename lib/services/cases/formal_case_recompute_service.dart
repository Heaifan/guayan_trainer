import '../../domain/cases/case_record.dart';
import '../../domain/rule_execution_context.dart';
import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/engine/rule_engine.dart';
import '../../domain/rules/facts/canonical_fact_snapshot_builder.dart';
import '../../domain/rules/governance/rule_resolver.dart';
import 'case_recompute_service.dart';
import 'case_repository.dart';

/// Rebuilds and persists one formal analysis from the selected runtime rules.
class FormalCaseRecomputeService {
  FormalCaseRecomputeService(
    this._repository, {
    RuleEngine? engine,
    DateTime Function()? clock,
  })  : _engine = engine ?? RuleEngine(),
        _clock = clock ?? DateTime.now;

  final CaseRepository _repository;
  final RuleEngine _engine;
  final DateTime Function() _clock;

  Future<CaseRecord> recompute({
    required CaseRecord record,
    required Iterable<RuleDefinition> rules,
  }) async {
    final activeRules = RuleResolver.resolve(rules.toList()).activeRules;
    final runId = 'recompute-${record.ruleRuns.length}';
    final analysis = _engine.execute(
      activeRules,
      CanonicalFactSnapshotBuilder.build(record.toHexagramCase()),
      caseId: record.id,
      ruleRunId: runId,
    );
    final context = RuleExecutionContext([
      for (final rule in activeRules)
        RuleVersionRef(rule.ruleId.id, _majorVersion(rule.version.version)),
    ]);
    await CaseRecomputeService(_repository, clock: _clock).recomputeAnalysis(
      caseId: record.id,
      ruleContext: context,
      analysis: analysis,
    );
    return (await _repository.read(record.id))!;
  }
}

int _majorVersion(String version) => int.parse(version.split('.').first);
