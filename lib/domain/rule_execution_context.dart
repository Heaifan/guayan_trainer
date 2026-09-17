/// 规则执行上下文（Rule Version Replay Contract）。
///
/// 由于 RelationKey 将 RuleVersion 纳入身份，旧卦例重算时必须能复现
/// 「当时各规则使用的版本」，否则系统升级规则后历史 RelationKey 变化、
/// 旧笔记将无法重新绑定（关系重算失忆）。
///
/// 契约：
/// - 可 JSON 持久化，跟随 HexagramCase 保存；
/// - 明确记录必要 RuleId + RuleVersion；
/// - 不依赖当前全局最新版规则（replay 优先使用本上下文）。
library;

/// 单条规则的版本快照。
class RuleVersionRef {
  const RuleVersionRef(this.ruleId, this.version);

  /// 规则稳定身份（`sys.*` 或自定义 JSON `id`）。
  final String ruleId;

  /// 该卦例计算关系时使用的规则版本（>= 1）。
  final int version;

  Map<String, Object> toJson() => {'ruleId': ruleId, 'version': version};

  factory RuleVersionRef.fromJson(Map<String, Object?> json) =>
      RuleVersionRef(json['ruleId'] as String, json['version'] as int);

  @override
  bool operator ==(Object other) =>
      other is RuleVersionRef &&
      other.ruleId == ruleId &&
      other.version == version;

  @override
  int get hashCode => Object.hash(ruleId, version);
}

class RulePackVersionRef {
  const RulePackVersionRef(this.packId, this.version);

  final String packId;
  final String version;

  Map<String, String> toJson() => {'packId': packId, 'version': version};

  factory RulePackVersionRef.fromJson(Map<String, Object?> json) =>
      RulePackVersionRef(json['packId'] as String, json['version'] as String);

  @override
  bool operator ==(Object other) =>
      other is RulePackVersionRef &&
      other.packId == packId &&
      other.version == version;

  @override
  int get hashCode => Object.hash(packId, version);
}

/// 卦例级规则版本快照（最小 replay 上下文）。
class RuleExecutionContext {
  /// 空上下文：无版本记录（旧数据 / 未启用规则上下文）。
  const RuleExecutionContext.empty()
      : refs = const [],
        packRefs = const [];

  /// 带版本记录的上下文；重复 ruleId 或非法版本直接拒绝（runtime 校验）。
  RuleExecutionContext(this.refs, {this.packRefs = const []}) {
    final seen = <String>{};
    for (final ref in refs) {
      if (!seen.add(ref.ruleId)) {
        throw ArgumentError('RuleExecutionContext 中 ruleId 重复: ${ref.ruleId}');
      }
      if (ref.version < 1) {
        throw ArgumentError.value(ref.version, 'version', '规则版本必须 >= 1');
      }
    }
  }

  final List<RuleVersionRef> refs;
  final List<RulePackVersionRef> packRefs;

  /// 查询某规则在此卦例中使用的版本；无记录返回 null。
  int? versionFor(String ruleId) {
    for (final ref in refs) {
      if (ref.ruleId == ruleId) return ref.version;
    }
    return null;
  }

  /// 查询版本并回退默认值（无记录时使用 [fallback]）。
  int versionForOrDefault(String ruleId, {int fallback = 1}) =>
      versionFor(ruleId) ?? fallback;

  Map<String, Object?> toJson() => {
    'refs': refs.map((r) => r.toJson()).toList(),
    'packRefs': packRefs.map((r) => r.toJson()).toList(),
  };

  factory RuleExecutionContext.fromJson(Map<String, Object?> json) {
    final refs = (json['refs'] as List<Object?>? ?? const [])
        .map((e) => RuleVersionRef.fromJson(e as Map<String, Object?>))
        .toList();
    final packRefs = (json['packRefs'] as List<Object?>? ?? const [])
        .map((e) => RulePackVersionRef.fromJson(e as Map<String, Object?>))
        .toList();
    return refs.isEmpty && packRefs.isEmpty
        ? const RuleExecutionContext.empty()
        : RuleExecutionContext(refs, packRefs: packRefs);
  }

  @override
  bool operator ==(Object other) =>
      other is RuleExecutionContext &&
      other.refs.length == refs.length &&
      other.refs.every((r) => refs.contains(r)) &&
      other.packRefs.length == packRefs.length &&
      other.packRefs.every((r) => packRefs.contains(r));

  @override
  int get hashCode => Object.hashAll(refs);
}
