import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/calendar/lunar_calendar.dart';

void main() {
  test('2026-09-17 converts to the real lunar date', () {
    final result = LunarCalendar.dateFor(DateTime(2026, 9, 17));

    expect(result.yearLabel, '丙午年');
    expect(result.dateLabel, '八月初七');
  });

  test('lunar date conversion is independent of the host timezone', () {
    final result = LunarCalendar.dateFor(DateTime(2026, 9, 17, 23, 59));

    expect(result.dateLabel, '八月初七');
  });
}
