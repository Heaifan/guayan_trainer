import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/calendar/calendar_error.dart';
import 'package:guayan_trainer/domain/calendar/day/ganzhi_day.dart';

/// T1 · 日柱 Golden Tests。
///
/// 基准值取自**独立于本实现**的两个公开黄历源（2026-09 采集）：
/// - 911cha：`https://mipnongli.911cha.com/<y>-<m>-<d>.html`
/// - bumiju：`https://eihuangli.bumiju.com/<y>/<m>-<d>.html`
/// 两源在重叠区间互相一致，且与 1949-10-01 甲子日这一公开事实吻合。
void main() {
  group('T1 · 跨年代 Golden Dates', () {
    const golden = <String, String>{
      '1900-01-01': '甲戌',
      '1912-02-12': '戊午',
      '1949-10-01': '甲子', // 锚点
      '1970-01-01': '辛巳',
      '1976-09-09': '甲子',
      '1984-01-31': '甲子',
      '1997-07-01': '甲辰',
      '1999-12-31': '丁巳',
      '2000-01-01': '戊午',
      '2008-08-08': '庚辰',
      '2015-06-15': '壬戌',
      '2020-02-29': '壬寅', // 闰日
      '2023-09-29': '庚寅',
    };

    golden.forEach((date, expected) {
      test('$date → $expected', () {
        final p = date.split('-').map(int.parse).toList();
        final day = ganzhiDayOfDate(p[0], p[1], p[2]);
        expect(day.label, expected);
        // 同时断言拆分字段，避免只比对拼接串掩盖错位。
        expect(day.gan.label, expected[0]);
        expect(day.zhi.label, expected[1]);
      });
    });

    test('锚点 1949-10-01 的六十甲子序号为 0', () {
      expect(ganzhiDayOfDate(1949, 10, 1).cycleIndex, 0);
    });
  });

  group('T1 · 连续性与闰年', () {
    test('相邻两日序号严格 +1（模 60），跨越闰年 2 月 29 日不断档', () {
      var cursor = DateTime.utc(2020, 1, 1);
      var prev = ganzhiDayOfDate(2020, 1, 1);
      for (var i = 0; i < 400; i++) {
        cursor = cursor.add(const Duration(days: 1));
        final cur = ganzhiDayOfDate(cursor.year, cursor.month, cursor.day);
        expect(
          cur.cycleIndex,
          (prev.cycleIndex + 1) % 60,
          reason: '${cursor.toIso8601String()} 处干支日断档',
        );
        prev = cur;
      }
    });

    test('闰年 2 月 29 日存在，平年 2 月 29 日不存在', () {
      expect(daysInMonth(2020, 2), 29);
      expect(daysInMonth(1900, 2), 28, reason: '1900 非闰年（百年不闰）');
      expect(daysInMonth(2000, 2), 29, reason: '2000 是闰年（四百年再闰）');
    });
  });

  group('T1 · 非法日期明确失败', () {
    test('2026-02-30 抛 InvalidCalendarDate，不静默归一化', () {
      expect(
        () => julianDayNumber(2026, 2, 30),
        throwsA(isA<InvalidCalendarDate>()),
      );
      expect(
        () => ganzhiDayOfDate(2026, 2, 30),
        throwsA(isA<InvalidCalendarDate>()),
      );
    });

    test('月份非法与 13 月抛出', () {
      expect(
        () => julianDayNumber(2026, 13, 1),
        throwsA(isA<InvalidCalendarDate>()),
      );
      expect(
        () => julianDayNumber(2026, 0, 1),
        throwsA(isA<InvalidCalendarDate>()),
      );
    });

    test('GanZhiDay 序号越界抛出 ArgumentError', () {
      expect(() => GanZhiDay.fromCycleIndex(60), throwsA(isA<ArgumentError>()));
      expect(() => GanZhiDay.fromCycleIndex(-1), throwsA(isA<ArgumentError>()));
    });
  });
}
