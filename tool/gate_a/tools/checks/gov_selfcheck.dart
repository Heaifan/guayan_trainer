/// POST-R3-GOV-01 治理自检（**只读**）：5+100 与生成文档等价性。
///
/// 本文件只是**入口**（薄壳）；规则实现与自证分别在：
///
/// ```text
/// tools/gov/rules_regression.dart   规则 0：用临时夹具自证计数口径
/// tools/gov/line_scan.dart          规则 1：Dart 文件 <= 100 行
/// tools/gov/dir_scan.dart           规则 2：目录**直接文件** <= 5
/// tools/gov/doc_scan.dart           规则 3：生成文档 SHA256 == 黄金快照
/// tools/gov/gov_rules.dart          编排 + 证据打印
/// ```
///
/// 用法（仓库根目录）：
/// ```text
/// dart run tool/gate_a/tools/checks/gov_selfcheck.dart
/// ```
/// 除系统临时目录内的自证夹具外，不读写仓库内任何文件。
library;

import 'dart:io';

import '../gov/gov_rules.dart';

void main() {
  final root = Directory('tool/gate_a');
  if (!root.existsSync()) {
    stderr.writeln('找不到 tool/gate_a —— 请在仓库根目录运行');
    exit(1);
  }
  exitCode = runGovSelfcheck(root);
}
