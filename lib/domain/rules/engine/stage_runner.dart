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
import 'engine_types.dart';
import 'stage_iteration_runner.dart';

class StageRunnerResult {
  final List<FactRecord> derivedFacts;
  final List<FactRecord> derivedStates;
  final List<FactRecord> tags;
  final List<FactRecord> structures;
  final List<FactRecord> records;
  final List<RuleHit> ruleHits;
  final List<EvidenceNode> evidenceNodes;
  final List<EvidenceEdge> evidenceEdges;
  final int iterations;
  const StageRunnerResult(
    this.derivedFacts, this.derivedStates, this.tags, this.structures,
    this.records, this.ruleHits, this.evidenceNodes, this.evidenceEdges, this.iterations,
  );
  List<FactRecord> get allNewFacts => [
    ...derivedFacts, ...derivedStates, ...tags, ...structures, ...records,
  ];
}

class StageRunner {
  const StageRunner({
    required this.bindingResolver,
    required this.predicateEvaluator,
    required this.actionExecutor,
    this.maxIterations = 20,
  });
  final BindingResolver bindingResolver;
  final PredicateEvaluator predicateEvaluator;
  final ActionExecutor actionExecutor;
  final int maxIterations;

  StageRunnerResult runStage(RuleStage stage, List<RuleDefinition> stageRules, FactSnapshot initialSnapshot) {
    var currentSnapshot = initialSnapshot;
    final allDerivedFacts = <FactRecord>[];
    final allDerivedStates = <FactRecord>[];
    final allTags = <FactRecord>[];
    final allStructures = <FactRecord>[];
    final allRecords = <FactRecord>[];
    final allRuleHits = <RuleHit>[];
    final allEvidenceNodes = <EvidenceNode>[];
    final allEvidenceEdges = <EvidenceEdge>[];
    int iterations = 0;
    bool stageChanged = true;

    final iter = StageIterationRunner(bindingResolver: bindingResolver, predicateEvaluator: predicateEvaluator, actionExecutor: actionExecutor);

    while (stageChanged) {
      iterations++;
      if (iterations > maxIterations) { throw RuleEngineNonConvergence(stage, iterations); }
      final newFactsInIteration = <FactRecord>[];

      stageChanged = iter.runIteration(
        stageRules, currentSnapshot, newFactsInIteration,
        allDerivedFacts, allDerivedStates, allTags, allStructures, allRecords,
        allRuleHits, allEvidenceNodes, allEvidenceEdges
      );

      if (newFactsInIteration.isNotEmpty) {
        currentSnapshot = FactSnapshot.build(
          List<FactRecord>.from(currentSnapshot.facts)..addAll(newFactsInIteration),
          currentSnapshot.relations
        );
      }
    }
    return StageRunnerResult(
      allDerivedFacts, allDerivedStates, allTags, allStructures, allRecords,
      allRuleHits, allEvidenceNodes, allEvidenceEdges, iterations,
    );
  }
}
