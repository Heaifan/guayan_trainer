/// Gate A 公共上下文：装载真实历法数据包 → 构建 CalendarEngine。
///
/// 与产品路径完全一致：JSON → 解析 → 校验 → 导入 → 内存仓储 → Provider
/// → MonthBranchResolver → CalendarEngine。Gate A 不允许绕开任何一层，
/// 否则验的就不是产品真值。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/calendar_context.dart';
import 'package:guayan_trainer/domain/calendar/calendar_engine.dart';
import 'package:guayan_trainer/domain/calendar/calendar_request.dart';
import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_importer.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/month_branch_resolver.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/calendar/store/calendar_data_store.dart';
import 'package:guayan_trainer/domain/calendar/store/stored_solar_term_provider.dart';

/// 数据包年份范围（`assets/calendar/` 内实际存在的年份）。
const List<int> gateAYears = <int>[
  2019,
  2020,
  2021,
  2022,
  2023,
  2024,
  2025,
  2026,
  2027,
  2028,
];

/// 东八区偏移（卦眼与专业软件的对照基准时区）。
const Duration tzPlus8 = Duration(hours: 8);

/// 组装好的历法引擎。
class GateAContext {
  const GateAContext(this.engine, this.installedYears);

  final CalendarEngine engine;
  final List<int> installedYears;
}

/// 从 `assets/calendar/` 装载全部年份并构建引擎。
Future<GateAContext> loadGateAContext() async {
  final store = InMemoryCalendarDataStore();
  final importer = CalendarDataPackImporter(store);
  final loaded = <int>[];

  for (final year in gateAYears) {
    final file = File('assets/calendar/$year.calendar.json');
    if (!file.existsSync()) continue;
    await importer.importPack(file.readAsStringSync());
    loaded.add(year);
  }
  if (loaded.isEmpty) {
    throw StateError('assets/calendar/ 下没有任何数据包，Gate A 无法运行');
  }

  final provider = await StoredSolarTermProvider.load(store);
  return GateAContext(
    CalendarEngine(monthBranchResolver: MonthBranchResolver(provider)),
    loaded,
  );
}

/// 解析 `YYYY-MM-DD HH:mm:ss` 为当地挂钟 [DateTime]（不依赖宿主时区）。
DateTime parseWallClock(String text) {
  final p = text.split(RegExp(r'[- :]')).map(int.parse).toList();
  return DateTime(p[0], p[1], p[2], p[3], p[4], p[5]);
}

/// GA-1 / GA-2 / GA-3 统一使用的日界规则（日界本身由 GA-4 单列）。
const DayBoundaryRule dayBoundaryRuleMidnight = DayBoundaryRule.midnight;

/// 以 +08:00 挂钟时间构造历法请求。
CalendarRequest calendarRequestFor(DateTime local, DayBoundaryRule rule) =>
    CalendarRequest(
      localDateTime: local,
      utcOffset: tzPlus8,
      dayBoundaryRule: rule,
    );

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

/// 便捷入口：+08:00 挂钟时间 + 日界规则 → 历法上下文。
CalendarContext resolveAt(
  GateAContext ctx,
  DateTime local,
  DayBoundaryRule rule,
) => ctx.engine.resolve(calendarRequestFor(local, rule));

/// GA-3 / GA-4 使用的默认入口（midnight）。
CalendarContext resolveCalendar(GateAContext ctx, DateTime local) =>
    resolveAt(ctx, local, dayBoundaryRuleMidnight);

/// 当地挂钟时间 + 偏移 → RFC3339 文本（仅用于展示）。
String wallClockWithOffset(DateTime local, Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final abs = offset.abs();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-'
      '${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}:${two(local.second)} '
      '$sign${two(abs.inHours)}:${two(abs.inMinutes % 60)}';
}
