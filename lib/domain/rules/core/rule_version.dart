library;

/// 规则的版本号。
/// 使用 semantic versioning 的字符串形式。
class RuleVersion {
  const RuleVersion(this.version);

  final String version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleVersion && other.version == version;

  @override
  int get hashCode => version.hashCode;

  String toJson() => version;

  factory RuleVersion.fromJson(String json) => RuleVersion(json);

  @override
  String toString() => version;
}
