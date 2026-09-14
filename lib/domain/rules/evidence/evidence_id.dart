library;

/// Evidence 的稳定身份标识。
class EvidenceId {
  const EvidenceId(this.id);

  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvidenceId && other.id == id;

  @override
  int get hashCode => id.hashCode;

  String toJson() => id;

  factory EvidenceId.fromJson(String json) => EvidenceId(json);

  /// 生成基于内容的 Canonical Identity
  factory EvidenceId.canonical({
    required String ruleId,
    required String version,
    required Map<String, String> bindings,
    required String conclusion,
    required List<EvidenceId> supports,
  }) {
    // 强制顺序
    final bindingKeys = bindings.keys.toList()..sort();
    final bindingStr = bindingKeys.map((k) => '$k=${bindings[k]}').join(',');

    final supportIds = supports.map((s) => s.id).toList()..sort();
    final supportStr = supportIds.join(',');

    // 简单拼接做hash或直接作为id（这里用拼接演示）
    return EvidenceId('$ruleId@$version|bindings[$bindingStr]|concl[$conclusion]|supp[$supportStr]');
  }

  @override
  String toString() => id;
}
