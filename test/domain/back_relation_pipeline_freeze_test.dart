import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/domain/cases/casting_snapshot.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/casting/cast_chart.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/presentation/review/review_case_adapter.dart';
import 'package:guayan_trainer/presentation/review/review_relation_filter.dart';

void main() {
  test('line 6 Earth→Water is back-overcome and reaches Review State', () {
    final c = _directCase(6, original: '子', changed: '未');
    final relations = calculateRelations(c).where(
      (relation) => relation.type == RelationType.huiTouKe,
    );
    final relation = relations.single;
    expect(relation.source, YaoEndpoint(LineScope.changed, 6));
    expect(relation.target, YaoEndpoint(LineScope.original, 6));

    final state = ReviewCaseAdapter.adapt(c);
    final record = state.relationRecords.singleWhere(
      (item) => item.relationType == RelationType.huiTouKe,
    );
    expect(filterReviewRelationRecords(state.relationRecords, category: '全部'), contains(record));
    expect(filterReviewRelationRecords(state.relationRecords, category: '生克'), contains(record));
  });

  test('fresh and legacy-restored Cases produce equivalent back Relations', () {
    final fixture = _findMovingEarthToFire();
    final time = DateTime(2026, 9, 18);
    final fresh = HexagramCase(
      id: 'fresh',
      question: 'equivalence',
      createdAt: time,
      lines: [
        for (final line in fixture.chart.lines)
          LineState(
            position: line.position,
            movementType: fixture.movements[line.position - 1],
            branch: line.branch.label,
            changedBranch: line.changedBranch?.label,
          ),
      ],
    );
    final legacy = CaseRecord.create(
      id: 'legacy',
      snapshot: CastingSnapshot(
        castingTime: time,
        subject: 'equivalence',
        lines: [
          for (final line in fresh.lines)
            LineState(
              position: line.position,
              movementType: line.movementType,
              branch: line.branch,
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
    final restored = legacy.toHexagramCase();
    final freshBack = _backKeys(fresh);
    final restoredBack = _backKeys(restored);
    expect(restored.lineAt(2).changedBranch, fresh.lineAt(2).changedBranch);
    expect(restoredBack, freshBack);
  });
}

HexagramCase _directCase(int position, {required String original, required String changed}) => HexagramCase(
  id: 'direct-$position',
  question: 'freeze',
  createdAt: DateTime(2026, 9, 18),
  lines: [
    for (var i = 1; i <= 6; i++)
      LineState(
        position: i,
        movementType: i == position ? MovementType.laoYang : MovementType.shaoYang,
        branch: i == position ? original : '卯',
        changedBranch: i == position ? changed : null,
      ),
  ],
);

Set<String> _backKeys(HexagramCase c) => {
  for (final relation in calculateRelations(c))
    if (relation.type == RelationType.huiTouSheng || relation.type == RelationType.huiTouKe)
      relation.key.canonical,
};

({List<MovementType> movements, CastChart chart}) _findMovingEarthToFire() {
  for (var mask = 0; mask < 4096; mask++) {
    final movements = [
      for (var i = 0; i < 6; i++) MovementType.values[(mask >> (i * 2)) & 3],
    ];
    final chart = CastingEngine.cast(movements);
    final line = chart.lineAt(2);
    if (line.isMoving && line.branch.wuXing.label == '土' && line.changedBranch?.wuXing.label == '火') {
      return (movements: movements, chart: chart);
    }
  }
  throw StateError('missing moving Earth→Fire fixture');
}
