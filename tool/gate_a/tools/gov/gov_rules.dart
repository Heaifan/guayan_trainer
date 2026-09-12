/// POST-R3-GOV-01 治理自检的**规则编排**（只读）。
///
/// 顺序刻意如此：**规则 0 先自证规则实现**，再让规则 1/2/3 去判仓库。
/// 理由见 `rules_regression.dart`：本轮的教训正是「检查器自己数错，
/// 报告却写 PASS」。检查器不可自证时，后面的 PASS 一律不算数。
library;

import 'dart:io';

import 'dir_scan.dart';
import 'doc_scan.dart';
import 'line_scan.dart';
import 'rules_regression.dart';

/// 规则 1 的行数上限（普通 Dart 源文件）。
const int maxLines = 100;

/// 规则 2 的目录预算：每个目录的**直接文件**数 <= 5。
///
/// 子目录**不**占父目录预算 —— 增加语义子目录正是本规则要求的修复动作。
/// 该口径由 `rules_regression.dart` 的夹具断言，改动必须同步改夹具。
const int maxFilesPerDir = 5;

/// 生成文档的黄金快照（相对仓库根）。
const String goldenPath = 'memory/gate-a-golden-sha256.txt';

/// 生成文档所在目录。
const String docDir = 'gate-a';

/// 执行全部规则、打印证据；返回进程退出码（0 = PASS）。
int runGovSelfcheck(Directory root) {
  final repoRoot = Directory.current;
  var failures = 0;

  failures += _report(
    '规则 0 · 规则实现自证（临时夹具，专防假 PASS）',
    ruleImplementationProblems(),
  );
  failures += _report(
    '规则 1 · Dart 文件 <= $maxLines 行',
    overLongDartFiles(root, repoRoot, maxLines),
  );
  failures += _report(
    '规则 2 · 目录直接文件 <= $maxFilesPerDir（子目录独立计、不计入父目录）',
    overBudgetDirs(root, repoRoot, maxFilesPerDir),
  );
  failures += _reportDocDrift();

  _printDirEvidence(root, repoRoot);

  stdout.writeln('');
  if (failures == 0) {
    stdout.writeln('POST-R3-GOV-01 治理自检：PASS');
  } else {
    stdout.writeln('POST-R3-GOV-01 治理自检：FAIL（$failures 项）');
  }
  return failures == 0 ? 0 : 1;
}

int _reportDocDrift() {
  final drift = docDrift(goldenPath, docDir);
  if (drift == null) {
    stdout.writeln('FAIL  规则 3 · 生成文档 SHA256 == 黄金快照');
    stdout.writeln('        $goldenPath 不存在 —— 缺快照时不得当 PASS');
    return 1;
  }
  return _report('规则 3 · 生成文档 SHA256 == 黄金快照（$goldenPath）', drift);
}

void _printDirEvidence(Directory root, Directory repoRoot) {
  final labels = scanDirs(root).map((d) => dirLabel(repoRoot, d.path)).toList();
  var width = 0;
  for (final l in labels) {
    if (l.length > width) width = l.length;
  }
  stdout.writeln('');
  stdout.writeln('--- 规则 2 证据：每目录**直接**子项（非递归）---');
  final lines = dirEvidenceLines(
    root,
    repoRoot,
    align: (s) => s.padRight(width),
  );
  for (final l in lines) {
    stdout.writeln(l);
  }
}

int _report(String title, List<String> problems) {
  if (problems.isEmpty) {
    stdout.writeln('PASS  $title');
    return 0;
  }
  stdout.writeln('FAIL  $title');
  for (final p in problems) {
    stdout.writeln('        $p');
  }
  return problems.length;
}
