library;

import '../core/rule_definition.dart';
import '../core/rule_origin.dart';
import 'custom_rule_store.dart';
import 'user_governance_state.dart';

class CustomRuleService {
  final CustomRuleStore store;
  final UserGovernanceState governance;

  CustomRuleService(this.store, this.governance);

  Future<void> load() async {
    await store.load();
    await governance.load();
  }

  /// 合并 SYSTEM 与 CUSTOM 规则，并应用 Governance 状态
  List<RuleDefinition> getMergedRules(List<RuleDefinition> systemRules) {
    final result = <RuleDefinition>[];

    // 注入 SYSTEM 规则（如果被 Disable，克隆一份 enabled = false）
    for (final sys in systemRules) {
      if (sys.origin != RuleOrigin.SYSTEM) continue;
      if (governance.isSystemRuleDisabled(sys.ruleId)) {
        result.add(_cloneWithEnabled(sys, false));
      } else {
        result.add(sys);
      }
    }

    // 注入 CUSTOM 规则
    result.addAll(store.getAll());

    return result;
  }

  static RuleDefinition _cloneWithEnabled(RuleDefinition r, bool enabled) {
    return RuleDefinition(
      ruleId: r.ruleId,
      version: r.version,
      origin: r.origin,
      namespace: r.namespace,
      categoryId: r.categoryId,
      stage: r.stage,
      title: r.title,
      description: r.description,
      provenance: r.provenance,
      bindings: r.bindings,
      condition: r.condition,
      actions: r.actions,
      overrideTarget: r.overrideTarget,
      reviewState: r.reviewState,
      schemaVersion: r.schemaVersion,
      enabled: enabled,
    );
  }
}
