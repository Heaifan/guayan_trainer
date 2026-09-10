import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_engine.dart';
import 'package:guayan_trainer/domain/calendar/calendar_request.dart';
import 'package:guayan_trainer/domain/calendar/day/ganzhi_day.dart';
import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';

/// T5 · 日界测试。
///
/// 两种规则必须都正确实现，且**不得有隐式默认值**：
/// 最终产品采用哪一种由业务层冻结，历法层不替业务层拍板。
///
/// 基准：2026-01-01 = 乙亥日，2026-01-02 = 丙子日。
void main() {
  const tz = Duration(hours: 8);

  GanZhiDay dayOf(String ymdhms, DayBoundaryRule rule) {
    final p = ymdhms.split(RegExp(r'[- :]')).map(int.parse).toList();
    return CalendarEngine.dayOf(
      CalendarRequest(
        localDateTime: DateTime(p[0], p[1], p[2], p[3], p[4], p[5]),
        utcOffset: tz,
        dayBoundaryRule: rule,
      ),
    );
  }

  group('midnight · 00:00 换日', () {
    test('22:59:59 / 23:00:00 / 23:59:59 均属当日', () {
      expect(
        dayOf('2026-01-01 22:59:59', DayBoundaryRule.midnight).label,
        '乙亥',
      );
      expect(
        dayOf('2026-01-01 23:00:00', DayBoundaryRule.midnight).label,
        '乙亥',
      );
      expect(
        dayOf('2026-01-01 23:59:59', DayBoundaryRule.midnight).label,
        '乙亥',
      );
    });

    test('00:00:00 属当日（新一天从 00:00 起）', () {
      expect(
        dayOf('2026-01-01 00:00:00', DayBoundaryRule.midnight).label,
        '乙亥',
      );
      expect(
        dayOf('2026-01-02 00:00:00', DayBoundaryRule.midnight).label,
        '丙子',
      );
    });
  });

  group('ziHourStart · 23:00 子初换日', () {
    test('22:59:59 仍属当日', () {
      expect(
        dayOf('2026-01-01 22:59:59', DayBoundaryRule.ziHourStart).label,
        '乙亥',
      );
    });

    test('23:00:00 起即算次日', () {
      expect(
        dayOf('2026-01-01 23:00:00', DayBoundaryRule.ziHourStart).label,
        '丙子',
      );
      expect(
        dayOf('2026-01-01 23:59:59', DayBoundaryRule.ziHourStart).label,
        '丙子',
      );
    });

    test('00:00:00 仍属次日（不回落）', () {
      expect(
        dayOf('2026-01-02 00:00:00', DayBoundaryRule.ziHourStart).label,
        '丙子',
      );
    });
  });

  group('两种规则在 23:00—24:00 必然不同', () {
    test('23:30 是唯一分歧窗口', () {
      const t = '2026-01-01 23:30:00';
      expect(dayOf(t, DayBoundaryRule.midnight).label, '乙亥');
      expect(dayOf(t, DayBoundaryRule.ziHourStart).label, '丙子');
      expect(
        dayOf(t, DayBoundaryRule.midnight).label,
        isNot(dayOf(t, DayBoundaryRule.ziHourStart).label),
      );
    });
  });

  group('跨月 / 跨年 / 闰日进位', () {
    test('月末 23:30 → 次月 1 日', () {
      expect(
        dayOf('2026-01-31 23:30:00', DayBoundaryRule.ziHourStart).label,
        dayOf('2026-02-01 12:00:00', DayBoundaryRule.midnight).label,
      );
    });

    test('年末 23:30 → 次年 1 月 1 日', () {
      expect(
        dayOf('2025-12-31 23:30:00', DayBoundaryRule.ziHourStart).label,
        dayOf('2026-01-01 12:00:00', DayBoundaryRule.midnight).label,
      );
    });

    test('闰年前夜 2020-02-28 23:30 → 2020-02-29', () {
      expect(
        dayOf('2020-02-28 23:30:00', DayBoundaryRule.ziHourStart).label,
        ganzhiDayOfDate(2020, 2, 29).label,
      );
    });
  });
}
