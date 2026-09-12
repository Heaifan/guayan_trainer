/// Gate A 生成器入口：产出**供人工对照**的验收表单（不做自动判定）。
///
/// 用法（仓库根目录）：
/// ```text
/// pwsh -File tool/gate_a/gate_a_runner.ps1 run
/// ```
library;

import 'dart:convert';
import 'dart:io';

import 'reports/case_report.dart';
import 'cases/derive.dart';
import 'gate_a_context.dart';
import 'reports/day_report.dart';
import 'core/pillars.dart';
import 'core/gate_status.dart';
import 'core/gate_truth_items.dart';
import 'core/hexagram_audit.dart';
import 'cases/derive.dart';
import 'cases/derive.dart';
import 'reports/readme_header.dart';
import 'reports/solar_term_report.dart';

const String _outDir = 'gate-a';

Future<void> main(List<String> args) async {
  final ctx = await loadGateAContext();
  stdout.writeln(
    'Gate A · 已装载历年数据包：${ctx.installedYears.join(', ')}',
  );

  final audit = [...verifyPalaceTable()];
  stdout.writeln(
    audit.isEmpty
        ? '结构自检（八宫表完整性）：PASS — 64 组合一一对应，每宫 8 卦，世应相隔三位'
        : '结构自检（八宫表完整性）：FAIL\n  ${audit.join('\n  ')}',
  );

  Directory(_outDir).createSync(recursive: true);

  final facts = computeAllCaseFacts(ctx);
  final normal = facts
      .where((f) => f.def.group == 'GA-1')
      .toList(growable: false);
  final classic = facts
      .where((f) => f.def.group == 'GA-2')
      .toList(growable: false);

  final header = _header(ctx, facts);
  _write('$_outDir/README.md', header);
  _write(
    '$_outDir/01-normal-cases.md',
    _title('GA-1 普通真实卦例（${normal.length} 例）') +
        _instructions() +
        renderCaseFacts(normal),
  );
  _write(
    '$_outDir/02-classic-cases.md',
    _title('GA-2 经典卦体专项（${classic.length} 例）') +
        _instructions() +
        renderCaseFacts(classic),
  );
  _write(
    '$_outDir/03-solar-term-boundaries.md',
    _title('GA-3 节气边界专项（2026 年十二「节」官方测试点 + 立春秒级三点）') +
        _instructions() +
        _solarTermSection(ctx),
  );
  _write(
    '$_outDir/04-day-boundary.md',
    _title('GA-4 日界专项（${dayBoundaryCases.length} 个日期）') +
        _instructions() +
        dayBoundaryCases.map((c) => renderDayBoundaryCase(ctx, c)).join(),
  );
  _write(
    '$_outDir/05-master-table.md',
    _title('Gate A 总表（Truth Result 与 Compatibility Result 分列）') +
        _masterTable(facts),
  );

  _consoleDigest(normal, classic);

  final lockProblems = <String>[
    for (final f in facts)
      for (final p in f.auditProblems) '${f.def.id}: $p',
  ];
  stdout.writeln('');
  if (lockProblems.isEmpty) {
    stdout.writeln('案例锁定自检：PASS — 全部 ${facts.length} 例本卦/变卦与声明一致，'
        '纳甲组装顺序正确');
  } else {
    stdout.writeln('案例锁定自检：FAIL');
    for (final p in lockProblems) {
      stdout.writeln('  $p');
    }
  }

  stdout.writeln('');
  stdout.writeln('已生成（$_outDir 下 6 个文件）：');
  stdout.writeln('  $_outDir/README.md');
  stdout.writeln('  $_outDir/01-normal-cases.md');
  stdout.writeln('  $_outDir/02-classic-cases.md');
  stdout.writeln('  $_outDir/03-solar-term-boundaries.md');
  stdout.writeln('  $_outDir/04-day-boundary.md');
  stdout.writeln('  $_outDir/05-master-table.md');
  stdout.writeln('');
  stdout.writeln(r3FinalStatusBlock());
}

void _write(String path, String content) {
  File(path).writeAsStringSync(content, encoding: utf8);
}

String _title(String t) => '# $t\n\n';

String _instructions() => '''> **使用方式（Gate A-Compat 专用，可选）**：把表中「专业软件」列留空的位置，
> 用专业排盘软件按给出的「起卦时间 + 六爻输入」排出结果后逐项填入（或截图回传）。
> 未填写时该表 Result 记为 `NOT EXECUTED`，**不是** FAIL。
>
> **注意**：Gate A-Compat **不阻塞 R3**。核心业务真值由 Gate A-Truth 承担，
> 其证据来自独立规则核验与官方历法双源，不依赖任何专业软件。
>
> 时区统一 **+08:00**；六爻输入自**初爻至上爻**，7=少阳 8=少阴 9=老阳 6=老阴。

\n''';

