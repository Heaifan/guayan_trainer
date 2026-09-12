/// GA-4 日界专项渲染：跨子时连续时间轴在两种规则下的日辰 / 旬空。
///
/// 本轮只出**事实对照**：若两个外部软件规则本身分流，
/// 一律记为 `Rule Difference`，交由用户决定卦眼默认值，Agent 不拍板。
library;

import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/tian_gan.dart';

import '../cases/derive.dart';
import '../gate_a_context.dart';
import '../core/formatting/format.dart';
import '../core/time/time_input.dart';

/// 渲染单个日界案例。
String renderDayBoundaryCase(GateAContext ctx, DayBoundaryCase c) {
  final base = parseWallClock('${c.date} 00:00:00');
  final b = StringBuffer();
  b.writeln('### ${c.id} · ${c.date}（d1）');
  b.writeln();
  b.writeln('```text');
  b.writeln('覆盖点    ${c.purpose}');
  b.writeln('时区      +08:00');
  b.writeln('时间轴    d1 22:59:59 → d1 23:00:00 → d1 23:30:00 → d1 23:59:59');
  b.writeln('          → d1+1 00:00:00 → d1+1 00:00:01');
  b.writeln('待判字段  日辰（六十甲子日柱）、旬空；月建不受日界影响，一并记录');
  b.writeln('```');
  b.writeln();

  for (final rule in dayBoundaryRules) {
    b.writeln('**卦眼 · ${dayBoundaryRuleLabel(rule)}**');
    b.writeln();
    b.writeln('| 时间点 | 实际挂钟时间（+08:00） | 日辰 | 旬空 | 月建 | '
        '专业软件日辰 | 专业软件旬空 | 一致 |');
    b.writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final p in dayBoundaryClockPoints) {
      final at = base.add(p.offset);
      final local = DateTime(
        at.year,
        at.month,
        at.day,
        at.hour,
        at.minute,
        at.second,
      );
      final cal = resolveAt(ctx, local, rule);
      b.writeln(
        '| ${p.label} | ${wallClockWithOffsetText(local)} '
        '| ${cal.dayGanZhi} | ${cal.xunKongLabel} | ${cal.monthBranchLabel} '
        '| | | |',
      );
    }
    b.writeln();
  }

  b.writeln('> **时干口径提示**：23 时后的时柱存在「按当日日干（晚子时）」与'
      '「按次日日干（早子时）」两种流派。本轮只判日辰与旬空，'
      '时干差异请单独注明，不要与日辰差异混为一谈。');
  b.writeln();
  return b.toString();
}

/// 某时刻在该规则下所用的日干（供时柱口径对照）。
TianGan dayGanAt(
  GateAContext ctx,
  DateTime local,
  DayBoundaryRule rule,
) => resolveAt(ctx, local, rule).day.gan;
