import '../core/rule_definition.dart';
import '../core/rule_stage.dart';
import '../facts/fact_record.dart';
import '../facts/fact_snapshot.dart';
import '../evidence/rule_hit.dart';
import '../evidence/evidence_node.dart';
import '../evidence/evidence_edge.dart';
import 'action_executor.dart';
import 'binding_resolver.dart';
import 'predicate_evaluator.dart';
import 'operators/operator_registry.dart';

import 'engine_types.dart';

import 'stage_runner.dart';

/// 核心规则引擎
class RuleEngine {
  RuleEngine({OperatorRegistry? registry, this.maxIterationsPerStage = 20})
    : registry = registry ?? OperatorRegistry(),
      bindingResolver = const BindingResolver(),
      actionExecutor = const ActionExecutor() {
    predicateEvaluator = PredicateEvaluator(this.registry);
    stageRunner = StageRunner(
      bindingResolver: bindingResolver,
      predicateEvaluator: predicateEvaluator,
      actionExecutor: actionExecutor,
      maxIterations: maxIterationsPerStage,
    );
  }

  final OperatorRegistry registry;
  final BindingResolver bindingResolver;
  final ActionExecutor actionExecutor;
  late final PredicateEvaluator predicateEvaluator;
  late final StageRunner stageRunner;
  final int maxIterationsPerStage;

  /// 执行规则派生
  AnalysisRun execute(
    List<RuleDefinition> rules,
    FactSnapshot initialSnapshot,
  ) {
    // 按照 stage 排序
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
    int totalIterations = 0;

    for (final stage in stages) {
      final stageRules = rules
          .where((r) => r.stage == stage && r.enabled)
          .toList();
      if (stageRules.isEmpty) continue;

      final stageResult = stageRunner.runStage(
        stage,
        stageRules,
        currentSnapshot,
      );

      if (stageResult.allNewFacts.isNotEmpty) {
        allDerivedFacts.addAll(stageResult.derivedFacts);
        allDerivedStates.addAll(stageResult.derivedStates);
        allTags.addAll(stageResult.tags);
        allStructures.addAll(stageResult.structures);
        allRecords.addAll(stageResult.records);

        final mergedFacts = List<FactRecord>.from(currentSnapshot.facts)
          ..addAll(stageResult.allNewFacts);
        currentSnapshot = FactSnapshot.build(mergedFacts);
      }
      allRuleHits.addAll(stageResult.ruleHits);
      allEvidenceNodes.addAll(stageResult.evidenceNodes);
      allEvidenceEdges.addAll(stageResult.evidenceEdges);
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
    );
  }
}
