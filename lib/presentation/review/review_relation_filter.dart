import '../../domain/relation_endpoint.dart';
import '../../domain/relations/relation_record.dart';

/// 审卦关系的唯一可见集合查询；Toolbar 与 Overlay 必须共用。
List<RelationRecord> filterReviewRelationRecords(
  Iterable<RelationRecord> records, {
  RelationEndpoint? focus,
  String category = '全部',
}) => [
  for (final record in records)
    if (record.kind == RelationKind.relation &&
        record.relationType != null &&
        (focus == null || record.participants.contains(focus)) &&
        (category == '全部' || category == '重点' || record.category == category))
      record,
];
