library;

/// 正式冻结的层级概念（规则阶段）。
/// Original Fact 不是规则阶段，而是引擎输入。
enum RuleStage {
  baseRelation,
  derivedState,
  structure,
  tag;

  Map<String, Object?> toJson() => {'name': name};

  static RuleStage fromJson(Map<String, Object?> json) => 
      RuleStage.values.byName(json['name'] as String);
}
