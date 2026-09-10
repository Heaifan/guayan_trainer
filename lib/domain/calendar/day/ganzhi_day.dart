/// 日柱（干支日）：公历日期 → 六十甲子。
///
/// 纯本地算法，无网络、无时区服务：公历日期 → 儒略日序（JDN）→ 六十甲子。
/// 基准锚点：**1949-10-01 = 甲子日**（cycleIndex 0）。
library;

import '../../di_zhi.dart';
import '../../tian_gan.dart';
import '../calendar_error.dart';

/// 一个干支日。
class GanZhiDay {
  const GanZhiDay._(this.cycleIndex);

  /// 由六十甲子序号（0 = 甲子 … 59 = 癸亥）构造。
  factory GanZhiDay.fromCycleIndex(int cycleIndex) {
    if (cycleIndex < 0 || cycleIndex > 59) {
      throw ArgumentError.value(cycleIndex, 'cycleIndex', '六十甲子序号必须在 0..59');
    }
    return GanZhiDay._(cycleIndex);
  }

  /// 六十甲子序号：0 = 甲子 … 59 = 癸亥。
  final int cycleIndex;

  /// 天干。
  TianGan get gan => TianGan.values[cycleIndex % 10];

  /// 地支。
  DiZhi get zhi => DiZhi.values[cycleIndex % 12];

  /// 干支文本，如「甲子」。
  String get label => '${gan.label}${zhi.label}';

  @override
  bool operator ==(Object other) =>
      other is GanZhiDay && other.cycleIndex == cycleIndex;

  @override
  int get hashCode => cycleIndex.hashCode;

  @override
  String toString() => 'GanZhiDay($label)';
}

/// 1949-10-01（甲子日）的儒略日序。
const int jiaZiAnchorJdn = 2433191;

bool _isLeap(int year) => (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

/// 某年某月的天数；月份非法返回 0。
int daysInMonth(int year, int month) => switch (month) {
  1 || 3 || 5 || 7 || 8 || 10 || 12 => 31,
  4 || 6 || 9 || 11 => 30,
  2 => _isLeap(year) ? 29 : 28,
  _ => 0,
};

/// 公历日期的儒略日序（JDN，整数，正午制）；非法日期抛
/// [InvalidCalendarDate]，绝不静默归一化（Dart `DateTime` 会把
/// 2026-02-30 悄悄变成 2026-03-02，历法层不能接受这种行为）。
int julianDayNumber(int year, int month, int day) {
  final dim = daysInMonth(year, month);
  if (dim == 0 || day < 1 || day > dim) {
    throw InvalidCalendarDate(year, month, day);
  }
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      (153 * m + 2) ~/ 5 +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;
}

/// 由**公历日期**求日柱。
///
/// 日界规则不属于本函数：调用方须先按 [DayBoundaryRule] 判定出日期，
/// 再调用本函数。
GanZhiDay ganzhiDayOfDate(int year, int month, int day) =>
    GanZhiDay.fromCycleIndex(
      (julianDayNumber(year, month, day) - jiaZiAnchorJdn) % 60,
    );
