/// 「三、Gate 判据（两层拆分）」块（自 `reports/boundary_report.dart` 拆出）。
///
/// 判据本身就是 Gate 的**状态陈述**，因此归入 `status/`：
/// 与 `gate_status.dart` 的 `TruthItem` / `compatStatus` 同源，
/// 避免「文档里写一套结论、状态文件里写另一套」。
library;

import '../solar_term/term_reference.dart';
import 'gate_status.dart';
import 'gate_truth_items.dart';

/// Gate 判据块（Truth / Compat 两层 + 立春精度修复 + 尺子现状 + 建点规则）。
String gateCriteria(List<OfficialTermReference> refs) {
  final withSecond = refs.where((r) => r.secondLevel != null).length;
  final b = StringBuffer();
  b.writeln('## 三、Gate 判据（两层拆分）\n');
  b.writeln('```text');
  b.writeln('Gate A-Truth · CORE DIVINATION TRUTH  —— R3 的 blocker');
  b.writeln('  问题：卦眼核心排盘规则本身是否正确？');
  b.writeln('  方法：独立规则核验 + 官方历法双源 + 秒级真值 + 边界 Golden Test；');
  b.writeln('        **不依赖任何专业软件**。');
  b.writeln(
    '  状态：${truthItems.any((t) => t.result == 'FAIL') ? 'FAIL' : 'PASS'}',
  );
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
  b.writeln(
    '| 仅有官方分钟值（全部 ${refs.length} 个「节」） | '
    '边界 −1min / 边界 / 边界 +1min |',
  );
  b.writeln(
    '| 另有可追溯秒级公开值（当前 $withSecond 个「节」） | '
    '追加 exact −1s / exact / exact +1s |',
  );
  b.writeln();
  b.writeln('> **已删除**：所有由未验证天文尺推导的「差异窗口」测试点');
  b.writeln(
    '> （如立春 03:56:24~04:02:00、立夏 19:36:50~19:49:00）——'
    '标记为 `UNVERIFIED TOOL OUTPUT`，不作为 Gate 真值。',
  );
  b.writeln();
  return b.toString();
}
