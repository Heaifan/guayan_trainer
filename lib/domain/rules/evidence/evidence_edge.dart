library;

import 'evidence_id.dart';

/// Evidence 图中的边。
class EvidenceEdge {
  const EvidenceEdge({
    required this.sourceId,
    required this.targetId,
    required this.relationType,
  });

  final EvidenceId sourceId;
  final EvidenceId targetId;

  /// 关系的类型，例如 "derives_to", "supports"
  final String relationType;
}
