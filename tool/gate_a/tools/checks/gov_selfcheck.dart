/// POST-R3-GOV-01 治理自检（**只读**）。
///
/// 1. 普通 Dart 源文件 <= 100 行
/// 2. 每个目录的**直接子项**（文件 + 子目录） <= 5
/// 3. 生成文档 SHA256 仍等于治理前的黄金快照
///
/// 只读：不修改任何文件，仅打印 PASS/FAIL 与违规清单。
library;

import 'dart:io';

import 'sha256.dart';

const int maxLines = 100;
const int maxFilesPerDir = 5;
const String goldenPath = 'memory/gate-a-golden-sha256.txt';

void main() {
  final root = Directory('tool/gate_a');
  if (!root.existsSync()) {
    stderr.writeln('找不到 tool/gate_a');
    exit(1);
  }

  var failures = 0;
  failures += _report('规则 1 · Dart 文件 <= $maxLines 行', _overLongFiles(root));
  failures += _report(
    '规则 2 · 目录 <= $maxFilesPerDir 文件',
    _overCrowdedDirs(root),
  );
  failures += _report('规则 3 · 生成文档 SHA256 与黄金快照一致', _docDrift());

  stdout.writeln('');
  if (failures == 0) {
    stdout.writeln('POST-R3-GOV-01 治理自检：PASS');
  } else {
    stdout.writeln('POST-R3-GOV-01 治理自检：FAIL（$failures 项）');
    exitCode = 1;
  }
}

String _rel(String path) => path
    .replaceAll('\\', '/')
    .replaceFirst(RegExp(r'^.*/tool/gate_a/'), '');

List<String> _overLongFiles(Directory root) {
  final out = <String>[];
  for (final f in root.listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    final n = f.readAsLinesSync().length;
    if (n > maxLines) out.add('${_rel(f.path)}  $n 行');
  }
  return out;
}

List<String> _overCrowdedDirs(Directory root) {
  final out = <String>[];
  for (final e in root.listSync(recursive: true).whereType<Directory>()) {
    final count = e.listSync(recursive: true).whereType<File>().length;
    if (count > maxFilesPerDir) out.add('${_rel(e.path)}  $count 个文件');
  }
  final topCount = root.listSync().whereType<File>().length;
  if (topCount > maxFilesPerDir) {
    out.add('tool/gate_a（根）  $topCount 个文件');
  }
  return out;
}

List<String> _docDrift() {
  final golden = File(goldenPath);
  if (!golden.existsSync()) {
    stdout.writeln('      （缺少 $goldenPath，跳过）');
    return const <String>[];
  }
  final out = <String>[];
  for (final line in golden.readAsLinesSync()) {
    if (line.startsWith('#') || line.trim().isEmpty) continue;
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) continue;
    final file = File('gate-a/${parts[1]}');
    if (!file.existsSync()) {
      out.add('${parts[1]}  缺失');
    } else if (sha256Hex(file.readAsBytesSync()) != parts[0]) {
      out.add('${parts[1]}  内容已变化');
    }
  }
  return out;
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
