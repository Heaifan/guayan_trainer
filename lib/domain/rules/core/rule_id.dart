library;

/// 规则的稳定身份标识。
/// 必须是可读的字符串，如 "core.relation.branch.clash"。
class RuleId {
  const RuleId(this.id);

  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleId && other.id == id;

  @override
  int get hashCode => id.hashCode;

  String toJson() => id;

  factory RuleId.fromJson(String json) => RuleId(json);

  @override
  String toString() => id;
}
