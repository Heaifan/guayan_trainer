import 'hexagram64.dart';
import 'bagua.dart';
import 'palace.dart';

enum EightPalaceStage {
  benGong('本宫', 6),
  yiShi('一世', 1),
  erShi('二世', 2),
  sanShi('三世', 3),
  siShi('四世', 4),
  wuShi('五世', 5),
  youHun('游魂', 4),
  guiHun('归魂', 3);

  const EightPalaceStage(this.label, this.shiLine);

  final String label;
  final int shiLine;
  int get yingLine => shiLine <= 3 ? shiLine + 3 : shiLine - 3;
}

class HexagramPalaceProfile {
  const HexagramPalaceProfile({
    required this.palace,
    required this.stage,
    required this.shiLine,
    required this.yingLine,
  });

  factory HexagramPalaceProfile.fromHexagram(Hexagram hexagram) =>
      HexagramPalaceProfile(
        palace: hexagram.palace,
        stage: _stageOf(hexagram.rank),
        shiLine: hexagram.shiPosition,
        yingLine: hexagram.yingPosition,
      );

  final Bagua palace;
  final EightPalaceStage stage;
  final int shiLine;
  final int yingLine;

  String get compactStage => stage.label;
}

EightPalaceStage _stageOf(PalaceRank rank) => switch (rank) {
  PalaceRank.benGong => EightPalaceStage.benGong,
  PalaceRank.yiShi => EightPalaceStage.yiShi,
  PalaceRank.erShi => EightPalaceStage.erShi,
  PalaceRank.sanShi => EightPalaceStage.sanShi,
  PalaceRank.siShi => EightPalaceStage.siShi,
  PalaceRank.wuShi => EightPalaceStage.wuShi,
  PalaceRank.youHun => EightPalaceStage.youHun,
  PalaceRank.guiHun => EightPalaceStage.guiHun,
};
