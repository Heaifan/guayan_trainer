/// Gate A 的时间输入与历法上下文辅助。
///
/// 统一约定：挂钟时间 + 东八区偏移 + 显式日界规则。
library;

import 'package:guayan_trainer/domain/calendar/calendar_context.dart';
import 'package:guayan_trainer/domain/calendar/calendar_request.dart';
import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import '../../gate_a_context.dart';

/// 东八区偏移（卦眼与专业软件的对照基准时区）。
const Duration tzPlus8 = Duration(hours: 8);

/// GA-1 / GA-2 / GA-3 统一使用的日界规则（日界本身由 GA-4 单列）。
const DayBoundaryRule dayBoundaryRuleMidnight = DayBoundaryRule.midnight;

/// 解析 `YYYY-MM-DD HH:mm:ss` 为当地挂钟 [DateTime]（不依赖宿主时区）。
DateTime parseWallClock(String text) {
  final p = text.split(RegExp(r'[- :]')).map(int.parse).toList();
  return DateTime(p[0], p[1], p[2], p[3], p[4], p[5]);
}

/// 以 +08:00 挂钟时间构造历法请求。
CalendarRequest calendarRequestFor(DateTime local, DayBoundaryRule rule) =>
    CalendarRequest(
      localDateTime: local,
      utcOffset: tzPlus8,
      dayBoundaryRule: rule,
    );

/// 便捷入口：+08:00 挂钟时间 + 日界规则 → 历法上下文。
CalendarContext resolveAt(
  GateAContext ctx,
  DateTime local,
  DayBoundaryRule rule,
) => ctx.engine.resolve(calendarRequestFor(local, rule));

/// GA-3 / GA-4 使用的默认入口（midnight）。
CalendarContext resolveCalendar(GateAContext ctx, DateTime local) =>
    resolveAt(ctx, local, dayBoundaryRuleMidnight);

/// 该瞬间是否尚未交 [year] 年的立春（决定年柱与月干的「年」）。
///
/// 立春 = 月建为寅的那个「节」。同时看 [year]-1 与 [year] 两年数据。
bool isBeforeLiChun(GateAContext ctx, DateTime instantUtc, int year) {
  SolarTerm? liChun;
  for (final y in <int>[year - 1, year]) {
    for (final t in ctx.engine.monthBranchResolver.provider.termsOfYear(y)) {
      if (t.id != SolarTermId.liChun) continue;
      if (liChun == null || t.instantUtc.isAfter(liChun.instantUtc)) {
        liChun = t;
      }
    }
  }
  if (liChun == null) return false;
  return instantUtc.isBefore(liChun.instantUtc);
}
