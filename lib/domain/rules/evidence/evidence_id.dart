library;

import 'dart:convert';
import '../facts/semantic_ref.dart';

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
    required Map<String, SemanticRef> bindings,
    required String conclusion,
    required List<EvidenceId> supports,
  }) {
    // 强制顺序
    final bindingKeys = bindings.keys.toList()..sort();
    final bindingsPayload = <List<String>>[];
    for (final k in bindingKeys) {
      final ref = bindings[k]!;
      bindingsPayload.add([k, ref.kind, ref.key]);
    }

    final supportIds = supports.map((s) => s.id).toList()..sort();

    // 采用结构化 Canonical Payload 并 JSON 序列化，杜绝拼接碰撞
    final payload = [
      ruleId,
      version,
      bindingsPayload,
      conclusion,
      supportIds,
    ];

    return EvidenceId(jsonEncode(payload));
  }

  @override
  String toString() => id;
}
