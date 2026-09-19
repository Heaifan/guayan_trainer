import '../../domain/relation_endpoint.dart';
import '../../domain/relation_type.dart';
import '../../domain/relations/relation_record.dart';
import 'relation_display_model.dart';

/// 审卦关系的唯一可见集合查询；Toolbar 与 Overlay 必须共用。
List<RelationRecord> filterReviewRelationRecords(
  Iterable<RelationRecord> records, {
  RelationEndpoint? focus,
  String category = '全部',
}) => [
  for (final record in records)
    if (record.kind == RelationKind.relation &&
        record.relationType != null &&
        _isReviewRendererType(record.relationType!) &&
        (focus == null || record.participants.contains(focus)) &&
        _matchesCategory(record, category))
      record,
];

bool _matchesCategory(RelationRecord record, String category) {
  if (category == '全部' || category == '重点') return true;
  final model = RelationDisplayModel.fromRecord(record);
  if (category == '生克') return model.isOrdinaryWuxing;
  if (category == '特殊') return model.isSpecial;
  return record.category == category;
}

bool _isReviewRendererType(RelationType type) => switch (type) {
  RelationType.sheng ||
  RelationType.ke ||
  RelationType.huiTouSheng ||
  RelationType.huiTouKe => true,
  _ => false,
};
