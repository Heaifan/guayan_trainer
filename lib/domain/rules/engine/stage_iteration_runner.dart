import '../core/rule_definition.dart';
import '../facts/fact_record.dart';
import '../facts/fact_snapshot.dart';
import '../evidence/rule_hit.dart';
import '../evidence/evidence_node.dart';
import '../evidence/evidence_edge.dart';
import 'action_executor.dart';
import 'binding_resolver.dart';
import 'predicate_evaluator.dart';
import 'rule_trace.dart';
import '../evidence/derived_evidence.dart';

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
    List<DerivedEvidence> allDerivedEvidence,
    List<RuleTrace> allRuleTraces,
    {
    String caseId = 'preview',
    String ruleRunId = 'in-memory',
    }
  ) {
    bool stageChanged = false;
    for (final rule in stageRules) {
      final bindingResult = bindingResolver.resolveWithTrace(
        rule.bindings,
        currentSnapshot,
      );
      if (bindingResult.traces.any((t) => t.status == RuleTraceStatus.error)) {
        allRuleTraces.add(RuleTrace(
          kind: RuleTraceKind.rule,
          label: rule.title,
          status: RuleTraceStatus.error,
          children: bindingResult.traces,
          reason: 'Binding 无法解析',
        ));
        continue;
      }
      final context = bindingResult.context;
      final result = predicateEvaluator.evaluate(
        rule.condition,
        context,
        currentSnapshot,
      );

      if (result.matched) {
        final contexts = result.matchedBindings.isEmpty
            ? [context]
            : [for (final bindings in result.matchedBindings) BindingContext(bindings)];
        final actionResults = [
          for (final scoped in contexts)
            actionExecutor.execute(
              rule,
              scoped,
              result.supports,
              caseId: caseId,
              ruleRunId: ruleRunId,
              conditionTrace: result.trace,
            ),
        ];
        allRuleTraces.add(RuleTrace(
          kind: RuleTraceKind.rule,
          label: rule.title,
          status: RuleTraceStatus.matched,
          children: [
            ...bindingResult.traces,
            if (result.trace != null) result.trace!,
            for (final actionResult in actionResults) ...actionResult.actionTraces,
          ],
        ));
        for (final actionResult in actionResults) {
          for (final evidence in actionResult.derivedEvidence) {
            if (!allDerivedEvidence.any((item) => item.id == evidence.id)) {
              allDerivedEvidence.add(evidence);
            }
          }
        }
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

        for (final actionResult in actionResults) {
          processFacts(actionResult.derivedFacts, allDerivedFacts);
          processFacts(actionResult.derivedStates, allDerivedStates);
          processFacts(actionResult.tags, allTags);
          processFacts(actionResult.structures, allStructures);
          processFacts(actionResult.records, allRecords);
        }

        if (anyNewFact) {
          for (final actionResult in actionResults) {
            for (final hit in actionResult.ruleHits) {
              if (!allRuleHits.any((h) => h.hitId == hit.hitId)) { allRuleHits.add(hit); }
            }
            allEvidenceNodes.addAll(actionResult.evidenceNodes);
            allEvidenceEdges.addAll(actionResult.evidenceEdges);
          }
        }
      } else {
        allRuleTraces.add(RuleTrace(
          kind: RuleTraceKind.rule,
          label: rule.title,
          status: RuleTraceStatus.notMatched,
          children: [
            ...bindingResult.traces,
            if (result.trace != null) result.trace!,
          ],
        ));
      }
    }
    return stageChanged;
  }
}
