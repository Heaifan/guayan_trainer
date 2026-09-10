/// 历法引擎：CalendarRequest → CalendarContext。
///
/// 纯 Dart 领域层，零 Flutter 依赖、零网络依赖 —— 运行时完全离线。
///
/// 聚合四件事：
/// ```text
/// 月建  ← MonthBranchResolver（十二「节」区间判断）
/// 日辰  ← GanZhiDay（JDN → 六十甲子，先按日界规则定日）
/// 旬空  ← XunKong（由日辰推导）
/// ```
library;

import 'calendar_context.dart';
import 'calendar_request.dart';
import 'day/ganzhi_day.dart';
import 'day/xun_kong.dart';
import 'day_boundary_rule.dart';
import 'solar_term/month_branch_resolver.dart';

/// 历法引擎（无状态）。
class CalendarEngine {
  const CalendarEngine({required this.monthBranchResolver});

  /// 月建解析器（其节气来源由 [SolarTermProvider] 注入，便于替换）。
  final MonthBranchResolver monthBranchResolver;

  /// 求解一次历法上下文。
  CalendarContext resolve(CalendarRequest request) {
    final instant = request.instantUtc;
    final day = dayOf(request);
    return CalendarContext(
      instantUtc: instant,
      monthBranch: monthBranchResolver.resolve(instant),
      day: day,
      xunKong: xunKongOf(day),
    );
  }

  /// 按日界规则判定请求所属「日」，再求日柱。
  ///
  /// - [DayBoundaryRule.midnight]：当地 00:00 换日，直接用当地日期；
  /// - [DayBoundaryRule.ziHourStart]：当地 23:00 起即算次日。
  ///
  /// 日柱以**当地日期**为准（干支日是地方性日历日），
  /// 与月建以 UTC 瞬间为准是两套不同的判定基准，此处刻意区分。
  static GanZhiDay dayOf(CalendarRequest request) {
    final local = request.localDateTime;
    if (dayBoundaryStartHour(request.dayBoundaryRule) == 0) {
      return ganzhiDayOfDate(local.year, local.month, local.day);
    }
    if (local.hour >= dayBoundaryStartHour(request.dayBoundaryRule)) {
      final next = DateTime.utc(
        local.year,
        local.month,
        local.day,
      ).add(const Duration(days: 1));
      return ganzhiDayOfDate(next.year, next.month, next.day);
    }
    return ganzhiDayOfDate(local.year, local.month, local.day);
  }
}