/// README 头与使用说明文本见 `reports/readme_header.dart`。
String _header(GateAContext ctx, List<CaseFacts> facts) =>
    renderReadmeHeader(ctx, facts);


String _names(List<CaseFacts> facts, bool Function(CaseFacts) test) {
  final names = <String>[
    for (final f in facts)
      if (test(f)) '${f.def.id}:${f.original.name}',
  ];
  return names.isEmpty ? '（无）' : names.join('、');
}

String _solarTermSection(GateAContext ctx) {
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

String _masterTable(List<CaseFacts> facts) {
  final b = StringBuffer();
  b.writeln('| ID | 类型 | 起卦时间（+08:00） | 六爻输入 | 月建 | 日辰 | 旬空 '
      '| 本卦 | 变卦 | 卦宫 | 世应 | 六神(初→上) | 纳甲(初→上) '
      '| 五行 | 六亲(初→上) | 变爻纳甲 | 变卦六亲 | 卦体 '
      '| Truth Result | Compatibility Result |');
  b.writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- '
      '| --- | --- | --- | --- | --- | --- | --- | --- | --- |');
  for (final f in facts) {
    final l = f.chart.lines;
    b.writeln(
      '| ${f.def.id} | ${f.def.group} | ${f.def.localTime} '
      '| ${f.def.inputText} | ${f.calendar.monthBranchLabel} '
      '| ${f.calendar.dayGanZhi} | ${f.calendar.xunKongLabel} '
      '| ${f.original.name} | ${f.changed?.name ?? '（静卦）'} '
      '| ${f.original.palace.label}·${f.original.palace.wuXing.label} '
      '| 世${f.original.shiPosition}/应${f.original.yingPosition} '
      '| ${l.map((x) => x.spirit?.label ?? '—').join('·')} '
      '| ${l.map((x) => x.ganZhi).join('·')} '
      '| ${l.map((x) => x.branch.wuXing.label).join('·')} '
      '| ${l.map((x) => x.relative.label).join('·')} '
      '| ${l.map((x) => x.changedGanZhi ?? '—').join('·')} '
      '| ${l.map((x) => x.changedRelative?.label ?? '—').join('·')} '
      '| ${f.original.rank.label}${f.isLiuChong ? '·六冲' : ''}'
      '${f.isLiuHe ? '·六合' : ''}'
      '${f.isChangedLiuChong ? '｜变六冲' : ''}'
      '${f.isChangedLiuHe ? '｜变六合' : ''} '
      '| ${f.auditProblems.isEmpty ? '**PASS**' : '**FAIL**'} '
      '| $compatStatus |',
    );
  }
  b.writeln();
  b.writeln('> 所有 `·` 分隔的列一律按**初爻→上爻**顺序。');
  b.writeln('> `变卦六亲` 列**仍以本卦之宫为「我」**，不按变卦之宫计算。');
  b.writeln('>');
  b.writeln('> **两个 Result 是两个 Gate，不得混用**：');
  b.writeln('> - `Truth Result` = Gate A-Truth：`PASS` '
      '表示该例结构自检与案例锁定通过（卦名/纳甲组装顺序无异常）；');
  b.writeln('> - `Compatibility Result` = Gate A-Compat：未做专业软件对照，'
      '故一律 `$compatStatus`，**不是** FAIL。');
  b.writeln();
  return b.toString();
}

void _consoleDigest(List<CaseFacts> normal, List<CaseFacts> classic) {
  stdout.writeln('');
  stdout.writeln('GA-1 普通卦例（${normal.length} 例）');
  for (final f in normal) {
    stdout.writeln(
      '  ${f.def.id}  ${f.def.localTime}  ${f.calendar.monthBranchLabel}月建 '
      '${f.calendar.dayGanZhi}日 ${f.calendar.xunKongLabel}空  '
      '${f.original.name}→${f.changed?.name ?? '（静）'}  '
      '${f.original.palace.label}宫·${f.original.rank.label}  '
      '世${f.original.shiPosition}/应${f.original.yingPosition}  '
      '${f.movingText}  '
      '${f.isLiuChong ? '六冲' : ''}${f.isLiuHe ? '六合' : ''}',
    );
  }
  stdout.writeln('');
  stdout.writeln('GA-2 经典卦体（${classic.length} 例）');
  for (final f in classic) {
    stdout.writeln(
      '  ${f.def.id}  ${f.original.name}→${f.changed?.name ?? '（静）'}  '
      '${f.original.palace.label}宫·${f.original.rank.label}  '
      '世${f.original.shiPosition}/应${f.original.yingPosition}  '
      '纳甲 ${f.chart.lines.map((l) => l.ganZhi).join(' ')}',
    );
  }
}
