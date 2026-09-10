/// 六十四卦解析：由六爻阴阳（自下而上）得到卦名、宫位、世应。
///
/// 解析结果同时携带该卦在八宫中的位次，因此宫位五行（六亲的「我」）
/// 与世应位置都无需二次查表。
library;

import 'bagua.dart';
import 'hexagram_names.dart';
import 'palace.dart';

/// 解析完成的重卦。
class Hexagram {
  const Hexagram({required this.entry, required this.name});

  /// 八宫表项（宫位 / 位次 / 六爻）。
  final PalaceEntry entry;

  /// 卦名，如「泽山咸」。
  final String name;

  /// 六爻阴阳，自下而上（index 0 = 初爻）。
  List<bool> get lines => entry.lines;

  /// 下卦（内卦）。
  Bagua get lower => entry.lower;

  /// 上卦（外卦）。
  Bagua get upper => entry.upper;

  /// 所属宫。
  Bagua get palace => entry.palace;

  /// 宫中位次（本宫/一世/…/归魂）。
  PalaceRank get rank => entry.rank;

  /// 世爻位置（1..6）。
  int get shiPosition => entry.shiPosition;

  /// 应爻位置（1..6）。
  int get yingPosition => entry.yingPosition;

  /// 逐爻阴阳（position → 是否阳），便于按爻位取值。
  bool isYangAt(int position) => lines[position - 1];
}

String _key(List<bool> lines) => lines.map((b) => b ? '1' : '0').join();

/// lines 键（如 "101010"，自下而上）→ 八宫表项。
final Map<String, PalaceEntry> _indexByKey = {
  for (final e in baGongTable) _key(e.lines): e,
};

/// 由六爻阴阳（自下而上，index 0 = 初爻）解析重卦。
///
/// 非法输入（爻数不足 / 表中无此组合）抛异常，绝不静默返回错误卦。
Hexagram resolveHexagram(List<bool> lines) {
  if (lines.length != 6) {
    throw ArgumentError.value(lines, 'lines', '重卦必须恰好 6 爻');
  }
  final key = _key(lines);
  final entry = _indexByKey[key];
  if (entry == null) {
    throw StateError('六十四卦表未覆盖该组合：$key');
  }
  return Hexagram(entry: entry, name: hexagramNameOf(entry.upper, entry.lower));
}
