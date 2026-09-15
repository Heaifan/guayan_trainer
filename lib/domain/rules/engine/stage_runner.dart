library;

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
    this.derivedFacts,
    this.derivedStates,
    this.tags,
    this.structures,
    this.records,
    this.ruleHits,
    this.evidenceNodes,
    this.evidenceEdges,
    this.iterations,
  );

  List<FactRecord> get allNewFacts => [
    ...derivedFacts,
    ...derivedStates,
    ...tags,
    ...structures,
    ...records,
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

  StageRunnerResult runStage(
    RuleStage stage,
    List<RuleDefinition> stageRules,
    FactSnapshot initialSnapshot,
  ) {
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

    while (stageChanged) {
      stageChanged = false;
      iterations++;
      if (iterations > maxIterations)
        throw RuleEngineNonConvergence(stage, iterations);
      final newFactsInIteration = <FactRecord>[];

      for (final rule in stageRules) {
        final context = bindingResolver.resolve(rule.bindings, currentSnapshot);
        final result = predicateEvaluator.evaluate(
          rule.condition,
          context,
          currentSnapshot,
        );

        if (result.matched) {
          final actionResult = actionExecutor.execute(
            rule,
            context,
            result.supports,
          );

          bool anyNewFact = false;

          void processFacts(
            List<FactRecord> sourceList,
            List<FactRecord> targetList,
          ) {
            for (final fact in sourceList) {
              if (currentSnapshot.getFact(fact.factId) == null &&
                  !newFactsInIteration.contains(fact) &&
                  !_containsFact(currentSnapshot.facts, fact) &&
                  !_containsFact(newFactsInIteration, fact)) {
                newFactsInIteration.add(fact);
                targetList.add(fact);
                anyNewFact = true;
                stageChanged = true;
              }
            }
          }

          processFacts(actionResult.derivedFacts, allDerivedFacts);
          processFacts(actionResult.derivedStates, allDerivedStates);
          processFacts(actionResult.tags, allTags);
          processFacts(actionResult.structures, allStructures);
          processFacts(actionResult.records, allRecords);

          if (anyNewFact) {
            for (final hit in actionResult.ruleHits) {
              if (!allRuleHits.any((h) => h.hitId == hit.hitId))
                allRuleHits.add(hit);
            }
            allEvidenceNodes.addAll(actionResult.evidenceNodes);
            allEvidenceEdges.addAll(actionResult.evidenceEdges);
          }
        }
      }

      if (newFactsInIteration.isNotEmpty) {
        currentSnapshot = FactSnapshot.build(
          List<FactRecord>.from(currentSnapshot.facts)
            ..addAll(newFactsInIteration),
          currentSnapshot.relations
        );
      }
    }
    return StageRunnerResult(
      allDerivedFacts,
      allDerivedStates,
      allTags,
      allStructures,
      allRecords,
      allRuleHits,
      allEvidenceNodes,
      allEvidenceEdges,
      iterations,
    );
  }

  bool _containsFact(Iterable<FactRecord> facts, FactRecord newFact) {
    return facts.any(
      (f) =>
          f.subject == newFact.subject &&
          f.predicateId == newFact.predicateId &&
          f.value == newFact.value,
    );
  }
}
