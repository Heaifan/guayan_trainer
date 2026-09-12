/// GA-3 节气边界章节（自 `reports/boundary_report.dart` 拆出）。
///
/// 设计原则（GATE-A-PREP-FIX2）：
/// 1. 测试点只以**官方发布值**（HKO / NAOJ）为准；
/// 2. 自建天文尺子一律标 `UNVERIFIED TOOL OUTPUT`，**不**参与建窗、不做真值；
/// 3. 有可追溯秒级公开值的节气，才追加 `exact −1s / exact / exact +1s`；
/// 4. 精度结论记在 `Gate A-Truth` 下，且只能是
///    `PARTIALLY SECOND-LEVEL VERIFIED`（立春秒级已核实，其余仅分钟级）。
///
/// 本文件出「一、数据包交节时刻」与「二、官方双源交叉」两节；
/// 「三、Gate 判据」在 `../status/gate_criteria.dart`，
/// 逐节气测试点表在 `term_render.dart`。
library;

import '../../core/formatting/format.dart';
import '../../gate_a_context.dart';
import '../status/gate_criteria.dart';
import 'term_reference.dart';
import 'term_render.dart';
import 'term_resolve.dart';

String renderSolarTermSection(GateAContext ctx) {
  final refs = resolveOfficialReferences(ctx, 2026);
  final b = StringBuffer()
    ..write(_solarTermSummary(refs))
    ..writeln()
    ..write(gateCriteria(refs))
    ..writeln();
  for (final r in refs) {
    b.write(renderOfficialTermCase(ctx, r));
  }
  return b.toString();
}

String _solarTermSummary(List<OfficialTermReference> refs) {
  final b = StringBuffer();
  b.writeln('## 一、数据包交节时刻与记录精度（2026 十二「节」）\n');
  b.writeln('| 节气 | 月建切换 | 数据包边界（HKT） | 精度 | 秒级公开值 | 秒级来源 |');
  b.writeln('| --- | --- | --- | --- | --- | --- |');
  for (final r in refs) {
    b.writeln(
      '| ${r.term.label} | ${r.oldMonth.label}→${r.newMonth.label} '
      '| ${wallClockText(r.packHkt)} '
      '| ${r.isSecondPrecise ? '**second**' : 'minute'} '
      '| ${r.secondLevel == null ? '无' : wallClockText(r.secondLevel!.hkt)} '
      '| ${r.secondLevel?.source ?? '—'} |',
    );
  }
  b.writeln();
  b.writeln(
    '> `minute` 表示该瞬间秒位仅作占位（`:00`），真实交节落在该分钟内；'
    '`second` 表示秒位可信。',
  );
  b.writeln();
  b.writeln('## 二、官方双源交叉核验（HKO vs NAOJ）\n');
  b.writeln('```text');
  b.writeln('HKO：香港天文台「二十四節氣的日期及時間資料」（HKT, UTC+8）');
  b.writeln('NAOJ：日本国立天文台「暦要項」（JST, UTC+9）→ 减 1 小时换算 HKT');
  b.writeln('结果：2026 年 24 / 24 日期一致、分钟一致（详见 gate_a_cross_source 输出）');
  b.writeln('结论：官方分钟级真值成立，两个独立机构互相印证。');
  b.writeln('```');
  b.writeln();
  return b.toString();
}
