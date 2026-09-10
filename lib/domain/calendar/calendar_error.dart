/// 历法层的类型化失败。
///
/// 不新建第二套错误体系：项目既有 Domain 一律以「抛类型化异常」表达
/// 不可恢复的坏输入（见 `line_state.dart` / `hexagram_case.dart`），
/// 本层沿用同一做法。
///
/// 原则：宁可明确 Unsupported，也绝不返回「看起来正常但可能错误」的月建。
library;

/// 请求年份超出节气表支持范围。
class UnsupportedCalendarYear implements Exception {
  const UnsupportedCalendarYear({
    required this.year,
    required this.minYear,
    required this.maxYear,
  });

  /// 被请求的年份。
  final int year;

  /// 支持范围下界（含）。
  final int minYear;

  /// 支持范围上界（含）。
  final int maxYear;

  @override
  String toString() =>
      'UnsupportedCalendarYear: $year 超出历法支持范围 $minYear..$maxYear';
}

/// 非法日历日期（如 2026-02-30）。
class InvalidCalendarDate implements Exception {
  const InvalidCalendarDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  @override
  String toString() => 'InvalidCalendarDate: $year-$month-$day 不是合法公历日期';
}

/// 缺少某年历法数据（该年数据包未导入 / 未安装）。
///
/// **禁止**用近似算法补算；宁可明确失败，也不返回可能错误的月建。
class CalendarDataMissing implements Exception {
  const CalendarDataMissing(this.year);

  /// 缺失的年份。
  final int year;

  @override
  String toString() => 'CalendarDataMissing: 缺少 $year 年历法数据包，无法计算月建';
}

/// 数据包不合法（解析失败或校验不通过）。
///
/// 携带全部失败原因，导入被整体拒绝，已安装数据不受影响。
class CalendarDataPackInvalid implements Exception {
  const CalendarDataPackInvalid(this.reasons);

  /// 失败原因（至少一条）。
  final List<String> reasons;

  @override
  String toString() =>
      'CalendarDataPackInvalid: '
      '${reasons.isEmpty ? "未知原因" : reasons.join("；")}';
}

/// 拒绝降级导入：待导入 revision 不高于已安装 revision。
class CalendarRevisionRejected implements Exception {
  const CalendarRevisionRejected({
    required this.calendarYear,
    required this.installed,
    required this.incoming,
  });

  final int calendarYear;
  final int installed;
  final int incoming;

  @override
  String toString() =>
      'CalendarRevisionRejected: $calendarYear 年已安装 '
      'revision $installed，拒绝导入 revision $incoming';
}
