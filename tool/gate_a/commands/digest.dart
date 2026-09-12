/// 控制台摘要输出：案例清单、案例锁定自检、R3 最终状态块。
///
/// 与文档生成无关，单独成文件以便 `gate_a_main.dart` 只留编排。
library;

import 'dart:io';

import '../cases/derive.dart';
import '../reports/status/gate_status.dart';

/// 打印 GA-1 / GA-2 案例摘要。
void printDigest(List<CaseFacts> normal, List<CaseFacts> classic) {
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

/// 打印案例锁定自检结果（本卦/变卦与声明是否一致）。
void printLockCheck(List<CaseFacts> facts) {
  final problems = <String>[
    for (final f in facts)
      for (final p in f.auditProblems) '${f.def.id}: $p',
  ];
  stdout.writeln('');
  if (problems.isEmpty) {
    stdout.writeln(
      '案例锁定自检：PASS — 全部 ${facts.length} 例本卦/变卦与声明一致，'
      '纳甲组装顺序正确',
    );
  } else {
    stdout.writeln('案例锁定自检：FAIL');
    for (final p in problems) {
      stdout.writeln('  $p');
    }
  }
}

/// 打印尾部的产出文件清单与 R3 最终状态块。
void printCloseout(String outDir) {
  stdout.writeln('');
  stdout.writeln('已生成（$outDir 下 6 个文件）：');
  for (final name in <String>[
    'README.md',
    '01-normal-cases.md',
    '02-classic-cases.md',
    '03-solar-term-boundaries.md',
    '04-day-boundary.md',
    '05-master-table.md',
  ]) {
    stdout.writeln('  $outDir/$name');
  }
  stdout.writeln('');
  stdout.writeln(r3FinalStatusBlock());
}
