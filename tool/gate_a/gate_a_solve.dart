/// 一次性辅助：按卦名算出位串，并给出「本卦 → 目标卦」需要动的爻位（0 基）。
///
/// 手写成卦名极易错位，因此位串与动爻一律由卦名程序化求出。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/casting/hexagram64.dart';

/// 遍历 64 个组合建立「卦名 → 位串」索引。
Map<String, String> buildNameIndex() {
  final out = <String, String>{};
  for (var v = 0; v < 64; v++) {
    final bits = <bool>[for (var i = 0; i < 6; i++) (v >> i) & 1 == 1];
    out[resolveHexagram(bits).name] =
        bits.map((b) => b ? '1' : '0').join();
  }
  return out;
}

void main(List<String> args) {
  final index = buildNameIndex();
  if (args.isEmpty) {
    // 打印全部 64 卦的位串，供人工查阅。
    final entries = index.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    for (final e in entries) {
      stdout.writeln('${e.value}  ${e.key}');
    }
    return;
  }
  // 用法：solve <本卦名> <目标卦名>
  final from = args[0];
  final to = args[1];
  final a = index[from];
  final b = index[to];
  if (a == null || b == null) {
    stdout.writeln('卦名无法识别：${a == null ? from : to}');
    exitCode = 1;
    return;
  }
  final positions = <int>[
    for (var i = 0; i < 6; i++)
      if (a[i] != b[i]) i,
  ];
  stdout.writeln('$from 位串 $a');
  stdout.writeln('$to 位串 $b');
  stdout.writeln(
    '动爻（0 基）= [${positions.join(', ')}]  '
    '（人读 1 基 = ${positions.map((i) => i + 1).join('、')}）',
  );
}
