/// 八宫归属 + 宫五行 + 世应（京房八宫，纯推导，无 64 卦手写归属表）。
///
/// 推导真源：每宫以本宫卦（上下卦同体）为基础，按爻翻掩码序列生成 8 卦：
/// 本宫(000000) → 一世(翻初爻) → 二世 → 三世 → 四世 → 五世(翻一~五爻)
/// → 游魂(五世再翻四爻) → 归魂(游魂再翻一~三爻，即与本宫只差上爻)。
/// 位契约：bit i = position i+1（初爻 = bit0）。
/// 世应位置契约冻结（position 口径，1 = 初爻 … 6 = 上爻）：
/// 本宫世6应3 / 一世1应4 / 二世2应5 / 三世3应6 /
/// 四世4应1 / 五世5应2 / 游魂4应1 / 归魂3应6。
library;

import '../trigram.dart';
import '../wuxing.dart';

/// 八宫阶段。
enum PalaceStage {
  benGong('本宫', 6, 3),
  yiShi('一世', 1, 4),
  erShi('二世', 2, 5),
  sanShi('三世', 3, 6),
  siShi('四世', 4, 1),
  wuShi('五世', 5, 2),
  youHun('游魂', 4, 1),
  guiHun('归魂', 3, 6);

  const PalaceStage(this.label, this.shiPosition, this.yingPosition);

  final String label;

  /// 世爻爻位（position 1..6）。
  final int shiPosition;

  /// 应爻爻位（position 1..6）。
  final int yingPosition;
}

/// 各阶段的爻翻掩码（bit i = position i+1）。
const List<(PalaceStage, int)> stageFlipMasks = [
  (PalaceStage.benGong, 0), // 0b000000
  (PalaceStage.yiShi, 1), // 0b000001
  (PalaceStage.erShi, 3), // 0b000011
  (PalaceStage.sanShi, 7), // 0b000111
  (PalaceStage.siShi, 15), // 0b001111
  (PalaceStage.wuShi, 31), // 0b011111
  (PalaceStage.youHun, 23), // 0b010111
  (PalaceStage.guiHun, 16), // 0b010000
];

/// 八宫归属结果。
class PalaceInfo {
  const PalaceInfo({
    required this.palaceTrigram,
    required this.stage,
  });

  /// 宫的本宫八卦（宫五行 = 卦五行）。
  final Trigram palaceTrigram;

  /// 在该宫中的阶段。
  final PalaceStage stage;

  String get palaceName => '${palaceTrigram.name}宫';

  /// 宫五行（六亲「我」的唯一来源）。
  FiveElement get palaceElement => palaceTrigram.element;

  int get shiPosition => stage.shiPosition;

  int get yingPosition => stage.yingPosition;
}

/// 卦身位 → 八宫归属（由掩码规则一次性推导）。
final Map<int, PalaceInfo> palaceByBits = {
  for (final t in Trigram.values)
    for (final (stage, mask) in stageFlipMasks)
      (t.code | (t.code << 3)) ^ mask:
          PalaceInfo(palaceTrigram: t, stage: stage),
};

/// 八宫归属（64 卦每卦恰属一宫一阶段；bits 越界抛出）。
PalaceInfo classifyPalace(int bits) {
  final info = palaceByBits[bits];
  if (info == null) {
    throw ArgumentError.value(bits, 'bits', '非法卦身位（必须 0..63）');
  }
  return info;
}
