import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/domain/cases/casting_snapshot.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/cast_chart.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/presentation/review/review_case_adapter.dart';
import 'package:guayan_trainer/presentation/review/review_relation_filter.dart';
import 'package:guayan_trainer/presentation/review/widgets/relation_overlay.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';

void main() {
  test('restored real cast keeps line 5 back-generate through review state', () {
    final fixture = _findEarthToFireCast();
    final time = DateTime(2026, 9, 18, 22, 31);
    final record = CaseRecord.create(
      id: 'back-generate-real',
      snapshot: CastingSnapshot(
        castingTime: time,
        subject: '真实回头生案例',
        lines: [
          for (final line in fixture.chart.lines)
            LineState(
              position: line.position,
              movementType: fixture.movements[line.position - 1],
              branch: line.branch.label,
            ),
        ],
        originalHexagramName: fixture.chart.original.name,
        changedHexagramName: fixture.chart.changed?.name,
        movingPositions: fixture.chart.movingPositions,
      ),
      createdAt: time,
      originalRuleRun: RuleRun.original(
        executedAt: time,
        ruleContext: const RuleExecutionContext.empty(),
        result: const {},
        evidence: const [],
      ),
    );

    final restored = record.toHexagramCase();
    final state = ReviewCaseAdapter.adapt(restored);
    final back = state.allRelations.where(
      (relation) => relation.type == RelationType.huiTouSheng,
    );

    // The fifth displayed row is domain position 2 (displayLines is reversed).
    expect(restored.lineAt(2).movementType.isMoving, isTrue);
    expect(restored.lineAt(2).branch, isNotNull);
    expect(restored.lineAt(2).changedBranch, isNotNull);
    expect(back, hasLength(1));
    expect(back.single.source, YaoEndpoint(LineScope.changed, 2));
    expect(back.single.target, YaoEndpoint(LineScope.original, 2));

    final records = state.relationRecords.where(
      (record) => record.relationType == RelationType.huiTouSheng,
    );
    expect(records, hasLength(1));
    expect(
      filterReviewRelationRecords(state.relationRecords, category: '特殊'),
      contains(records.single),
    );
    expect(
      RelationOverlay.visibleRecords(
        state.relationRecords,
        focus: YaoEndpoint(LineScope.original, 2),
        category: '特殊',
      ),
      contains(records.single),
    );
  });

test('real line 5 丑土 <- 午火 reaches Review Relation State', () {
  final case_ = HexagramCase(
    id: 'line-5-back-generate',
    question: '官鬼己丑土变妻财丙午火',
    createdAt: DateTime(2026, 9, 18),
    lines: [
      LineState(position: 1, movementType: MovementType.shaoYin, branch: '子'),
      LineState(position: 2, movementType: MovementType.shaoYin, branch: '寅'),
      LineState(position: 3, movementType: MovementType.shaoYin, branch: '辰'),
      LineState(position: 4, movementType: MovementType.shaoYin, branch: '巳'),
      LineState(
        position: 5,
        movementType: MovementType.laoYang,
        branch: '丑',
        changedBranch: '午',
      ),
      LineState(position: 6, movementType: MovementType.shaoYin, branch: '未'),
    ],
  );

  final state = ReviewCaseAdapter.adapt(case_);
  final relation = state.allRelations.singleWhere(
    (item) => item.type == RelationType.huiTouSheng,
  );

  expect(relation.source, YaoEndpoint(LineScope.changed, 5));
  expect(relation.target, YaoEndpoint(LineScope.original, 5));
  expect(
    state.relationRecords.any(
      (record) => record.relationType == RelationType.huiTouSheng,
    ),
    isTrue,
  );
});
}

({List<MovementType> movements, CastChart chart}) _findEarthToFireCast() {
  for (var mask = 0; mask < 4096; mask++) {
    final movements = [
      for (var position = 0; position < 6; position++)
        MovementType.values[(mask >> (position * 2)) & 3],
    ];
    final chart = CastingEngine.cast(movements);
    final line = chart.lineAt(2);
    if (line.isMoving &&
        line.branch.wuXing.label == '土' &&
        line.changedBranch?.wuXing.label == '火') {
      return (movements: movements, chart: chart);
    }
  }
  throw StateError('missing casting fixture with moving Earth -> Fire');
}
