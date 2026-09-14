library;

/// RulePack 标识符。
class RulePackId {
  const RulePackId(this.id);

  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RulePackId && other.id == id;

  @override
  int get hashCode => id.hashCode;

  String toJson() => id;

  factory RulePackId.fromJson(String json) => RulePackId(json);

  @override
  String toString() => id;
}
