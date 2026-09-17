library;

import '../facts/derived_fact.dart';
import '../facts/structure_fact.dart';

/// 将已经确认成立的结构事实投影为稳定的派生事实。
class DerivedFactProducer {
  const DerivedFactProducer();

  List<DerivedFact> fromStructures(Iterable<StructureFact> structures) {
    return structures
        .where((structure) => structure.state == StructureState.formed)
        .map(
          (structure) => DerivedFact(
            id: 'derived.structure.${structure.id}',
            type: 'structure.formed',
            value: structure.element,
            sourceIds: [structure.id, ...structure.memberObjectIds],
          ),
        )
        .toList(growable: false);
  }
}
