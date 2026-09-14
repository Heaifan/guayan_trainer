library;

import '../core/rule_id.dart';
import '../core/rule_version.dart';

/// 规则命中的凭证。
class RuleHit {
  const RuleHit({
    required this.ruleId,
    required this.version,
    required this.boundEntities,
  });

  /// 命中的规则
  final RuleId ruleId;

  /// 命中的版本
  final RuleVersion version;

  /// 命中时绑定的具体实体标识
  /// 例如 {'A': 'line/2', 'M': 'calendar/month'}
  final Map<String, String> boundEntities;
}
