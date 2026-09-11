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
import 'gate_a_format.dart';
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
    _title('GA-3 节气边界专项（${solarTermCases.length} 个节气）') +
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
| `03-solar-term-boundaries.md` | GA-3 节气边界 ${solarTermCases.length} 个节气 × 7 个时间点 |
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
节气边界        ${solarTermCases.length} 个节气（要求 >= 3，推荐 5）
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

1. **GA-3 · 立春**：`-1min` 与 `-30s` 两行是分钟精度风险的唯一判定点；
2. **GA-4 · 23:00—23:59**：日界流派分歧窗口，只判日辰与旬空；
3. **GA-2 · GA-C-06**：验证**变卦六亲仍取本卦之宫**（不得按变卦宫计算）。
''';

String _names(List<CaseFacts> facts, bool Function(CaseFacts) test) {
  final names = <String>[
    for (final f in facts)
      if (test(f)) '${f.def.id}:${f.original.name}',
  ];
  return names.isEmpty ? '（无）' : names.join('、');
}

String _solarTermSection(GateAContext ctx) {
  final b = StringBuffer()
    ..write(_solarTermSummary(ctx))
    ..writeln()
    ..write(solarTermCases.map((c) => renderSolarTermCase(ctx, c)).join());
  return b.toString();
}

String _solarTermSummary(GateAContext ctx) {
  final b = StringBuffer();
  b.writeln('## 交节瞬间一览（来自数据包）\n');
  b.writeln('| 案例 | 节气 | 覆盖点 | 交节（UTC） | 交节（HKT +08:00） | '
      '分钟值 | 精度风险 |');
  b.writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final c in solarTermCases) {
    final t = findTerm(ctx, c);
    if (t == null) continue;
    final minute = hktOf(t.instantUtc).minute;
    b.writeln(
      '| ${c.id} | ${c.title} | ${c.purpose} '
      '| ${t.instantUtc.toIso8601String()} '
      '| ${hktText(t.instantUtc)} +08:00 '
      '| :${minute.toString().padLeft(2, '0')} '
      '| ${_precisionRisk(minute)} |',
    );
  }
  b.writeln();
  b.writeln('## 精度风险判据（GA-3 的核心问题）\n');
  b.writeln('```text');
  b.writeln('HKO 只发布到分钟（秒位恒 :00），说明其内部为**四舍五入到分钟**。');
  b.writeln('→ 真实交节秒数落在 [m:00, m:59]，被记成 :00；或落在 [m-1:30, m:00)，');
  b.writeln('  被进位记成 m:00。');
  b.writeln('因此「分钟值」与「真实秒值」相差最多约 30 秒。');
  b.writeln('已知反证：2026 立春 真实 04:01:51（紫金山天文台），HKO 记 04:02 —— 差 9 秒。');
  b.writeln('```');
  b.writeln();
  b.writeln('| 分钟值 | 判定 | 含义 |');
  b.writeln('| --- | --- | --- |');
  b.writeln('| :00—:01 或 :58—:59 | **高风险** | 真实秒值可能落在相邻分钟，'
      '分钟精度**可能**造成月建分歧 |');
  b.writeln('| :02—:57 | 低风险 | ±30 秒不足以跨越分钟边界，'
      '分钟精度**不会**造成分歧 |');
  b.writeln();
  b.writeln('> 结论只能由 GA-3 的人工对照给出：若全部 6 个节气的 '
      '`-1min` / `-30s` / `边界` 三行都与专业软件一致，则判定 '
      '**HKO MINUTE PRECISION ACCEPTED**；一旦出现「专业软件在 -1min '
      '就换月建」，则判定 **REJECTED — DATA SOURCE UPGRADE REQUIRED**，'
      '且修复对象只能是数据源，不是 MonthBranchResolver。');
  b.writeln();
  return b.toString();
}

/// 分钟值风险标注。
String _precisionRisk(int minute) {
  if (minute <= 1 || minute >= 58) return '⚠️ 高风险';
  return '低';
}

String hktText(DateTime utc) {
  final t = utc.toUtc().add(const Duration(hours: 8));
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)} '
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
