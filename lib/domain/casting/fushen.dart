import '../di_zhi.dart';
import '../tian_gan.dart';
import '../wu_xing.dart';
import 'bagua.dart';
import 'six_relative.dart';

/// 一条由本宫首卦推导出的伏神事实。
class FushenResult {
  const FushenResult({
    required this.lineIndex,
    required this.relative,
    required this.stem,
    required this.branch,
    required this.element,
    required this.sourcePalace,
    required this.sourceHexagramId,
    required this.flyingLineId,
    required this.ruleSetId,
    required this.ruleVersion,
    required this.reasonSnapshot,
  });

  /// 伏在第几爻（1..6）。
  final int lineIndex;
  final SixRelative relative;
  final TianGan stem;
  final DiZhi branch;
  final WuXing element;
  final Bagua sourcePalace;
  final String sourceHexagramId;
  final String flyingLineId;
  final String ruleSetId;
  final String ruleVersion;
  final String reasonSnapshot;

  String get ganZhi => '${stem.label}${branch.label}';

  String get label => '${relative.label}$ganZhi${element.label}';
}
