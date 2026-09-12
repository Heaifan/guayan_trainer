/// 京房八宫卦序：宫位归属与世应位置的算法来源。
///
/// 世应不是 64 条硬编码表，而是由「本宫卦逐爻变化」的固定规则完全确定：
///
/// ```text
/// 本宫(世6) → 一世(世1) → 二世(世2) → 三世(世3)
///          → 四世(世4) → 五世(世5) → 游魂(世4) → 归魂(世3)
/// ```
///
/// 每一步只翻转指定爻位：一世翻转初爻，二世翻转二爻，三世翻转三爻，
/// 四世翻转四爻，五世翻转五爻，游魂**回到四爻再翻一次**，
/// 归魂则把内卦整体还原为本宫卦。
library;

import 'bagua.dart';

/// 卦在所属宫中的位次（决定世爻）。
enum PalaceRank {
  benGong('本宫卦', 6),
  yiShi('一世', 1),
  erShi('二世', 2),
  sanShi('三世', 3),
  siShi('四世', 4),
  wuShi('五世', 5),
  youHun('游魂', 4),
  guiHun('归魂', 3);

  const PalaceRank(this.label, this.shiPosition);

  final String label;

  /// 世爻位置（1..6）。
  final int shiPosition;
}

/// 八宫卦序中的一项：卦的阴阳六爻 + 宫 + 位次。
class PalaceEntry {
  const PalaceEntry({
    required this.lines,
    required this.palace,
    required this.rank,
  });

  /// 六爻阴阳，**自下而上**（index 0 = 初爻）；true = 阳。
  final List<bool> lines;

  /// 所属宫（该宫五行为六亲判定的「我」）。
  final Bagua palace;

  /// 宫中位次。
  final PalaceRank rank;

  /// 下卦（内卦）。
  Bagua get lower => Bagua.fromLines(lines.sublist(0, 3));

  /// 上卦（外卦）。
  Bagua get upper => Bagua.fromLines(lines.sublist(3, 6));

  /// 世爻位置（1..6）。
  int get shiPosition => rank.shiPosition;

  /// 应爻位置（1..6）：世应相隔三位。
  int get yingPosition => shiPosition <= 3 ? shiPosition + 3 : shiPosition - 3;
}

/// 八宫顺序（京房）：乾 坎 艮 震 巽 离 坤 兑。
const List<Bagua> baGongOrder = [
  Bagua.qian,
  Bagua.kan,
  Bagua.gen,
  Bagua.zhen,
  Bagua.xun,
  Bagua.li,
  Bagua.kun,
  Bagua.dui,
];

/// 八宫 64 卦全表（构建一次，顺序稳定）。
final List<PalaceEntry> baGongTable = _buildBaGongTable();

List<bool> _flip(List<bool> src, int index) {
  final out = List<bool>.of(src);
  out[index] = !out[index];
  return out;
}

List<PalaceEntry> _buildBaGongTable() {
  final out = <PalaceEntry>[];
  for (final palace in baGongOrder) {
    final pure = [...palace.lines, ...palace.lines];
    final yi = _flip(pure, 0);
    final er = _flip(yi, 1);
    final san = _flip(er, 2);
    final si = _flip(san, 3);
    final wu = _flip(si, 4);
    final you = _flip(wu, 3);
    final gui = [...palace.lines, ...you.sublist(3, 6)];

    out.addAll([
      PalaceEntry(lines: pure, palace: palace, rank: PalaceRank.benGong),
      PalaceEntry(lines: yi, palace: palace, rank: PalaceRank.yiShi),
      PalaceEntry(lines: er, palace: palace, rank: PalaceRank.erShi),
      PalaceEntry(lines: san, palace: palace, rank: PalaceRank.sanShi),
      PalaceEntry(lines: si, palace: palace, rank: PalaceRank.siShi),
      PalaceEntry(lines: wu, palace: palace, rank: PalaceRank.wuShi),
      PalaceEntry(lines: you, palace: palace, rank: PalaceRank.youHun),
      PalaceEntry(lines: gui, palace: palace, rank: PalaceRank.guiHun),
    ]);
  }
  return out;
}
