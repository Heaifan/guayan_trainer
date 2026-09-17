import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/domain/cases/casting_snapshot.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';

void main() {
  test('historical review input comes from saved snapshot, not current draft', () {
    final snapshot = CastingSnapshot(
      castingTime: DateTime(2026, 9, 18, 22),
      subject: '历史事项',
      lines: [
        for (var position = 1; position <= 6; position++)
          LineState(
            position: position,
            movementType: position == 1 ? MovementType.laoYang : MovementType.shaoYin,
          ),
      ],
      originalHexagramName: '乾为天',
      movingPositions: const [1],
    );
    final record = CaseRecord.create(
      id: 'historical',
      snapshot: snapshot,
      createdAt: DateTime(2026, 9, 18, 22, 1),
      originalRuleRun: RuleRun.original(
        executedAt: DateTime(2026, 9, 18, 22),
        ruleContext: const RuleExecutionContext.empty(),
        result: const {'originalHexagramName': '乾为天'},
        evidence: const [],
      ),
    );

    final restored = record.toHexagramCase();

    expect(restored.id, 'historical');
    expect(restored.createdAt, snapshot.castingTime);
    expect(restored.question, '历史事项');
    expect(restored.lines, snapshot.lines);
  });
}
