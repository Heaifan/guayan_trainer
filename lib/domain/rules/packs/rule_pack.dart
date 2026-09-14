library;

import '../core/rule_id.dart';
import '../core/rule_origin.dart';
import '../core/rule_version.dart';
import 'rule_pack_id.dart';
import 'rule_pack_scope.dart';

/// RulePack 契约。
/// RulePack 仅通过关联 RuleId 的方式组合规则，作用域只有 COMMON/TOPIC 两个正交维度，
/// 来源 origin 可能是 CUSTOM 或 SYSTEM。
class RulePack {
  RulePack({
    required this.packId,
    required this.version,
    required this.origin,
    required this.scope,
    this.topicId,
    required this.title,
    required this.ruleIds,
  }) {
    if (scope == RulePackScope.COMMON && topicId != null) {
      throw ArgumentError('COMMON scope cannot have a topicId');
    }
    if (scope == RulePackScope.TOPIC && topicId == null) {
      throw ArgumentError('TOPIC scope must have a topicId');
    }
  }

  final RulePackId packId;
  final RuleVersion version;
  final RuleOrigin origin;
  final RulePackScope scope;
  final String? topicId;
  final String title;
  final List<RuleId> ruleIds;
}
