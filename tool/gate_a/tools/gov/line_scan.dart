/// 规则 1：普通 Dart 源文件行数 <= [maxLines]。
///
/// 口径：`readAsLinesSync().length`（注释与空行同样计入）——
/// 这与编辑器显示的行号一致，避免「压行凑数」式的自欺。
library;

import 'dart:io';

import 'dir_scan.dart';

/// 超长文件清单（`相对路径  行数`），按仓库根取相对路径便于粘贴进报告。
List<String> overLongDartFiles(
  Directory root,
  Directory repoRoot,
  int maxLines,
) {
  final out = <String>[];
  final base = slashPath(repoRoot.path);
  for (final f in root.listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    final n = f.readAsLinesSync().length;
    if (n > maxLines) {
      final p = slashPath(f.path);
      out.add(
        '${p.startsWith('$base/') ? p.substring(base.length + 1) : p}  $n 行',
      );
    }
  }
  out.sort();
  return out;
}
