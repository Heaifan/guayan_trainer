import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar_snapshot.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/presentation/review/review_case_adapter.dart';

void main() {
  test('真实卦例四柱统一使用干支加年月日时后缀', () {
    final state = ReviewCaseAdapter.adapt(HexagramCase(
      id: 'pillar-format',
      question: '四柱格式',
      createdAt: DateTime(2026, 9, 30, 10, 36),
      calendar: const CalendarSnapshot(
        monthBranch: '酉',
        dayGanZhi: '丁未',
        yearGanZhi: '丙午',
        hourGanZhi: '乙巳',
      ),
      lines: const [
        LineState(position: 1, movementType: MovementType.shaoYang),
        LineState(position: 2, movementType: MovementType.shaoYang),
        LineState(position: 3, movementType: MovementType.shaoYang),
        LineState(position: 4, movementType: MovementType.shaoYin),
        LineState(position: 5, movementType: MovementType.shaoYin),
        LineState(position: 6, movementType: MovementType.shaoYin),
      ],
    ));
    expect(state.yearPillar, '丙午年');
    expect(state.monthPillar, '丁酉月');
    expect(state.dayPillar, '丁未日');
    expect(state.hourPillar, '乙巳时');
  });
}
