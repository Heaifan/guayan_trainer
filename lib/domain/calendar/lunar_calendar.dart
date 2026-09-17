/// 公历日期到中国农历日期的离线、确定性转换。
library;

import 'lunar_year_data.dart';

class LunarDate {
  const LunarDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;

  String get yearLabel => '${_ganZhiYear(year)}年';
  String get dateLabel => '${_monthNames[month - 1]}${_dayNames[day - 1]}';
  String get displayLabel => '$yearLabel$dateLabel';
}

class LunarCalendar {
  LunarCalendar._();

  static LunarDate dateFor(DateTime solar) {
    final date = DateTime.utc(solar.year, solar.month, solar.day);
    var lunarYear = solar.year;
    final newYear = lunarNewYear[lunarYear];
    if (newYear == null) throw RangeError('农历暂支持 2019–2029 年');
    if (date.isBefore(newYear)) lunarYear--;
    final start = lunarNewYear[lunarYear];
    if (start == null) throw RangeError('农历暂支持 2019–2029 年');
    var offset = date.difference(start).inDays;
    var month = 1;
    final leap = _leapMonth(lunarYear);
    var isLeap = false;
    while (true) {
      final days = _monthDays(lunarYear, month, isLeap);
      if (offset < days) break;
      offset -= days;
      if (leap != 0 && month == leap && !isLeap) {
        isLeap = true;
      } else {
        if (isLeap) isLeap = false;
        month++;
      }
    }
    return LunarDate(year: lunarYear, month: month, day: offset + 1);
  }

  static int _leapMonth(int year) => lunarYearInfo[year]! & 0xf;

  static int _monthDays(int year, int month, bool leap) {
    final info = lunarYearInfo[year]!;
    if (leap) return (info & 0x10000) != 0 ? 30 : 29;
    return (info & (0x10000 >> month)) != 0 ? 30 : 29;
  }
}

const _monthNames = [
  '正月',
  '二月',
  '三月',
  '四月',
  '五月',
  '六月',
  '七月',
  '八月',
  '九月',
  '十月',
  '冬月',
  '腊月',
];
const _dayNames = [
  '初一',
  '初二',
  '初三',
  '初四',
  '初五',
  '初六',
  '初七',
  '初八',
  '初九',
  '初十',
  '十一',
  '十二',
  '十三',
  '十四',
  '十五',
  '十六',
  '十七',
  '十八',
  '十九',
  '二十',
  '廿一',
  '廿二',
  '廿三',
  '廿四',
  '廿五',
  '廿六',
  '廿七',
  '廿八',
  '廿九',
  '三十',
];
const _stems = '甲乙丙丁戊己庚辛壬癸';
const _branches = '子丑寅卯辰巳午未申酉戌亥';

String _ganZhiYear(int year) {
  final index = (year - 1984) % 60;
  return '${_stems[index % 10]}${_branches[index % 12]}';
}
