/// 只读诊断：解析 tool/gate_a 内所有相对 import/export，报告无法解析的目标。
///
/// 运行：`dart run _check_imports.dart`
library;

import 'dart:io';

String norm(String p) {
  // Windows 路径先统一成正斜杠再分段。
  final out = <String>[];
  for (final s in p.replaceAll('\\', '/').split('/')) {
    if (s == '.' || s.isEmpty) continue;
    if (s == '..' && out.isNotEmpty && out.last != '..') {
      out.removeLast();
      continue;
    }
    out.add(s);
  }
  return out.join('/');
}

void main() {
  final root = Directory('tool/gate_a');
  final pattern = RegExp(r"""(import|export)\s+'([^']+)';""");
  var bad = 0;
  final files = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final f in files) {
    final dir = norm(
      f.path.substring(0, f.path.lastIndexOf(RegExp(r'[/\\]'))),
    );
    for (final line in f.readAsLinesSync()) {
      final m = pattern.firstMatch(line);
      if (m == null) continue;
      final target = m.group(2)!;
      if (!target.startsWith('.')) continue;
      final resolved = norm('$dir/$target');
      if (!File(resolved).existsSync() &&
          !Directory(resolved).existsSync()) {
        bad++;
        stdout.writeln('BAD  ${f.path.replaceAll('\\', '/')}');
        stdout.writeln('       -> $target');
      }
    }
  }
  stdout.writeln('');
  stdout.writeln(bad == 0 ? 'OK：所有相对 import 均可解析' : 'BAD: $bad 条无法解析');
  if (bad > 0) exitCode = 1;
}
