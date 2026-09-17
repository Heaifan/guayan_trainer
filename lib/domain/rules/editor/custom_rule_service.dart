library;
import '../core/rule_definition.dart';
import '../core/rule_origin.dart';
import 'custom_rule_store.dart';
import 'user_governance_state.dart';
import 'custom_rule_save_boundary.dart';
import '../vocabulary/condition_registry.dart';
import '../ast/rule_expr.dart';
import '../governance/rule_resolver.dart';

class CustomRuleService {
  final CustomRuleStore store;
  final UserGovernanceState governance;

  CustomRuleService(this.store, this.governance);

  Future<void> load() async {
    await store.load();
    await governance.load();
  }

  List<RuleDefinition> getMergedRules(List<RuleDefinition> systemRules) {
    final result = <RuleDefinition>[];
    for (final sys in systemRules) {
      if (sys.origin != RuleOrigin.SYSTEM) continue;
      if (governance.isSystemRuleDisabled(sys.ruleId)) {
        result.add(_cloneWithEnabled(sys, false));
      } else {
        result.add(sys);
      }
    }
    result.addAll(store.getAll());
    return result;
  }

  Future<void> save(RuleDefinition rule, List<RuleDefinition> currentSystemRules) async {
    // 1. Schema Validation using existing registry
    _validateExpr(rule.condition);

    // 2. Boundary Validation（COMMON / topic.* 分发，未知 namespace 拒绝）
    CustomRuleSaveBoundary.validate(rule);

    // 3. RuleResolver Preflight
    final testSet = getMergedRules(currentSystemRules).toList();
    testSet.removeWhere((r) => r.ruleId == rule.ruleId);
    testSet.add(rule);
    RuleResolver.resolve(testSet); // Throws if conflict or invalid override

    // 4. Save
    await store.addOrUpdate(rule);
  }

  void _validateExpr(RuleExpr expr) {
    if (expr is PredicateExpr) {
      final def = CanonicalConditionRegistry.getDefinition(expr.operatorId);
      if (def == null) throw StateError('Unknown operator ${expr.operatorId}');
      if (expr.operands.length != def.operandCount) throw StateError('Operator ${expr.operatorId} needs ${def.operandCount} operands, got ${expr.operands.length}');
    } else if (expr is AllExpr) {
      expr.nodes.forEach(_validateExpr);
    } else if (expr is AnyExpr) {
      expr.nodes.forEach(_validateExpr);
    } else if (expr is NotExpr) {
      _validateExpr(expr.node);
    }
  }

  static RuleDefinition _cloneWithEnabled(RuleDefinition r, bool enabled) {
    return RuleDefinition(
      ruleId: r.ruleId, version: r.version, origin: r.origin,
      namespace: r.namespace, categoryId: r.categoryId, stage: r.stage,
      title: r.title, description: r.description, provenance: r.provenance,
      bindings: r.bindings, condition: r.condition, actions: r.actions,
      overrideTarget: r.overrideTarget, reviewState: r.reviewState,
      schemaVersion: r.schemaVersion,
      enabled: enabled,
    );
  }
}
