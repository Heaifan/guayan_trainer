import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar_snapshot.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/domain/shensha/shensha_engine.dart';
import 'package:guayan_trainer/presentation/review/review_case_adapter.dart';

import '../../domain/shensha/shensha_golden_fixture.dart';

void main() {
  test(
    'Review adapter reads persisted shen sha results from calendar snapshot',
    () {
      final shenShaResults = const ShenShaEngine().calculate(
        goldenShenShaContext,
      );
      final hexagramCase = HexagramCase(
        id: 'shensha-case',
        question: '测试',
        lines: [
          for (var position = 1; position <= 6; position++)
            LineState(position: position, movementType: MovementType.shaoYang),
        ],
        createdAt: DateTime(2026, 9, 17, 21),
        ruleContext: RuleExecutionContext([]),
        calendar: CalendarSnapshot(
          monthBranch: '酉',
          dayGanZhi: '癸巳',
          yearGanZhi: '丙午',
          hourGanZhi: '壬戌',
          shenShaResults: shenShaResults,
        ),
      );

      final state = ReviewCaseAdapter.adapt(hexagramCase);

      expect(state.shenShaItems, hasLength(19));
      expect(state.shenShaItems.first.label, '卦身：酉');
      expect(state.shenShaItems.first.id, 'shensha.gua_shen');
      expect(state.shenShaItems[3].reasonSnapshot, '日支三合局=巳酉丑 → 亥');
    },
  );

  test('Review adapter projects engine fushen facts onto the matching yao', () {
    final hexagramCase = HexagramCase(
      id: 'fushen-case',
      question: '测试伏神',
      lines: [
        for (var position = 1; position <= 6; position++)
          LineState(
            position: position,
            movementType: position.isEven
                ? MovementType.shaoYin
                : MovementType.shaoYang,
          ),
      ],
      createdAt: DateTime(2026, 9, 18),
      ruleContext: const RuleExecutionContext.empty(),
    );

    final state = ReviewCaseAdapter.adapt(hexagramCase);

    expect(state.lineAt(3).primaryHidden!.label, '妻财戊午火');
    expect(state.lineAt(3).primaryHidden!.naYin, '天上火');
    expect(state.lineAt(3).oppositeHidden!.label, '官鬼己亥水');
    expect(state.lineAt(3).oppositeHidden!.naYin, '平地木');
    expect(state.lineAt(3).identity!.element, '水');

    final reloaded = HexagramCase.fromJson(hexagramCase.toJson());
    expect(
      ReviewCaseAdapter.adapt(reloaded).lineAt(3).identity!.naYin,
      state.lineAt(3).identity!.naYin,
    );
  });
}
