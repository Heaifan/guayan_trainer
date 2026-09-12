/// 规则 2 的目录预算扫描 —— **只数「直接文件」**：不递归、不把子目录算进去。
///
/// 为什么单独成文件：POST-R3-GOV-01 的 S0 独立核验发现旧实现正是在这里数错，
/// 详细记录见 `rules_regression.dart`。计数口径必须先被夹具自证，
/// 才允许拿去判仓库 —— 否则检查器本身就会发假 PASS / 假 FAIL。
library;

import 'dart:io';

/// 路径统一成正斜杠（Windows 的 `\` 会污染所有比对与打印）。
String slashPath(String p) => p.replaceAll('\\', '/');

/// 根目录 + 全部后代目录，按标签排序（含根自身）。
List<Directory> scanDirs(Directory root) {
  final out = <Directory>[
    root,
    ...root.listSync(recursive: true).whereType<Directory>(),
  ]..sort((a, b) => a.path.compareTo(b.path));
  return out;
}

/// 「直接文件」数：该目录**第一层**的普通文件。
///
/// 明确**不含**：子目录自身、任何后代文件。
int directFileCount(Directory dir) => dir.listSync().whereType<File>().length;

/// 「直接子目录」数。单独度量、单独打印，便于人工分辨两种口径。
int directSubdirCount(Directory dir) =>
    dir.listSync().whereType<Directory>().length;

/// 目录标签：相对 [repoRoot] 的路径（如 `tool/gate_a/reports`）。
String dirLabel(Directory repoRoot, String path) {
  final target = slashPath(path);
  final base = slashPath(repoRoot.path);
  final rel = target == base
      ? target.split('/').last
      : (target.startsWith('$base/')
            ? target.substring(base.length + 1)
            : target);
  return rel;
}

/// 违规目录：**直接文件数** > [maxFilesPerDir]。
///
/// 子目录不是违规：把职责搬进语义子目录正是本规则要求的修复动作，
/// 若子目录也占用父目录预算，规则会自相矛盾且永远无法满足。
List<String> overBudgetDirs(
  Directory root,
  Directory repoRoot,
  int maxFilesPerDir,
) {
  final out = <String>[];
  for (final d in scanDirs(root)) {
    final n = directFileCount(d);
    if (n > maxFilesPerDir) {
      out.add('${dirLabel(repoRoot, d.path)}  $n 个直接文件');
    }
  }
  return out;
}

/// 规则 2 的证据表：每目录一行 `标签  files=N  subdirs=M`。
List<String> dirEvidenceLines(
  Directory root,
  Directory repoRoot, {
  required String Function(String) align,
}) {
  final lines = <String>[];
  var maxFiles = 0;
  for (final d in scanDirs(root)) {
    final files = directFileCount(d);
    final subs = directSubdirCount(d);
    if (files > maxFiles) maxFiles = files;
    lines.add(
      '${align(dirLabel(repoRoot, d.path))} files=$files  subdirs=$subs',
    );
  }
  lines.add('');
  lines.add('MAX DIRECT FILES = $maxFiles');
  return lines;
}
