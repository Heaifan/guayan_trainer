/// 规则 3：生成文档的 SHA256 必须仍等于治理前的**黄金快照**。
///
/// 快照行格式：`<SHA256>  <相对文件名>`；`#` 开头与空行忽略。
/// 快照文件本身缺失时**明确打印跳过**，不得静默当成 PASS。
library;

import 'dart:io';

import '../checks/sha256.dart';

/// 漂移清单（`文件名  缺失/内容已变化`）。
///
/// 返回 `null` 表示快照文件不存在 —— 调用方必须把这种情况打印出来，
/// 而不是当作「无漂移」。
List<String>? docDrift(String goldenPath, String docDir) {
  final golden = File(goldenPath);
  if (!golden.existsSync()) return null;
  final out = <String>[];
  for (final line in golden.readAsLinesSync()) {
    final text = line.trim();
    if (text.isEmpty || text.startsWith('#')) continue;
    final parts = text.split(RegExp(r'\s+'));
    if (parts.length < 2) continue;
    final name = parts.sublist(1).join(' ');
    final file = File('$docDir/$name');
    if (!file.existsSync()) {
      out.add('$name  缺失');
    } else if (sha256Hex(file.readAsBytesSync()) != parts[0]) {
      out.add('$name  内容已变化');
    }
  }
  return out;
}
