import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/domain/cases/casting_snapshot.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';

CaseRecord recordFixture(String id, DateTime time) => CaseRecord.create(
      id: id,
      snapshot: CastingSnapshot(
        castingTime: time,
        subject: '',
        lines: [
          for (var position = 1; position <= 6; position++)
            LineState(position: position, movementType: MovementType.shaoYin),
        ],
        originalHexagramName: '雷水解',
        movingPositions: const [],
      ),
      createdAt: time.add(const Duration(minutes: 1)),
      originalRuleRun: RuleRun.original(
        executedAt: time,
        ruleContext: const RuleExecutionContext.empty(),
        result: const {},
        evidence: const [],
      ),
    );
