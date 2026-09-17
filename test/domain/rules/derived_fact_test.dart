import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/engine/derived_fact_producer.dart';
import 'package:guayan_trainer/domain/rules/facts/structure_fact.dart';

void main() {
  test('formed structure becomes a stable derived fact with evidence', () {
    const structure = StructureFact(
      id: 'structure.san_he.water',
      kind: StructureKind.sanHe,
      state: StructureState.formed,
      element: '水',
      memberObjectIds: ['line/1', 'line/3', 'line/5'],
    );

    final derived = const DerivedFactProducer().fromStructures([structure]);

    expect(derived, hasLength(1));
    expect(derived.single.id, 'derived.structure.structure.san_he.water');
    expect(derived.single.type, 'structure.formed');
    expect(derived.single.value, '水');
    expect(derived.single.sourceIds, [
      'structure.san_he.water',
      'line/1',
      'line/3',
      'line/5',
    ]);
  });

  test('unformed structure is not emitted', () {
    const structure = StructureFact(
      id: 'structure.san_he.water',
      kind: StructureKind.sanHe,
      state: StructureState.unformed,
      element: '水',
      memberObjectIds: ['line/1', 'line/3'],
    );

    expect(const DerivedFactProducer().fromStructures([structure]), isEmpty);
  });
}
