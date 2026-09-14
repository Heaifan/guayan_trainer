// ignore_for_file: constant_identifier_names
library;

import '../ast/rule_action.dart';
import '../ast/rule_binding.dart';
import '../ast/rule_expr.dart';
import 'rule_id.dart';
import 'rule_origin.dart';
import 'rule_stage.dart';
import 'rule_version.dart';

/// 审核状态，预留给未来 AI 导入等场景。
enum ReviewState { PENDING, APPROVED, REJECTED }

/// 规范化规则定义模型，纯数据契约。
/// 不包含 evaluator、callback、script 等任何可执行逻辑代码。
class RuleDefinition {
  const RuleDefinition({
    required this.ruleId,
    required this.version,
    required this.origin,
    required this.namespace,
    required this.categoryId,
    required this.stage,
    required this.title,
    required this.description,
    required this.provenance,
    required this.bindings,
    required this.condition,
    required this.actions,
    this.overrideTarget,
    this.enabled = true,
    this.reviewState = ReviewState.APPROVED,
    this.schemaVersion = 1,
  });

  final RuleId ruleId;
  final RuleVersion version;
  final RuleOrigin origin;
  final String namespace;
  final String categoryId;
  final RuleStage stage;
  final String title;
  final String description;
  final String provenance;
  final List<RuleBinding> bindings;
  final RuleExpr condition;
  final List<RuleAction> actions;
  final RuleId? overrideTarget;
  final bool enabled;
  final ReviewState reviewState;
  final int schemaVersion;

  // JSON 序列化在 T3 Codec 阶段统一实现
}
