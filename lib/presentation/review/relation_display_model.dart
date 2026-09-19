import '../../domain/relation_type.dart';
import '../../domain/relations/relation_record.dart';

enum RelationVisualStyle { solid, returnDashed, flyingDotted }

class RelationDisplayModel {
  const RelationDisplayModel({
    required this.record,
    required this.category,
    required this.visualStyle,
    required this.status,
    required this.evidence,
  });

  final RelationRecord record;
  final String category;
  final RelationVisualStyle visualStyle;
  final String status;
  final List<String> evidence;

  RelationType get type => record.relationType!;
  String get title => record.title;
  bool get isOrdinaryWuxing =>
      type == RelationType.sheng || type == RelationType.ke;
  bool get isSpecial => switch (type) {
    RelationType.huiTouSheng ||
    RelationType.huiTouKe ||
    RelationType.flyingGeneratesHidden ||
    RelationType.flyingOvercomesHidden ||
    RelationType.hiddenGeneratesFlying ||
    RelationType.hiddenOvercomesFlying => true,
    _ => false,
  };

  static RelationDisplayModel fromRecord(RelationRecord record) {
    final type = record.relationType!;
    return RelationDisplayModel(
      record: record,
      category: _category(type),
      visualStyle: _style(type),
      status: '有效',
      evidence: _evidence(type, record),
    );
  }
}

List<RelationDisplayModel> buildRelationDisplayModels(
  Iterable<RelationRecord> records,
) => [
  for (final record in records)
    if (record.kind == RelationKind.relation && record.relationType != null)
      if (_isVisibleType(record.relationType!))
      RelationDisplayModel.fromRecord(record),
];

bool _isVisibleType(RelationType type) => type != RelationType.dongBian;

Map<String, int> relationFilterCounts(Iterable<RelationRecord> records) {
  final models = buildRelationDisplayModels(records);
  return {
    '全部': models.length,
    '生克': models.where((model) => model.isOrdinaryWuxing).length,
    '特殊': models.where((model) => model.isSpecial).length,
  };
}

String _category(RelationType type) => switch (type) {
  RelationType.sheng || RelationType.ke => '生克',
  RelationType.huiTouSheng ||
  RelationType.huiTouKe ||
  RelationType.flyingGeneratesHidden ||
  RelationType.flyingOvercomesHidden ||
  RelationType.hiddenGeneratesFlying ||
  RelationType.hiddenOvercomesFlying => '特殊',
  _ => '其他',
};

RelationVisualStyle _style(RelationType type) => switch (type) {
  RelationType.huiTouSheng ||
  RelationType.huiTouKe => RelationVisualStyle.returnDashed,
  RelationType.flyingGeneratesHidden ||
  RelationType.flyingOvercomesHidden ||
  RelationType.hiddenGeneratesFlying ||
  RelationType.hiddenOvercomesFlying => RelationVisualStyle.flyingDotted,
  _ => RelationVisualStyle.solid,
};

List<String> _evidence(RelationType type, RelationRecord record) {
  if (record.evidence.isNotEmpty) return record.evidence;
  return switch (type) {
    RelationType.huiTouSheng => ['变爻生同位原动爻', '原动爻得助，保留主动作用资格'],
    RelationType.huiTouKe => ['变爻克同位原动爻', '原动爻受制，主动生克已被抑制'],
    RelationType.flyingGeneratesHidden => ['飞神生伏神', '生扶证据，不自动出伏'],
    RelationType.flyingOvercomesHidden => ['飞神克伏神', '飞神压制证据，不自动永久封锁'],
    RelationType.hiddenGeneratesFlying => ['伏神生飞神', '飞伏作用事实，不直接决定出伏'],
    RelationType.hiddenOvercomesFlying => ['伏神克飞神', '飞神压制解除证据，不自动出伏'],
    _ => const ['五行关系已通过作用权结算'],
  };
}
