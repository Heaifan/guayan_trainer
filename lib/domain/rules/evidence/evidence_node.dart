library;

import 'evidence_id.dart';

/// Evidence 图中的节点。
class EvidenceNode {
  const EvidenceNode({
    required this.id,
    required this.label,
    required this.type,
  });

  final EvidenceId id;

  /// 节点的展示标签，例如 "【考试】文书"
  final String label;

  /// 节点类型，例如 tag, rule, fact
  final String type;
}

/// Tag 专属身份契约
class TagIdentity {
  const TagIdentity(this.categoryId, this.tagId);
  final String categoryId;
  final String tagId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagIdentity &&
          other.categoryId == categoryId &&
          other.tagId == tagId;

  @override
  int get hashCode => Object.hash(categoryId, tagId);
}
