import 'bagua.dart';
import 'double_fucang.dart';
import 'hexagram64.dart';
import 'najia.dart';
import 'six_relative.dart';

/// 全宫大卦双伏藏：本宫纯卦与对宫纯卦始终各生成完整六爻。
class DoubleFucangEngine {
  DoubleFucangEngine._();

  static const ruleSetId = 'fucang.double_palace.v1';

  static DoubleFucangResult calculate(Bagua primaryPalace) {
    final oppositePalace = _oppositeOf(primaryPalace);
    return DoubleFucangResult(
      primaryPalace: primaryPalace,
      oppositePalace: oppositePalace,
      primary: _lines(
        primaryPalace,
        HiddenPalaceRole.primary,
        relativePalace: primaryPalace,
      ),
      opposite: _lines(
        oppositePalace,
        HiddenPalaceRole.opposite,
        relativePalace: primaryPalace,
      ),
    );
  }

  static List<HiddenPalaceLine> _lines(
    Bagua palace,
    HiddenPalaceRole role, {
    required Bagua relativePalace,
  }) {
    final root = resolveHexagram([...palace.lines, ...palace.lines]);
    final gans = najiaGans(root.lower, root.upper);
    final branches = najiaLines(root.lower, root.upper);
    return [
      for (var index = 0; index < 6; index++)
        HiddenPalaceLine(
          lineIndex: index + 1,
          role: role,
          palace: palace,
          sourceHexagramId: root.name,
          // 干支取当前伏藏来源宫；六亲始终以主卦所属宫为“我”。
          relative: sixRelativeOf(relativePalace, branches[index]),
          stem: gans[index],
          branch: branches[index],
          element: branches[index].wuXing,
        ),
    ];
  }

  static Bagua _oppositeOf(Bagua palace) => switch (palace) {
    Bagua.qian => Bagua.kun,
    Bagua.kun => Bagua.qian,
    Bagua.zhen => Bagua.xun,
    Bagua.xun => Bagua.zhen,
    Bagua.kan => Bagua.li,
    Bagua.li => Bagua.kan,
    Bagua.dui => Bagua.gen,
    Bagua.gen => Bagua.dui,
  };
}
