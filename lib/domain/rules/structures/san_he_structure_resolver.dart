library;

import '../facts/fact_snapshot.dart';
import '../facts/structure_fact.dart';

class SanHeStructureResolver {
  const SanHeStructureResolver();

  List<StructureFact> resolve(FactSnapshot snapshot) {
    final branches = <String, String>{};
    for (final fact in snapshot.facts) {
      if (fact.subject.kind == 'line' && fact.predicateId == 'branch') {
        branches[fact.subject.toString()] = fact.value.value.toString();
      }
    }
    const groups = {
      '水': {'申', '子', '辰'},
      '火': {'寅', '午', '戌'},
      '木': {'亥', '卯', '未'},
      '金': {'巳', '酉', '丑'},
    };
    final results = <StructureFact>[];
    for (final entry in groups.entries) {
      final members = branches.entries
          .where((item) => entry.value.contains(item.value))
          .map(
            (item) =>
                item.key.replaceFirst('SemanticRef(', '').replaceFirst(')', ''),
          )
          .toList();
      if (members.length == 3) {
        results.add(
          StructureFact(
            id: 'san_he_${entry.key}',
            kind: StructureKind.sanHe,
            state: StructureState.formed,
            element: entry.key,
            memberObjectIds: members,
          ),
        );
      }
    }
    return results;
  }
}
