library;

import '../core/rule_id.dart';
import '../core/rule_version.dart';
import '../facts/semantic_ref.dart';
import 'evidence_id.dart';

/// 规则命中的凭证。
class RuleHit {
  const RuleHit({
    required this.hitId,
    required this.ruleId,
    required this.ruleVersion,
    required this.bindings,
    required this.conclusions,
    required this.supports,
  });

  /// 凭证ID
  final EvidenceId hitId;

  /// 命中的规则
  final RuleId ruleId;

  /// 命中的版本
  final RuleVersion ruleVersion;

  /// 命中时绑定的具体实体标识
  final Map<String, SemanticRef> bindings;

  /// 结论
  final List<String> conclusions;

  /// 支持证据
  final List<EvidenceId> supports;
}
