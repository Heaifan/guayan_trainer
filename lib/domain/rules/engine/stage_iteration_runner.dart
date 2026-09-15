import '../core/rule_definition.dart';
import '../facts/fact_record.dart';
import '../facts/fact_snapshot.dart';
import '../evidence/rule_hit.dart';
import '../evidence/evidence_node.dart';
import '../evidence/evidence_edge.dart';
import 'action_executor.dart';
import 'binding_resolver.dart';
import 'predicate_evaluator.dart';

class StageIterationRunner {
  final BindingResolver bindingResolver;
  final PredicateEvaluator predicateEvaluator;
  final ActionExecutor actionExecutor;

  const StageIterationRunner({
    required this.bindingResolver,
    required this.predicateEvaluator,
    required this.actionExecutor,
  });

  bool _containsFact(Iterable<FactRecord> facts, FactRecord newFact) {
    return facts.any(
      (f) =>
          f.subject == newFact.subject &&
          f.predicateId == newFact.predicateId &&
          f.value == newFact.value,
    );
  }

  bool runIteration(
    List<RuleDefinition> stageRules,
    FactSnapshot currentSnapshot,
    List<FactRecord> newFactsInIteration,
    List<FactRecord> allDerivedFacts,
    List<FactRecord> allDerivedStates,
    List<FactRecord> allTags,
    List<FactRecord> allStructures,
    List<FactRecord> allRecords,
    List<RuleHit> allRuleHits,
    List<EvidenceNode> allEvidenceNodes,
    List<EvidenceEdge> allEvidenceEdges,
  ) {
    bool stageChanged = false;
    for (final rule in stageRules) {
      final context = bindingResolver.resolve(rule.bindings, currentSnapshot);
      final result = predicateEvaluator.evaluate(rule.condition, context, currentSnapshot);

      if (result.matched) {
        final actionResult = actionExecutor.execute(rule, context, result.supports);
        bool anyNewFact = false;

        void processFacts(List<FactRecord> sourceList, List<FactRecord> targetList) {
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
            if (!allRuleHits.any((h) => h.hitId == hit.hitId)) { allRuleHits.add(hit); }
          }
          allEvidenceNodes.addAll(actionResult.evidenceNodes);
          allEvidenceEdges.addAll(actionResult.evidenceEdges);
        }
      }
    }
    return stageChanged;
  }
}
