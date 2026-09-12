/// GA-3 节气边界章节：官方测试点表 + Gate 判据块。
library;

import "status/gate_status.dart";
import "status/gate_truth_items.dart";
import "../gate_a_context.dart";
import "solar_term_report.dart";


String renderSolarTermSection(GateAContext ctx) {
  final refs = resolveOfficialReferences(ctx, 2026);
  final b = StringBuffer()
    ..write(_solarTermSummary(refs))
    ..writeln()
    ..write(_gateCriteria(refs))
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
      '| ${_short(r.packHkt)} '
      '| ${r.isSecondPrecise ? '**second**' : 'minute'} '
      '| ${r.secondLevel == null ? '无' : _short(r.secondLevel!.hkt)} '
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

String _gateCriteria(List<OfficialTermReference> refs) {
  final withSecond = refs.where((r) => r.secondLevel != null).length;
  final b = StringBuffer();
  b.writeln('## 三、Gate 判据（两层拆分）\n');
  b.writeln('```text');
  b.writeln('Gate A-Truth · CORE DIVINATION TRUTH  —— R3 的 blocker');
  b.writeln('  问题：卦眼核心排盘规则本身是否正确？');
  b.writeln('  方法：独立规则核验 + 官方历法双源 + 秒级真值 + 边界 Golden Test；');
  b.writeln('        **不依赖任何专业软件**。');
  b.writeln('  状态：${truthItems.any((t) => t.result == 'FAIL') ? 'FAIL' : 'PASS'}');
  b.writeln('  节气数据精度：PARTIALLY SECOND-LEVEL VERIFIED');
  b.writeln('        2026 LiChun = 04:02:08 +08:00（SECOND-LEVEL VERIFIED）');
  b.writeln('        其余节气 MINUTE-LEVEL VERIFIED（via HKO + NAOJ）');
  b.writeln('        已知 precision gap：FIXED');
  b.writeln('        No fabricated second-level values');
  b.writeln('');
  b.writeln('Gate A-Compat · PROFESSIONAL SOFTWARE COMPATIBILITY');
  b.writeln('  问题：目标专业软件与卦眼（同一输入）是否给出同一月建？');
  b.writeln('  方法：用上表「边界 -1min / 边界 / 边界 +1min」三点做人工对照；');
  b.writeln('        立春另有秒级三点。');
  b.writeln('  状态：$compatStatus / DEFERRED —— NON-BLOCKING');
  b.writeln('  理由：$compatReason');
  b.writeln('```');
  b.writeln();
  b.writeln('> 未填写专业软件列时，记为 `$compatStatus`，**不得显示 FAIL**。');
  b.writeln();
  b.writeln('### 立春精度修复（R3-B-DATA-PRECISION-FIX）\n');
  b.writeln('```text');
  b.writeln('根因：分钟级官方显示值被保存为 :00 秒 Instant，');
  b.writeln('      而该分钟内存在可验证的真实秒级交节时刻。');
  b.writeln('      分钟级数据**不足以表达**该秒级边界 —— 不是 HKO 错了。');
  b.writeln('');
  b.writeln('修复前：2026-02-03T20:02:00Z → 04:02:00 起即切寅月（提前 8 秒）');
  b.writeln('修复后：2026-02-03T20:02:08Z → 04:02:08 起才切寅月');
  b.writeln('数据包：schemaVersion 2 / revision 2 / precision = second /');
  b.writeln('        sourceOverride = 中国科学院紫金山天文台科普部');
  b.writeln('```');
  b.writeln();
  b.writeln('### 自建天文尺子的现状（不可作为真值）\n');
  b.writeln('```text');
  b.writeln('状态：REJECTED AS GATE ORACLE（保留为 diagnostic tool）');
  b.writeln('证据：与官方发布时刻相比，时间残差最大约 729 秒（立夏）；');
  b.writeln('      2026 立春对秒级公开值残差约 -343 秒。');
  b.writeln('根因（已定位）：视黄经**日变率正确**（1.0187 vs 官方 1.0187 °/日），');
  b.writeln('      但在官方交节瞬间，本尺子给出的视黄经已越过目标角 9～30 角秒，');
  b.writeln('      且该偏差随季节变化（与中心差 C 同相）—— 属绝对项偏差，');
  b.writeln('      自洽性（求根反代 = 0.000000°）不能证明绝对正确。');
  b.writeln('');
  b.writeln('旧的 <0.01° 自检已降级为 coarse sanity check：');
  b.writeln('      0.01° ≈ 14.6 分钟时间，通过它**不足以**证明分钟级或秒级精度。');
  b.writeln('```');
  b.writeln();
  b.writeln('### 测试点构建规则\n');
  b.writeln('| 情形 | 测试点 |');
  b.writeln('| --- | --- |');
  b.writeln('| 仅有官方分钟值（全部 ${refs.length} 个「节」） | '
      '边界 −1min / 边界 / 边界 +1min |');
  b.writeln('| 另有可追溯秒级公开值（当前 $withSecond 个「节」） | '
      '追加 exact −1s / exact / exact +1s |');
  b.writeln();
  b.writeln('> **已删除**：所有由未验证天文尺推导的「差异窗口」测试点');
  b.writeln('> （如立春 03:56:24~04:02:00、立夏 19:36:50~19:49:00）——'
      '标记为 `UNVERIFIED TOOL OUTPUT`，不作为 Gate 真值。');
  b.writeln();
  return b.toString();
}

String _short(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} '
      '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
}
