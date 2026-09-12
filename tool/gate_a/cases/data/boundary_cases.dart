/// GA-3 节气编号与 GA-4 日界案例：类型定义 + 数据。
/// 日界时间点带完整日期归属（子时横跨两个公历日），避免时间轴歧义。
library;

import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

/// 节气边界案例的**编号编排**（`GA-ST-<黄经序>`）。
///
/// 实际测试点由 `reports/solar_term_report.dart` 从**官方发布值**逐节生成；
/// 本类只保留「节气 → 序号」的稳定编号约定，不承载测试点定义。
class SolarTermBoundaryCase {
  const SolarTermBoundaryCase({
    required this.id,
    required this.term,
    required this.year,
    required this.purpose,
  });

  final String id;
  final SolarTermId term;
  final int year;
  final String purpose;

  /// 完整标题，如 `立春 2026`。
  String get title => '${term.label} $year';
}

/// 日界专项案例：一个基准公历日 `d1`。
class DayBoundaryCase {
  const DayBoundaryCase({
    required this.id,
    required this.date,
    required this.purpose,
  });

  final String id;

  /// 基准公历日期 `YYYY-MM-DD`（记作 `d1`）。
  final String date;

  final String purpose;
}

/// 时间轴偏移点（相对基准日 `d1 00:00:00` 的偏移 + 展示标签）。
class DayClockPoint {
  const DayClockPoint(this.label, this.offset);

  final String label;
  final Duration offset;
}

/// 日界两种规则的展示顺序。
const List<DayBoundaryRule> dayBoundaryRules = <DayBoundaryRule>[
  DayBoundaryRule.midnight,
  DayBoundaryRule.ziHourStart,
];

/// 规则中文名。
String dayBoundaryRuleLabel(DayBoundaryRule rule) => switch (rule) {
  DayBoundaryRule.midnight => 'midnight（00:00 换日）',
  DayBoundaryRule.ziHourStart => 'ziHourStart（23:00 子初换日）',
};

/// 六个关键挂钟时刻（§13），带完整日期归属：
/// `d1 22:59:59` → `d1 23:00:00` → `d1 23:30:00` → `d1 23:59:59`
/// → `d1+1 00:00:00` → `d1+1 00:00:01`。
const List<DayClockPoint> dayBoundaryClockPoints = <DayClockPoint>[
  DayClockPoint('d1 22:59:59', Duration(hours: 22, minutes: 59, seconds: 59)),
  DayClockPoint('d1 23:00:00', Duration(hours: 23)),
  DayClockPoint('d1 23:30:00', Duration(hours: 23, minutes: 30)),
  DayClockPoint('d1 23:59:59', Duration(hours: 23, minutes: 59, seconds: 59)),
  DayClockPoint('d1+1 00:00:00', Duration(days: 1)),
  DayClockPoint('d1+1 00:00:01', Duration(days: 1, seconds: 1)),
];

/// GA-4 日界案例。
const List<DayBoundaryCase> dayBoundaryCases = <DayBoundaryCase>[
  DayBoundaryCase(
    id: 'GA-DAY-01',
    date: '2026-09-07',
    purpose: '普通日（白露当日 22:41 交节，可同时观察月建是否同为 22:41 切换）',
  ),
  DayBoundaryCase(
    id: 'GA-DAY-02',
    date: '2026-12-31',
    purpose: '跨公历年（23:00 在 ziHourStart 下进入 2027-01-01）',
  ),
  DayBoundaryCase(
    id: 'GA-DAY-03',
    date: '2026-01-31',
    purpose: '跨公历月（23:00 在 ziHourStart 下进入 2 月 1 日）',
  ),
];
