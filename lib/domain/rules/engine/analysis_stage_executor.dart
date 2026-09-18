import '../core/rule_definition.dart';
import '../core/rule_stage.dart';
import '../facts/fact_record.dart';
import '../facts/fact_snapshot.dart';
import '../evidence/rule_hit.dart';
import '../evidence/evidence_node.dart';
import '../evidence/evidence_edge.dart';
import 'stage_runner.dart';
import 'engine_types.dart';
import 'rule_trace.dart';

class AnalysisStageExecutor {
  final StageRunner stageRunner;
  const AnalysisStageExecutor(this.stageRunner);

  AnalysisRun execute(List<RuleDefinition> rules, FactSnapshot initialSnapshot) {
    final stages = [
      RuleStage.baseRelation,
      RuleStage.derivedState,
      RuleStage.structure,
      RuleStage.tag,
    ];

    var currentSnapshot = initialSnapshot;
    final allDerivedFacts = <FactRecord>[];
    final allDerivedStates = <FactRecord>[];
    final allTags = <FactRecord>[];
    final allStructures = <FactRecord>[];
    final allRecords = <FactRecord>[];
    final allRuleHits = <RuleHit>[];
    final allEvidenceNodes = <EvidenceNode>[];
    final allEvidenceEdges = <EvidenceEdge>[];
    final allRuleTraces = <RuleTrace>[];
    int totalIterations = 0;

    for (final stage in stages) {
      final stageRules = rules.where((r) => r.stage == stage && r.enabled).toList();
      for (final rule in rules.where((r) => r.stage == stage && !r.enabled)) {
        allRuleTraces.add(RuleTrace(
          kind: RuleTraceKind.rule,
          label: rule.title,
          status: RuleTraceStatus.skipped,
          reason: '规则未启用',
        ));
      }
      if (stageRules.isEmpty) continue;

      final stageResult = stageRunner.runStage(stage, stageRules, currentSnapshot);

      if (stageResult.allNewFacts.isNotEmpty) {
        allDerivedFacts.addAll(stageResult.derivedFacts);
        allDerivedStates.addAll(stageResult.derivedStates);
        allTags.addAll(stageResult.tags);
        allStructures.addAll(stageResult.structures);
        allRecords.addAll(stageResult.records);

        final mergedFacts = List<FactRecord>.from(currentSnapshot.facts)..addAll(stageResult.allNewFacts);
        currentSnapshot = FactSnapshot.build(mergedFacts);
      }
      allRuleHits.addAll(stageResult.ruleHits);
      allEvidenceNodes.addAll(stageResult.evidenceNodes);
      allEvidenceEdges.addAll(stageResult.evidenceEdges);
      allRuleTraces.addAll(stageResult.ruleTraces);
      totalIterations += stageResult.iterations;
    }

    return AnalysisRun(
      baseSnapshot: initialSnapshot,
      derivedFacts: List.unmodifiable(allDerivedFacts),
      derivedStates: List.unmodifiable(allDerivedStates),
      tags: List.unmodifiable(allTags),
      structures: List.unmodifiable(allStructures),
      records: List.unmodifiable(allRecords),
      ruleHits: List.unmodifiable(allRuleHits),
      evidenceNodes: List.unmodifiable(allEvidenceNodes),
      evidenceEdges: List.unmodifiable(allEvidenceEdges),
      iterations: totalIterations,
      traces: List.unmodifiable(allRuleTraces),
    );
  }
}
