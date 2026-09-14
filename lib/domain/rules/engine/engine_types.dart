library;

import '../core/rule_stage.dart';
import '../facts/fact_record.dart';
import '../facts/fact_snapshot.dart';
import '../evidence/rule_hit.dart';

/// 引擎执行结果分析
class AnalysisRun {
  const AnalysisRun({
    required this.baseSnapshot,
    required this.derivedFacts,
    required this.ruleHits,
    required this.iterations,
  });

  final FactSnapshot baseSnapshot;
  final List<FactRecord> derivedFacts;
  final List<RuleHit> ruleHits;
  final int iterations;
}

/// 死循环/不收敛异常
class RuleEngineNonConvergence implements Exception {
  final RuleStage stage;
  final int iterationCount;
  
  RuleEngineNonConvergence(this.stage, this.iterationCount);

  @override
  String toString() => 'RuleEngineNonConvergence: Stage ${stage.name} failed to converge after $iterationCount iterations.';
}

class ActionExecutionResult {
  final List<FactRecord> derivedFacts;
  final List<RuleHit> ruleHits;

  const ActionExecutionResult(this.derivedFacts, this.ruleHits);
}
