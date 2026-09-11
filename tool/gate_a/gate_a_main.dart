/// Gate A 生成器入口：产出**供人工对照**的验收表单（不做自动判定）。
///
/// 用法（仓库根目录）：
/// ```text
/// pwsh -File tool/gate_a/gate_a_runner.ps1 run
/// ```
library;

import 'dart:convert';
import 'dart:io';

import 'gate_a_case_report.dart';
import 'gate_a_cases.dart';
import 'gate_a_context.dart';
import 'gate_a_day_report.dart';
import 'gate_a_hexagram_audit.dart';
import 'gate_a_hexagram_facts.dart';
import 'gate_a_solar_term_report.dart';

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
    _title('GA-3 节气边界专项（2026 年十二「节」全量测量 + 前 6 详表）') +
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
    _title('Gate A 总表（待用户回填后定稿）') +
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
  stdout.writeln('状态：WAITING FOR USER MANUAL GATE INPUT');
}

void _write(String path, String content) {
  File(path).writeAsStringSync(content, encoding: utf8);
}

String _title(String t) => '# $t\n\n';

String _instructions() => '''> **使用方式**：把上表「专业软件」列留空的位置，用专业排盘软件
> 按给出的「起卦时间 + 六爻输入」排出结果后逐项填入（或直接截图回传）。
> 「一致」列填 ✅ / ❌；❌ 时在文末写清哪个字段不一致。
>
> 时区统一 **+08:00**；六爻输入自**初爻至上爻**，7=少阳 8=少阴 9=老阳 6=老阴。

\n''';

