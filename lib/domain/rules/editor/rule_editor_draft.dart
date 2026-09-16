library;

import '../core/rule_definition.dart';
import '../core/rule_id.dart';
import '../core/rule_origin.dart';
import '../core/rule_stage.dart';
import '../core/rule_version.dart';
import '../ast/rule_action.dart';
import '../ast/rule_binding.dart';
import '../ast/rule_expr.dart';

class RuleEditorDraft {
  RuleId ruleId;
  RuleVersion version;
  RuleOrigin origin;
  String namespace;
  String categoryId;
  RuleStage stage;
  String title;
  String description;
  String provenance;
  List<RuleBinding> bindings;
  RuleExpr? condition;
  List<RuleAction> actions;
  RuleId? overrideTarget;
  bool enabled;

  RuleEditorDraft.fromDefinition(RuleDefinition r)
    : ruleId = r.ruleId,
      version = r.version,
      origin = r.origin,
      namespace = r.namespace,
      categoryId = r.categoryId,
      stage = r.stage,
      title = r.title,
      description = r.description,
      provenance = r.provenance,
      bindings = List.of(r.bindings),
      condition = r.condition,
      actions = List.of(r.actions),
      overrideTarget = r.overrideTarget,
      enabled = r.enabled;

  RuleDefinition toDefinition() {
    if (condition == null) throw StateError('Condition is empty');
    return RuleDefinition(
      ruleId: ruleId,
      version: version,
      origin: origin,
      namespace: namespace,
      categoryId: categoryId,
      stage: stage,
      title: title,
      description: description,
      provenance: provenance,
      bindings: bindings,
      condition: condition!,
      actions: actions,
      overrideTarget: overrideTarget,
      enabled: enabled,
    );
  }
}
