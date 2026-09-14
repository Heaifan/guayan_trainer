// ignore_for_file: constant_identifier_names
library;

/// RulePack 的作用域枚举：全局公共 (COMMON) 或 主题特定 (TOPIC)。
enum RulePackScope {
  COMMON,
  TOPIC;

  Map<String, Object?> toJson() => {'name': name};

  static RulePackScope fromJson(Map<String, Object?> json) => 
      RulePackScope.values.byName(json['name'] as String);
}
