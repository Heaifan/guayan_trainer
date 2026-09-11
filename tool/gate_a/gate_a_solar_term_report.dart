/// GA-3 节气边界渲染：交节瞬间 ±2min / ±1min / 边界 / ±30s 的月建对照表。
///
/// 目的不是「让 HKO 达到秒级」，而是确定**分钟精度是否会造成真实月建分歧**：
/// 若专业软件在 `交节 - 1min` 已经给出新月建，则说明其交节时刻早于 HKO 分钟值，
/// 差异必须归类为「节气数据精度差异」（F8），而不是去改 MonthBranchResolver。
library;

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term.dart';

import 'gate_a_cases.dart';
import 'gate_a_context.dart';
import 'gate_a_format.dart';

/// 一个节气边界测试点。
class SolarTermProbe {
  const SolarTermProbe({
    required this.label,
    required this.offset,
    required this.precision,
  });

  /// 相对边界的行为标签，如 `-1min`。
  final String label;

  /// 相对交节瞬间的偏移。
  final Duration offset;

  final TimePrecision precision;
}

/// 测试点矩阵：±2min / ±1min / 边界，附 ±30s 秒级探测。
const List<SolarTermProbe> solarTermProbes = <SolarTermProbe>[
  SolarTermProbe(
    label: '-2min',
    offset: Duration(minutes: -2),
    precision: TimePrecision.shiftedMinute,
  ),
  SolarTermProbe(
    label: '-1min',
    offset: Duration(minutes: -1),
    precision: TimePrecision.shiftedMinute,
  ),
  SolarTermProbe(
    label: '-30s',
    offset: Duration(seconds: -30),
    precision: TimePrecision.shiftedSecond,
  ),
  SolarTermProbe(
    label: '边界（交节瞬间）',
    offset: Duration.zero,
    precision: TimePrecision.minute,
  ),
  SolarTermProbe(
    label: '+30s',
    offset: Duration(seconds: 30),
    precision: TimePrecision.shiftedSecond,
  ),
  SolarTermProbe(
    label: '+1min',
    offset: Duration(minutes: 1),
    precision: TimePrecision.shiftedMinute,
  ),
  SolarTermProbe(
    label: '+2min',
    offset: Duration(minutes: 2),
    precision: TimePrecision.shiftedMinute,
  ),
];

/// 找出数据包中指定年份的某个节气；该年缺失时**明确失败**，不跨年借代。
SolarTerm? findTerm(GateAContext ctx, SolarTermBoundaryCase c) {
  if (!ctx.installedYears.contains(c.year)) return null;
  for (final t in ctx.engine.monthBranchResolver.provider.termsOfYear(c.year)) {
    if (t.id == c.term) return t;
  }
  return null;
}

/// 渲染一个节气边界的完整对照表。
String renderSolarTermCase(GateAContext ctx, SolarTermBoundaryCase c) {
  final term = findTerm(ctx, c);
  final b = StringBuffer();
  b.writeln('### ${c.id} · ${c.title}');
  b.writeln();
  if (term == null) {
    b.writeln('> ❌ 数据包中找不到 ${c.year} 年 ${c.term.label}，Gate A 无法继续。');
    b.writeln();
    return b.toString();
  }

  final instantHkt = hktOf(term.instantUtc);
  b.writeln('```text');
  b.writeln('覆盖点      ${c.purpose}');
  b.writeln('数据包中交节（UTC）   ${rfc3339(term.instantUtc)}');
  b.writeln('数据包中交节（HKT）   ${wallClockWithOffsetText(instantHkt)}');
  b.writeln('来源                  Hong Kong Observatory（精度 1 分钟，秒位恒为 :00）');
  b.writeln('边界语义              instant < 交节 → 旧月建；instant >= 交节 → 新月建');
  b.writeln('```');
  b.writeln();
  b.writeln('| 测试点 | 时间（+08:00） | 精度 | 卦眼月建 | 专业软件月建 | 一致 '
      '| 卦眼日辰 | 卦眼旬空 |');
  b.writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');

  final rows = <String>[];
  for (final p in solarTermProbes) {
    final t = instantHkt.add(p.offset);
    final local = DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
    final facts = resolveCalendar(ctx, local);
    rows.add(
      '| ${p.label} | ${wallClockWithOffsetText(t)} '
      '| ${precisionLabel(p.precision)} | ${facts.monthBranchLabel} | | | '
      '${facts.dayGanZhi} | ${facts.xunKongLabel} |',
    );
  }
  for (final row in rows) {
    b.writeln(row);
  }
  b.writeln();
  b.writeln(
    '> 若专业软件在 `-1min` 或 `-30s` 就给出**新月建**，说明其交节时刻早于 '
    'HKO 分钟值 → 归类 **F8 节气数据精度差异**，'
    '**不得**修改 MonthBranchResolver 去适配该案例。',
  );
  b.writeln();
  return b.toString();
}
