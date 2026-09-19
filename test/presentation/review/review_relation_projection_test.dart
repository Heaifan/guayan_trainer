import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/presentation/review/review_relation_projection.dart';

void main() {
  test('projects only four renderer relation types in stable identity order', () {
    final records = [
      _record('ke', RelationType.ke),
      _record('flying', RelationType.flyingOvercomesHidden),
      _record('return-ke', RelationType.huiTouKe),
      _record('sheng', RelationType.sheng),
      _record('return-sheng', RelationType.huiTouSheng),
      _record('chong', RelationType.liuChong),
      _record('moving', RelationType.dongBian),
    ];

    final projected = ReviewRelationProjection.fromRecords(records);

    expect(projected.map((item) => item.record.id), [
      'ke',
      'return-ke',
      'return-sheng',
      'sheng',
    ]);
    expect(projected.map((item) => item.kind), [
      ReviewRelationKind.overcomes,
      ReviewRelationKind.returnOvercomes,
      ReviewRelationKind.returnGenerates,
      ReviewRelationKind.generates,
    ]);
    expect(projected.every((item) => item.record.evidence.isNotEmpty), isTrue);
  });
}

RelationRecord _record(String id, RelationType type) => RelationRecord.relation(
  id: id,
  sourceKind: RelationSourceKind.fact,
  relationType: type,
  fromRef: YaoEndpoint(LineScope.original, 3),
  toRef: YaoEndpoint(LineScope.original, 6),
  title: type.displayName,
  evidence: ['candidate:$id', 'effective'],
);
