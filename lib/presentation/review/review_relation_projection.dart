import '../../domain/relation_resolution_model.dart';
import '../../domain/relation_type.dart';
import '../../domain/relations/relation_record.dart';

enum ReviewRelationKind {
  generates,
  overcomes,
  returnGenerates,
  returnOvercomes,
}

class ReviewRelation {
  const ReviewRelation({required this.record, required this.kind});

  final RelationRecord record;
  final ReviewRelationKind kind;
}

abstract final class ReviewRelationProjection {
  static List<ReviewRelation> project(
    Iterable<RelationResolutionEntry> entries,
  ) => fromRecords([
    for (final entry in entries)
      _recordFromEntry(entry),
  ]);

  static List<ReviewRelation> fromRecords(Iterable<RelationRecord> records) {
    final projected = <ReviewRelation>[];
    for (final record in records) {
      final kind = _kindFor(record.relationType);
      if (kind != null) projected.add(ReviewRelation(record: record, kind: kind));
    }
    projected.sort((a, b) => a.record.id.compareTo(b.record.id));
    return List.unmodifiable(projected);
  }

  static RelationRecord _recordFromEntry(RelationResolutionEntry entry) =>
      RelationRecord.relation(
        id: entry.relation.key.canonical,
        sourceKind: RelationSourceKind.fact,
        relationType: entry.relation.type,
        fromRef: entry.relation.source,
        toRef: entry.relation.target,
        title: entry.relation.type.displayName,
        evidence: [entry.reason],
      );

  static ReviewRelationKind? _kindFor(RelationType? type) => switch (type) {
    RelationType.sheng => ReviewRelationKind.generates,
    RelationType.ke => ReviewRelationKind.overcomes,
    RelationType.huiTouSheng => ReviewRelationKind.returnGenerates,
    RelationType.huiTouKe => ReviewRelationKind.returnOvercomes,
    _ => null,
  };
}
