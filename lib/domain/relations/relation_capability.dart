import '../relation_type.dart';
import 'relation_record.dart';

class RelationCapabilitySnapshot {
  const RelationCapabilitySnapshot({
    required this.supportedRelations,
    required this.supportedStates,
  });

  factory RelationCapabilitySnapshot.fromRecords(
    Iterable<RelationRecord> records,
  ) {
    final relations = <RelationType>{};
    final states = <RelationStateType>{};
    for (final record in records) {
      if (record.kind == RelationKind.relation &&
          record.relationType != null) {
        relations.add(record.relationType!);
      }
      if (record.kind == RelationKind.state && record.stateType != null) {
        states.add(record.stateType!);
      }
    }
    return RelationCapabilitySnapshot(
      supportedRelations: Set.unmodifiable(relations),
      supportedStates: Set.unmodifiable(states),
    );
  }

  final Set<RelationType> supportedRelations;
  final Set<RelationStateType> supportedStates;
}
