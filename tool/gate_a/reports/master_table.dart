/// Gate A 总表渲染：Truth Result 与 Compatibility Result 分列。
library;

import "../cases/derive.dart";
import "../core/gate_status.dart";

String renderMasterTable(List<CaseFacts> facts) {
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

/// 把满足 [test] 的案例渲染成 `ID:卦名` 列表；空则返回「（无）」。
String caseNames(List<CaseFacts> facts, bool Function(CaseFacts) test) {
  final names = <String>[
    for (final f in facts)
      if (test(f)) '${f.def.id}:${f.original.name}',
  ];
  return names.isEmpty ? '（无）' : names.join('、');
}
