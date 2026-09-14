// ignore_for_file: constant_identifier_names
library;

/// 规则来源枚举，当前仅区分系统和自定义。
enum RuleOrigin {
  /// 系统预置内置规则
  SYSTEM,

  /// 用户自定义规则
  CUSTOM;

  Map<String, Object?> toJson() => {'name': name};

  static RuleOrigin fromJson(Map<String, Object?> json) =>
      RuleOrigin.values.byName(json['name'] as String);
}
