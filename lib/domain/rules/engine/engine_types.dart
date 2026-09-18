library;

import '../core/rule_stage.dart';
import '../facts/fact_record.dart';
import '../facts/fact_snapshot.dart';
import '../evidence/rule_hit.dart';
import '../evidence/evidence_node.dart';
import '../evidence/evidence_edge.dart';
import 'rule_trace.dart';

/// 运行时关系
class RuntimeRelation {
  final String relationId;
  final List<String> subjects;
  final String evidenceId;

  const RuntimeRelation({
    required this.relationId,
    required this.subjects,
    required this.evidenceId,
  });
}

/// 引擎执行结果分析
class AnalysisRun {
  const AnalysisRun({
    required this.baseSnapshot,
    required this.derivedFacts,
    required this.derivedStates,
    required this.tags,
    required this.structures,
    required this.records,
    required this.ruleHits,
    required this.evidenceNodes,
    required this.evidenceEdges,
    required this.iterations,
    this.traces = const [],
  });

  final FactSnapshot baseSnapshot;
  final List<FactRecord> derivedFacts;
  final List<FactRecord> derivedStates;
  final List<FactRecord> tags;
  final List<FactRecord> structures;
  final List<FactRecord> records;
  final List<RuleHit> ruleHits;
  final List<EvidenceNode> evidenceNodes;
  final List<EvidenceEdge> evidenceEdges;
  final List<RuleTrace> traces;
  final int iterations;
}

/// 死循环/不收敛异常
class RuleEngineNonConvergence implements Exception {
  final RuleStage stage;
  final int iterationCount;

  RuleEngineNonConvergence(this.stage, this.iterationCount);

  @override
  String toString() =>
      'RuleEngineNonConvergence: Stage ${stage.name} failed to converge after $iterationCount iterations.';
}

class ActionExecutionResult {
  final List<FactRecord> derivedFacts;
  final List<FactRecord> derivedStates;
  final List<FactRecord> tags;
  final List<FactRecord> structures;
  final List<FactRecord> records;
  final List<RuleHit> ruleHits;
  final List<EvidenceNode> evidenceNodes;
  final List<EvidenceEdge> evidenceEdges;
  final List<RuleTrace> actionTraces;

  const ActionExecutionResult(
    this.derivedFacts,
    this.derivedStates,
    this.tags,
    this.structures,
    this.records,
    this.ruleHits,
    this.evidenceNodes,
    this.evidenceEdges, [
    this.actionTraces = const [],
  ]);

  List<FactRecord> get allNewFacts => [
    ...derivedFacts,
    ...derivedStates,
    ...tags,
    ...structures,
    ...records,
  ];
}
