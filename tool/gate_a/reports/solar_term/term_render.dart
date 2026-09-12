/// 单个「节」的官方测试点矩阵渲染（自 `solar_term_report.dart` 拆出）。
///
/// 输出一张「测试点 × 卦眼月建 × 期望月建 × 专业软件月建」表格：
/// 卦眼列由程序填，专业软件列留空交人工对照。
library;

import '../../core/formatting/format.dart';
import '../../core/time/time_input.dart';
import '../../gate_a_context.dart';
import 'term_fields.dart';
import 'term_reference.dart';

/// 渲染单个「节」的官方测试点矩阵。
String renderOfficialTermCase(GateAContext ctx, OfficialTermReference r) {
  final b = StringBuffer();
  b.writeln(
    '### ${r.term.label} ${r.year} · '
    '${r.oldMonth.label}月 → ${r.newMonth.label}月',
  );
  b.writeln();
  b.writeln('```text');
  b.writeln('数据包边界（HKT）     ${wallClockText(r.packHkt)}');
  b.writeln('记录精度              ${r.isSecondPrecise ? 'second' : 'minute'}');
  if (r.secondLevel != null) {
    b.writeln('秒级公开值（HKT）     ${wallClockText(r.secondLevel!.hkt)}');
    b.writeln('秒级来源              ${r.secondLevel!.source}');
    b.writeln('备注                  ${r.secondLevel!.note}');
  } else {
    b.writeln('秒级公开值            无（未收录可追溯来源）');
  }
  b.writeln('```');
  b.writeln();
  if (!r.isSecondPrecise) {
    b.writeln(
      '> ⚠️ 本节气为**分钟级**：`instantUtc` 秒位为 `:00` 只表示'
      '「该分钟内交节」，**不**表示「恰在第 0 秒交节」。'
      '在取得可信秒级真值前，不追加秒级测试点。',
    );
    b.writeln();
  }

  b.writeln(
    '| 测试点 | 时间（+08:00） | 卦眼月建 | 期望月建 | 专业软件月建 '
    '| 一致 | 说明 |',
  );
  b.writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final (label, at, note) in termProbes(r)) {
    final local = DateTime(
      at.year,
      at.month,
      at.day,
      at.hour,
      at.minute,
      at.second,
    );
    final month = resolveCalendar(ctx, local).monthBranchLabel;
    final expected = at.isBefore(r.packHkt)
        ? r.oldMonth.label
        : r.newMonth.label;
    b.writeln(
      '| $label | ${wallClockWithOffsetText(local)} | $month | $expected '
      '| | | $note |',
    );
  }
  b.writeln();
  if (r.secondLevel == null) {
    b.writeln(
      '> 本节气**暂无**可追溯秒级真值，因此不设秒级测试点。'
      '若日后取得官方秒级发布值，按同一表格追加 `exact −1s / exact / exact +1s`。',
    );
    b.writeln();
  }
  return b.toString();
}
