/// 六爻关系类型：稳定机器名 + 方向类别 + 展示名。
///
/// 展示名只用于 UI 展示，绝不参与 RelationKey 构造；
/// RelationKey 只使用 [RelationType.machineName]。
library;

/// 关系方向类别：决定 RelationKey 构造时端点是否规范化排序。
enum RelationDirectionKind {
  /// 有向：A→B 与 B→A 语义不同，key 保留端点顺序。
  directed,

  /// 对称（无向）：A-B 与 B-A 是同一关系，key 对端点排序后入串。
  symmetric,
}

/// 六爻关系类型（首批：总开发计划 §12.1 基础关系子集）。
enum RelationType {
  dongBian('dong_bian', RelationDirectionKind.directed, '动变'),
  huiTouSheng('hui_tou_sheng', RelationDirectionKind.directed, '回头生'),
  huiTouKe('hui_tou_ke', RelationDirectionKind.directed, '回头克'),
  sheng('sheng', RelationDirectionKind.directed, '生'),
  ke('ke', RelationDirectionKind.directed, '克'),
  liuChong('liu_chong', RelationDirectionKind.symmetric, '六冲'),
  liuHe('liu_he', RelationDirectionKind.symmetric, '六合');

  const RelationType(this.machineName, this.directionKind, this.displayName);

  /// 稳定机器名（key 序列化用，永不变更）。
  final String machineName;

  final RelationDirectionKind directionKind;

  /// 展示名（仅 UI 用）。
  final String displayName;

  static RelationType fromMachineName(String name) =>
      values.firstWhere((t) => t.machineName == name);
}

/// 系统计算规则的稳定 RuleId（机器名，非展示标题）。
///
/// 自定义规则（JSON `id` 字段）后续接入，key 机制不变。
abstract final class SystemRuleIds {
  static const dongBian = 'sys.dong_bian';
  static const huiTouSheng = 'sys.hui_tou_sheng';
  static const huiTouKe = 'sys.hui_tou_ke';
  static const sheng = 'sys.sheng';
  static const ke = 'sys.ke';
  static const liuChong = 'sys.liu_chong';
  static const liuHe = 'sys.liu_he';
}