String _header(GateAContext ctx, List<CaseFacts> facts) => '''# 卦眼 2.0 · Gate A 专业排盘人工对照验收

> 本目录全部文件由 `tool/gate_a/gate_a_main.dart` 生成，**不含任何自动判定**。
> 「专业软件」列必须由人填写 —— 这是 Gate A 的唯一真值来源。

## 状态

```text
Gate A1 PROFESSIONAL SOFTWARE COMPATIBILITY
  WAITING FOR USER MANUAL INPUT

Gate A2 SOLAR TERM ABSOLUTE PRECISION
  UNRESOLVED — ASTRONOMICAL ORACLE NOT YET VALIDATED

GATE A
  NOT PASSED
```

## 数据来源

```text
数据包年份      ${ctx.installedYears.join(', ')}
节气来源        Hong Kong Observatory（HKO），分钟精度（秒位恒为 :00）
第二官方源      日本国立天文台 NAOJ「暦要項」（JST → HKT 减 1 小时）
双源交叉        2026 年 24 / 24 日期一致、分钟一致
秒级公开值      仅立春 2026（紫金山天文台科普部 04:02:08 +08:00）
时区基准        +08:00
卦眼日界（本表）midnight（00:00 换日）
```

> 自建天文尺子（Meeus）状态：**REJECTED AS GATE ORACLE**，仅作 diagnostic。
> 详见 `03-solar-term-boundaries.md` 的「自建天文尺子的现状」一节。

## 文件说明

| 文件 | 内容 |
| --- | --- |
| `01-normal-cases.md` | GA-1 普通真实卦例 ${normalCases.length} 例（月建/日辰/旬空/卦体/纳甲/六亲/世应） |
| `02-classic-cases.md` | GA-2 经典卦体 ${classicCases.length} 例（乾为天/坤为地/泽山咸/归魂/游魂…） |
| `03-solar-term-boundaries.md` | GA-3 节气边界：2026 十二「节」差异窗口全量测量 + 窗口最大的前 6 个详表 |
| `04-day-boundary.md` | GA-4 日界 ${dayBoundaryCases.length} 个日期 × 6 个时刻 × 2 种规则 |
| `05-master-table.md` | Gate A 总表（回填后定稿） |

## 用户需要做的三件事

1. 打开专业排盘软件（建议 **2 个独立来源**）；
2. 按 `01`/`02`/`03`/`04` 中给出的时间与卦象输入；
3. 把结果填回或截图发回，并注明**软件名与版本**（不同软件流派不同）。

> 用户不需要自己设计测试案例 —— 测试设计责任在 Agent。

## 已有结果 vs 待人工判定

**Agent 已完成（可复核）**

```text
GA0 Git baseline 核验                      DONE
GA1 GA-1 测试矩阵（${normalCases.length} 例）                    DONE
GA3 GA-2 测试矩阵（${classicCases.length} 例）                     DONE
GA4 GA-3 测试矩阵（2026 十二「节」× 官方测试点）  DONE
GA6 GA-4 测试矩阵（${dayBoundaryCases.length} 日 × 6 点 × 2 规则） DONE
结构自检（八宫表 / 纳甲组装 / 案例锁定）    DONE
官方双源交叉（HKO vs NAOJ 24/24）           DONE
自建天文尺子验证（REJECTED AS ORACLE）      DONE
```

**待用户人工对照（Agent 不得代做）**

```text
GA2  GA-1 人工对照        BLOCKED — 等待专业软件结果
GA5  GA-3 人工对照        BLOCKED — 等待专业软件结果
GA7  GA-4 人工对照        BLOCKED — 等待专业软件结果
GA8  差异分类             BLOCKED — 需先有差异
GA9  必要时最小 FIX       BLOCKED
GA11 Gate A 总表定稿      BLOCKED
GA14 Final Gate Decision  BLOCKED
```

## 覆盖矩阵（程序统计）

```text
普通案例        ${facts.where((f) => f.def.group == 'GA-1').length} 例（要求 >= 10）
经典卦体        ${facts.where((f) => f.def.group == 'GA-2').length} 例（要求 >= 6）
节气边界        2026 十二「节」全量（要求 >= 3，推荐 5）；详表出窗口最大的 6 个
日界专项        ${dayBoundaryCases.length} 日 × ${dayBoundaryClockPoints.length} 时间点 × 2 规则
有变 / 无变     ${facts.where((f) => f.changed != null).length} / ${facts.where((f) => f.changed == null).length}
单变 / 多变     ${facts.where((f) => f.chart.movingPositions.length == 1).length} / ${facts.where((f) => f.chart.movingPositions.length > 1).length}
六冲卦例        ${_names(facts, (f) => f.isLiuChong)}
六合卦例        ${_names(facts, (f) => f.isLiuHe)}
变卦为六合      ${_names(facts, (f) => f.isChangedLiuHe)}
游魂卦例        ${_names(facts, (f) => f.original.rank.label == '游魂')}
归魂卦例        ${_names(facts, (f) => f.original.rank.label == '归魂')}
```

> 六十四卦中其余六冲卦（坎为水 / 艮为山 / 巽为风 / 离为火 / 兑为泽 /
> 雷天大壮 / 天雷无妄）**未**强行造例凑覆盖率 —— 需求明确禁止为覆盖率伪造案例。

## 已知需要重点观察的三处

1. **GA-3 · 立春 2026**：唯一有秒级公开值的节气 ——
   `边界 −1min / 边界 / 边界 +1min / 秒级 exact −1s / exact / exact +1s` 六点，
   是 `Gate A1` 最关键的一组。
2. **GA-4 · 23:00—23:59**：日界流派分歧窗口，只判日辰与旬空。
3. **GA-2 · GA-C-06**：验证**变卦六亲仍取本卦之宫**（不得按变卦宫计算）。

## 关于 Gate A2

`Gate A2` 现为 **UNRESOLVED**：官方双源（HKO / NAOJ）已互相印证分钟级真值，
但**独立秒级天文真值尚未建立**，因此既不 PASS 也不 FAIL 数据源。
**不要据此升级 `CalendarDataPack`。**
''';

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
  b.writeln('## 一、官方交节时刻（数据包 = HKO，分钟精度）\n');
  b.writeln('| 节气 | 月建切换 | 官方交节（HKT） | 秒级公开值 | 秒级来源 |');
  b.writeln('| --- | --- | --- | --- | --- |');
  for (final r in refs) {
    b.writeln(
      '| ${r.term.label} | ${r.oldMonth.label}→${r.newMonth.label} '
      '| ${_short(r.packHkt)} '
      '| ${r.secondLevel == null ? '无' : _short(r.secondLevel!.hkt)} '
      '| ${r.secondLevel?.source ?? '—'} |',
    );
  }
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
  b.writeln('Gate A1 · PROFESSIONAL SOFTWARE COMPATIBILITY');
  b.writeln('  问题：目标专业软件与卦眼（同一输入）是否给出同一月建？');
  b.writeln('  方法：用上表「边界 -1min / 边界 / 边界 +1min」三点做人工对照。');
  b.writeln('  状态：WAITING FOR USER MANUAL INPUT');
  b.writeln('');
  b.writeln('Gate A2 · SOLAR TERM ABSOLUTE PRECISION');
  b.writeln('  状态：UNRESOLVED — ASTRONOMICAL ORACLE NOT YET VALIDATED');
  b.writeln('  原因：自建天文尺子的绝对精度尚未建立，');
  b.writeln('        不得用它证明数据包存在误差，也不得据此 FAIL 数据包。');
  b.writeln('  已确立的事实：HKO 与 NAOJ 官方分钟值 24/24 一致。');
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
      '| 五行 | 六亲(初→上) | 变爻纳甲 | 变卦六亲 | 卦体 | Result |');
  b.writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- '
      '| --- | --- | --- | --- | --- | --- | --- | --- |');
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
      '${f.isChangedLiuHe ? '｜变六合' : ''} | |',
    );
  }
  b.writeln();
  b.writeln('> 所有 `·` 分隔的列一律按**初爻→上爻**顺序。');
  b.writeln('> `变卦六亲` 列**仍以本卦之宫为「我」**，不按变卦之宫计算。');
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
