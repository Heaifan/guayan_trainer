library;

import '../core/rule_definition.dart';
import '../core/rule_stage.dart';
import '../facts/fact_record.dart';
import '../facts/fact_snapshot.dart';
import '../evidence/rule_hit.dart';
import 'action_executor.dart';
import 'binding_resolver.dart';
import 'predicate_evaluator.dart';
import 'engine_types.dart';

class StageRunnerResult {
  final List<FactRecord> newFacts;
  final List<RuleHit> ruleHits;
  final int iterations;
  const StageRunnerResult(this.newFacts, this.ruleHits, this.iterations);
}

class StageRunner {
  const StageRunner({required this.bindingResolver, required this.predicateEvaluator, required this.actionExecutor, this.maxIterations = 20});
  final BindingResolver bindingResolver;
  final PredicateEvaluator predicateEvaluator;
  final ActionExecutor actionExecutor;
  final int maxIterations;

  StageRunnerResult runStage(RuleStage stage, List<RuleDefinition> stageRules, FactSnapshot initialSnapshot) {
    var currentSnapshot = initialSnapshot;
    final allDerivedFacts = <FactRecord>[];
    final allRuleHits = <RuleHit>[];
    int iterations = 0;
    bool stageChanged = true;

    while (stageChanged) {
      stageChanged = false;
      iterations++;
      if (iterations > maxIterations) throw RuleEngineNonConvergence(stage, iterations);
      final newFactsInIteration = <FactRecord>[];

      for (final rule in stageRules) {
        try {
          final context = bindingResolver.resolve(rule.bindings, currentSnapshot);
          final result = predicateEvaluator.evaluate(rule.condition, context, currentSnapshot);

          if (result.matched) {
            final actionResult = actionExecutor.execute(rule, context, result.supports);
            for (final fact in actionResult.derivedFacts) {
              if (currentSnapshot.getFact(fact.factId) == null &&
                  !newFactsInIteration.contains(fact) && 
                  !_containsFact(currentSnapshot.facts, fact) &&
                  !_containsFact(newFactsInIteration, fact)) {
                newFactsInIteration.add(fact);
                stageChanged = true;
              }
            }
            for (final hit in actionResult.ruleHits) {
               if (!allRuleHits.any((h) => h.hitId == hit.hitId)) allRuleHits.add(hit);
            }
          }
        } catch (e) {
          // Ignore errors
        }
      }

      if (newFactsInIteration.isNotEmpty) {
        allDerivedFacts.addAll(newFactsInIteration);
        currentSnapshot = FactSnapshot.build(List<FactRecord>.from(currentSnapshot.facts)..addAll(newFactsInIteration));
      }
    }
    return StageRunnerResult(allDerivedFacts, allRuleHits, iterations);
  }

  bool _containsFact(Iterable<FactRecord> facts, FactRecord newFact) {
    return facts.any((f) => f.subject == newFact.subject && f.predicateId == newFact.predicateId && f.value == newFact.value);
  }
}
