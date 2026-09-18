import '../core/rule_definition.dart';
import '../facts/fact_snapshot.dart';
import 'action_executor.dart';
import 'binding_resolver.dart';
import 'predicate_evaluator.dart';
import 'operators/operator_registry.dart';
import 'engine_types.dart';
import 'stage_runner.dart';
import 'analysis_stage_executor.dart';

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
    executor = AnalysisStageExecutor(stageRunner);
  }

  final OperatorRegistry registry;
  final BindingResolver bindingResolver;
  final ActionExecutor actionExecutor;
  late final PredicateEvaluator predicateEvaluator;
  late final StageRunner stageRunner;
  late final AnalysisStageExecutor executor;
  final int maxIterationsPerStage;

  /// 执行规则派生
  AnalysisRun execute(
    List<RuleDefinition> rules,
    FactSnapshot initialSnapshot,
    {
    String caseId = 'preview',
    String ruleRunId = 'in-memory',
    }
  ) {
    return executor.execute(
      rules,
      initialSnapshot,
      caseId: caseId,
      ruleRunId: ruleRunId,
    );
  }
}
