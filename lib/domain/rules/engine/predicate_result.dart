library;

import '../evidence/evidence_id.dart';

/// 谓词评估结果
class PredicateResult {
  const PredicateResult({
    required this.matched,
    this.supports = const [],
  });

  final bool matched;
  final List<EvidenceId> supports;

  /// 当未匹配时，返回固定的失败结果
  static const PredicateResult fail = PredicateResult(matched: false);

  /// 成功时携带证据返回
  factory PredicateResult.match(List<EvidenceId> supports) {
    return PredicateResult(matched: true, supports: supports);
  }
}
