library;

/// Canonical Rule 中使用的有限、JSON-safe 的值模型。
/// 限制只能包含基础类型或特定的 stable token 字符串，
/// 绝对禁止传入 Function、闭包、或任何带有行为的 Dart 对象。
class RuleValue {
  const RuleValue._(this.value);

  /// 实际存储的值，只能是 JSON 兼容的基础类型。
  final Object? value;

  /// 构造字符串。也用于构造六亲、六神、五行等地支的 stable token。
  /// 例如 "relative.parent", "branch.mao"
  factory RuleValue.string(String val) => RuleValue._(val);

  factory RuleValue.integer(int val) => RuleValue._(val);

  factory RuleValue.number(double val) => RuleValue._(val);

  factory RuleValue.boolean(bool val) => RuleValue._(val);

  factory RuleValue.nullValue() => const RuleValue._(null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleValue && other.value == value;

  @override
  int get hashCode => value.hashCode;

  Object? toJson() => value;

  factory RuleValue.fromJson(Object? json) {
    if (json == null) return RuleValue.nullValue();
    if (json is String || json is int || json is double || json is bool) {
      return RuleValue._(json);
    }
    throw ArgumentError('不支持的 RuleValue 类型: ${json.runtimeType}');
  }

  @override
  String toString() => 'RuleValue($value)';
}
