import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rules/facts/canonical_fact_snapshot_builder.dart';
import 'package:guayan_trainer/domain/rules/objects/dynamic_object_resolver.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';

HexagramCase _case({bool missingBranch = false}) {
  const movements = [
    MovementType.shaoYin,
    MovementType.shaoYang,
    MovementType.laoYin,
    MovementType.shaoYang,
    MovementType.laoYang,
    MovementType.shaoYin,
  ];
  final chart = CastingEngine.cast(movements);
  return HexagramCase(
    id: 'case-canonical',
    question: '测试',
    createdAt: DateTime(2026, 9, 18),
    lines: [
      for (final line in chart.lines)
        LineState(
          position: line.position,
          movementType: movements[line.position - 1],
          branch: missingBranch && line.position == 5 ? null : line.branch.label,
          changedBranch: line.changedBranch?.label,
        ),
    ],
  );
}

void main() {
  test('real Case builds six complete line candidates', () {
    final snapshot = CanonicalFactSnapshotBuilder.build(_case());
    final all = const DynamicObjectResolver().resolve(
      const DynamicBindingSelector(selectorId: 'dynamic.line.all'),
      snapshot,
    );

    expect(all.candidates, hasLength(6));
    expect(snapshot.getFact('branch-5')?.value.value, '酉');
    expect(snapshot.getFact('branch-3')?.value.value, '午');
    expect(snapshot.getFact('relative-3')?.value.value, isNotNull);
    expect(
      const DynamicObjectResolver().resolve(
        const DynamicBindingSelector(
          selectorId: 'dynamic.line.by_spirit',
          parameters: {'spirit': 'spirit.bai_hu'},
        ),
        snapshot,
      ).candidates,
      hasLength(1),
    );
  });

  test('missing Case facts are a context error, not a normal no-match', () {
    expect(
      () => CanonicalFactSnapshotBuilder.build(_case(missingBranch: true)),
      throwsA(isA<StateError>()),
    );
  });
}
