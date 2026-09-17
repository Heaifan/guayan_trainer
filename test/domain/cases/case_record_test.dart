import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/domain/cases/casting_snapshot.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';

List<LineState> _lines() => [
  for (var position = 1; position <= 6; position++)
    LineState(
      position: position,
      movementType: MovementType.shaoYin,
      branch: '子',
    ),
];

RuleRun _run() => RuleRun.original(
  executedAt: DateTime(2026, 9, 18),
  ruleContext: const RuleExecutionContext.empty(),
  result: const {'title': '可成'},
  evidence: const [],
);

void main() {
  test('case keeps category separate from the question body', () {
    final record = CaseRecord.create(
      id: 'case-semantic',
      snapshot: CastingSnapshot(
        castingTime: DateTime(2026, 9, 18),
        subject: '我什么时候开发完成？',
        category: '事业',
        lines: _lines(),
        originalHexagramName: '水火既济',
        movingPositions: const [],
      ),
      createdAt: DateTime(2026, 9, 18),
      originalRuleRun: _run(),
    );

    expect(record.toHexagramCase().question, '我什么时候开发完成？');
    expect(record.snapshot.category, '事业');
  });

  final snapshot = CastingSnapshot(
    castingTime: DateTime(2026, 9, 18, 22, 30),
    subject: '回款',
    lines: [
      for (var position = 1; position <= 6; position++)
        LineState(
          position: position,
          movementType: position == 3
              ? MovementType.laoYang
              : MovementType.shaoYin,
          branch: '子',
        ),
    ],
    originalHexagramName: '水雷屯',
    changedHexagramName: '水地比',
    movingPositions: const [3],
  );

  test(
    'CaseRecord round-trips immutable snapshot and frozen original RuleRun',
    () {
      final original = RuleRun.original(
        executedAt: DateTime(2026, 9, 18, 22, 30),
        ruleContext: RuleExecutionContext([RuleVersionRef('sys.default', 1)]),
        result: const {'title': '可成', 'text': '当时命中结果'},
        evidence: const [
          {'ruleId': 'sys.default', 'text': '命中证据'},
        ],
      );
      final record = CaseRecord.create(
        id: 'case-001',
        snapshot: snapshot,
        createdAt: DateTime(2026, 9, 18, 22, 31),
        originalRuleRun: original,
      );

      final restored = CaseRecord.fromJson(record.toJson());

      expect(restored.snapshot, snapshot);
      expect(restored.snapshot.castingTime, DateTime(2026, 9, 18, 22, 30));
      expect(restored.createdAt, DateTime(2026, 9, 18, 22, 31));
      expect(restored.subject, '回款');
      expect(restored.ruleRuns.single, original);
      expect(restored.deletedAt, isNull);
      expect(restored.isFavorite, isFalse);
    },
  );

  test('empty subject is valid and has a display fallback', () {
    final record = CaseRecord.create(
      id: 'case-empty',
      snapshot: snapshot.copyWith(subject: ''),
      createdAt: DateTime(2026, 9, 18),
      originalRuleRun: RuleRun.original(
        executedAt: DateTime(2026, 9, 18),
        ruleContext: const RuleExecutionContext.empty(),
        result: const {},
        evidence: const [],
      ),
    );

    expect(record.subjectDisplay, '未填写事项');
  });
}
