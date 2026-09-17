import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/facts/structure_fact.dart';
import 'package:guayan_trainer/domain/rules/structures/san_he_structure_resolver.dart';

void main() {
  test('san-he resolver produces formed structure and members', () {
    final snapshot = FactSnapshot.build([
      _fact('3', '申'),
      _fact('4', '子'),
      _fact('5', '辰'),
    ]);
    final result = const SanHeStructureResolver().resolve(snapshot);
    expect(result, hasLength(1));
    expect(result.single.kind, StructureKind.sanHe);
    expect(result.single.state, StructureState.formed);
    expect(result.single.element, '水');
    expect(
      result.single.memberObjectIds,
      containsAll(['line/3', 'line/4', 'line/5']),
    );
  });
}

FactRecord _fact(String line, String branch) => FactRecord(
  factId: 'branch-$line',
  subject: SemanticRef('line', line),
  predicateId: 'branch',
  value: RuleValue.string(branch),
  origin: FactOrigin.baseRelation,
);
