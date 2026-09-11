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
IN PROGRESS — WAITING FOR USER MANUAL GATE INPUT
```

## 数据来源

```text
数据包年份      ${ctx.installedYears.join(', ')}
节气来源        Hong Kong Observatory（HKO）
节气精度        1 分钟（秒位恒为 :00）
时区基准        +08:00
卦眼日界（本表）midnight（00:00 换日）
```

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
GA4 GA-3 测试矩阵（${solarTermCases.length} 节气 × 7 时间点）      DONE
GA6 GA-4 测试矩阵（${dayBoundaryCases.length} 日 × 6 点 × 2 规则） DONE
结构自检（八宫表 / 纳甲组装 / 案例锁定）    DONE
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

1. **GA-3 · 差异窗口起点**：四个测试点里，**只有「窗口起点」一行是决定性的** ——
   它决定 `Gate A1 PROFESSIONAL SOFTWARE COMPATIBILITY` 是否 PASS。
   `-1min` / `-30s` **不再是判据**（实测差异窗口 16s～729s，远大于 30s）。
2. **GA-4 · 23:00—23:59**：日界流派分歧窗口，只判日辰与旬空。
3. **GA-2 · GA-C-06**：验证**变卦六亲仍取本卦之宫**（不得按变卦宫计算）。

## 本轮新增结论（需你决定）

`Gate A2 SOLAR TERM ABSOLUTE PRECISION` 已可如实记录：数据包为**分钟级**，
但与天算真实交节的最大差异窗口达 **729 秒**（立夏），
十二「节」中只有 2 个与天算同分钟。原「分钟精度误差 ≤ 30 秒」的假设不成立。
**真正待决的是：数据源是否升级到秒级天文数据。**（架构已就绪，只需换数据包。）
''';

String _names(List<CaseFacts> facts, bool Function(CaseFacts) test) {
  final names = <String>[
    for (final f in facts)
      if (test(f)) '${f.def.id}:${f.original.name}',
  ];
  return names.isEmpty ? '（无）' : names.join('、');
}

String _solarTermSection(GateAContext ctx) {
  // 全量：2026 年十二「节」逐项测量差异窗口。
  final all = resolveTermReferencesForYear(ctx, 2026);
  final ranked = [...all]..sort((a, b) => b.windowSeconds.compareTo(a.windowSeconds));
  // 详表只出窗口最大的前 6 个（人工对照成本受控），其余在总表中列出。
  final detailed = ranked.take(6).toList();

  final b = StringBuffer()
    ..write(_solarTermSummary(all, ranked, detailed))
    ..writeln()
    ..write(_gateCriteria(all))
    ..writeln();
  for (final r in detailed) {
    b.write(renderSolarTermCase(ctx, r));
  }
  return b.toString();
}

String _solarTermSummary(
  List<TermReference> all,
  List<TermReference> ranked,
  List<TermReference> detailed,
) {
  final b = StringBuffer();
  b.writeln('## 一、2026 年十二「节」：数据包 vs 天算（差异窗口全表）\n');
  b.writeln('| 优先 | 节气 | 月建切换 | 数据包（HKT） | 天算（HKT） | 残差 | '
      '窗口时长 | 同分钟 |');
  b.writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
  for (var i = 0; i < ranked.length; i++) {
    final r = ranked[i];
    final isDetailed = detailed.contains(r);
    b.writeln(
      '| ${isDetailed ? '**详表**' : '仅记录'} '
      '| ${i + 1}. ${r.term.id.label} '
      '| ${previousMonthBranch(r.term.id).label}→${r.term.id.monthBranch!.label} '
      '| ${_short(r.packHkt)} | ${_short(r.astroHkt)} '
      '| ${r.residualSeconds}s | ${r.windowSeconds}s '
      '| ${r.sameMinute ? '是' : '否'} |',
    );
  }
  b.writeln();
  final maxWin = ranked.first;
  final minWin = ranked.last;
  b.writeln(
    '> 窗口时长区间：**${minWin.windowSeconds}s ～ ${maxWin.windowSeconds}s**'
    '（最大 ${maxWin.term.id.label}）。',
  );
  b.writeln();
  b.writeln('## 二、数据包与天算的切换时刻对照（月建口径）\n');
  b.writeln('| 节气 | 数据包口径下切换于 | 天算口径下切换于 | 错判窗口 |');
  b.writeln('| --- | --- | --- | --- |');
  for (final r in ranked) {
    b.writeln(
      '| ${r.term.id.label} | ${_short(r.packHkt)} | ${_short(r.astroHkt)} '
      '| [${_short(r.windowStart)}, ${_short(r.windowEnd)}) = '
      '${r.windowSeconds}s |',
    );
  }
  b.writeln();
  b.writeln(
    '> 窗口语义：在窗口区间内起卦时，「以数据包为准的月建」与'
    '「以真实交节为准的月建」**不同**。',
  );
  b.writeln();
  return b.toString();
}

String _gateCriteria(List<TermReference> all) {
  final maxWin = all.map((r) => r.windowSeconds).reduce((a, b) => a > b ? a : b);
  final minWin = all.map((r) => r.windowSeconds).reduce((a, b) => a < b ? a : b);
  final sameMinute = all.where((r) => r.sameMinute).length;
  final b = StringBuffer();
  b.writeln('## 三、Gate 判据（两层拆分，互不替代）\n');
  b.writeln('```text');
  b.writeln('Gate A1 · PROFESSIONAL SOFTWARE COMPATIBILITY');
  b.writeln('  问题：目标专业软件与卦眼（同一输入）是否给出同一月建？');
  b.writeln('  方法：在「窗口起点」一行输入专业软件（详表已给出该时刻）。');
  b.writeln('  结果：一致 → PASS；分歧 → 记 F8/F10 并先定位根因再谈修。');
  b.writeln('');
  b.writeln('Gate A2 · SOLAR TERM ABSOLUTE PRECISION');
  b.writeln('  问题：卦眼所用数据源的绝对精度到什么量级？');
  b.writeln('  方法：与天算交节时刻逐项比对（本页全表即为结果）。');
  b.writeln('  结果：如实记录量级，**不得**把分钟级数据说成秒级。');
  b.writeln('```');
  b.writeln();
  b.writeln('### 为什么 `-1min` / `-30s` 不能作判据（实测数据）\n');
  b.writeln('```text');
  b.writeln('旧判据的隐含假设：数据包分钟值 = 真实交节四舍五入到分钟，误差 <= 30 秒。');
  b.writeln('实测：2026 十二「节」中只有 $sameMinute 个与天算落在同一分钟；');
  b.writeln('      差异窗口最小 ${minWin}s、最大 ${maxWin}s。');
  b.writeln('因此 -1min / -30s 两个点既可能在真实边界之前、也可能在之后，');
  b.writeln('      不可能成为「分钟精度是否足够」的决定性测试。');
  b.writeln('');
  b.writeln('正确判据：以窗口 [min(数据包, 天算), max(数据包, 天算)) 为准，');
  b.writeln('      在「窗口起点 -1s」与「窗口起点」两点上做人工对照。');
  b.writeln('```');
  b.writeln();
  b.writeln('### 详表四个测试点的分工\n');
  b.writeln('| 测试点 | 作用 |');
  b.writeln('| --- | --- |');
  b.writeln('| 窗口起点 −1s | **对照行**：天算尚未交节，'
      '专业软件应给旧月建（若给新月建则说明它用的边界更早，另需定位） |');
  b.writeln('| 窗口起点 | **决定性行**：天算已交节。'
      '专业软件给新月建 → 与天算一致、卦眼落后 → F8 数据精度差异 |');
  b.writeln('| 数据包边界 −1s | **错判窗口内**：卦眼给旧月建；'
      '专业软件若给新月建即说明冲突就发生在这里 |');
  b.writeln('| 数据包边界 | **收敛行**：两套口径均为新月建（应为一致） |');
  b.writeln();
  b.writeln('> 旧的 `-1min` / `-30s` 两个点**仍然保留价值，但身份变了**：');
  b.writeln('> 它们不再是「分钟精度是否足够」的判据，而是**对照组** ——');
  b.writeln('> 用来确认专业软件不会在真实边界之前就换月建。');
  b.writeln();
  b.writeln('> 天算尺子来自 `tool/gate_a/gate_a_sun_longitude.dart`'
      '（Meeus 章动 + 光行差，**不入产品、不改架构**），');
  b.writeln('> 仅用于测量差异窗口，**不**作为产品数据源。');
  b.writeln();
  b.writeln('> ⚠️ **本轮新发现，需你决定**：数据包与真实交节的最大差异窗口达 '
      '$maxWin 秒，');
  b.writeln('> 这**远大于**原假设的 30 秒。这意味着「HKO 分钟精度是否可接受」'
      '这一问法本身需要改口径：');
  b.writeln('> 真正要决定的是**数据源是否升级到秒级天文数据**，'
      '而不是分钟精度是否够用。');
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
