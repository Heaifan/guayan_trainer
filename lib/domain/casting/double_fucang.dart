import '../di_zhi.dart';
import '../tian_gan.dart';
import '../wu_xing.dart';
import 'bagua.dart';
import 'six_relative.dart';

enum HiddenPalaceRole { primary, opposite }

class HiddenPalaceLine {
  const HiddenPalaceLine({
    required this.lineIndex,
    required this.role,
    required this.palace,
    required this.sourceHexagramId,
    required this.relative,
    required this.stem,
    required this.branch,
    required this.element,
  });

  final int lineIndex;
  final HiddenPalaceRole role;
  final Bagua palace;
  final String sourceHexagramId;
  final SixRelative relative;
  final TianGan stem;
  final DiZhi branch;
  final WuXing element;

  String get ganZhi => '${stem.label}${branch.label}';

  String get label => '${relative.label}$ganZhi${element.label}';

  String get compactLabel => '${relative.shortLabel}$ganZhi';
}

class DoubleFucangResult {
  const DoubleFucangResult({
    required this.primaryPalace,
    required this.oppositePalace,
    required this.primary,
    required this.opposite,
  });

  final Bagua primaryPalace;
  final Bagua oppositePalace;
  final List<HiddenPalaceLine> primary;
  final List<HiddenPalaceLine> opposite;
}
