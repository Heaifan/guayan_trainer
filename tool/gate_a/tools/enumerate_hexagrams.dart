/// Gate A 一次性探查：枚举 64 卦的六冲 / 六合 / 游魂 / 归魂归属。
///
/// 用途：为案例矩阵的「覆盖点」标注提供**程序化**依据，
/// 替代手感分类（手感分类在本次 Gate A 中已多次出错）。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/casting/bagua.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/casting/najia.dart';
import 'package:guayan_trainer/domain/casting/palace.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/line_state.dart';

void main() {
  final chong = <String>[];
  final he = <String>[];
  final youHun = <String>[];
  final guiHun = <String>[];
  final byPalace = <String, List<String>>{};

  for (final entry in baGongTable) {
    final h = resolveHexagram(entry.lines);
    final chart = CastingEngine.cast([
      for (var i = 0; i < 6; i++)
        entry.lines[i] ? MovementType.shaoYang : MovementType.shaoYin,
    ]);
    final branches = [for (final l in chart.lines) l.branch];
    // 六冲：六爻支两两相冲。
    final seen = <DiZhi>{};
    var chongPairs = 0;
    var hePairs = 0;
    var dup = false;
    for (final z in branches) {
      if (!seen.add(z)) dup = true;
      if (seen.contains(z.chong)) chongPairs++;
      if (seen.contains(z.he)) hePairs++;
    }
    if (!dup && chongPairs == 3) chong.add(h.name);
    if (!dup && hePairs == 3) he.add(h.name);
    if (entry.rank == PalaceRank.youHun) youHun.add(h.name);
    if (entry.rank == PalaceRank.guiHun) guiHun.add(h.name);
    byPalace.putIfAbsent(entry.palace.label, () => []).add(
      '${h.name}(${entry.rank.label}·世${entry.shiPosition})',
    );
  }

  stdout.writeln('六冲卦（${chong.length}）：${chong.join('、')}');
  stdout.writeln('六合卦（${he.length}）：${he.join('、')}');
  stdout.writeln('游魂卦（${youHun.length}）：${youHun.join('、')}');
  stdout.writeln('归魂卦（${guiHun.length}）：${guiHun.join('、')}');
  stdout.writeln('');
  for (final e in byPalace.entries) {
    stdout.writeln('${e.key}宫：${e.value.join('  ')}');
  }
  stdout.writeln('');
  stdout.writeln('== 关键卦纳甲 ==');
  for (final bits in <String>[
    '111111',
    '000000',
    '000010',
    '011000',
    '001000',
    '000100',
    '001110',
    '110001',
  ]) {
    final lines = [for (final ch in bits.split('')) ch == '1'];
    final h = resolveHexagram(lines);
    final chart = CastingEngine.cast([
      for (final b in lines)
        b ? MovementType.shaoYang : MovementType.shaoYin,
    ]);
    stdout.writeln(
      '  $bits ${h.name}（${h.palace.label}宫·${h.rank.label}·'
      '世${h.shiPosition}应${h.yingPosition}）纳甲 '
      '${[for (final l in chart.lines) l.ganZhi].join(' ')}',
    );
  }
  // 静卦用的纳甲表顺序自检
  stdout.writeln('');
  for (final b in Bagua.values) {
    stdout.writeln(
      '  ${b.label}：内 ${najiaByBagua[b]!.sublist(0, 3).map((z) => z.label).join(' ')}'
      '  外 ${najiaByBagua[b]!.sublist(3, 6).map((z) => z.label).join(' ')}',
    );
  }
}
