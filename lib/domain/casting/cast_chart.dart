/// 排盘结果模型：本卦 / 变卦 / 六爻完整信息。
///
/// 纯数据 + 展示派生，不含任何计算规则（规则一律在引擎与各专题模块中）。
library;

import '../di_zhi.dart';
import '../tian_gan.dart';
import 'hexagram64.dart';
import 'six_relative.dart';
import 'six_spirit.dart';

/// 单爻排盘结果（本卦侧 + 变卦侧）。
class CastLine {
  const CastLine({
    required this.position,
    required this.isYang,
    required this.isMoving,
    required this.gan,
    required this.branch,
    required this.relative,
    required this.isShi,
    required this.isYing,
    this.spirit,
    this.changedIsYang,
    this.changedGan,
    this.changedBranch,
    this.changedRelative,
  });

  /// 爻位：1 = 初爻 … 6 = 上爻。
  final int position;

  /// 本卦该爻是否阳。
  final bool isYang;

  /// 是否动爻。
  final bool isMoving;

  /// 本卦纳甲天干。
  final TianGan gan;

  /// 本卦纳甲地支。
  final DiZhi branch;

  /// 本卦六亲（以本卦之宫为「我」）。
  final SixRelative relative;

  /// 六神；未提供日干时为 null（不猜、不默认）。
  final SixSpirit? spirit;

  /// 是否世爻。
  final bool isShi;

  /// 是否应爻。
  final bool isYing;

  /// 变卦该爻是否阳；无变卦时为 null。
  final bool? changedIsYang;

  /// 变卦纳甲天干；无变卦时为 null。
  final TianGan? changedGan;

  /// 变卦纳甲地支；无变卦时为 null。
  final DiZhi? changedBranch;

  /// 变卦六亲（**仍以本卦之宫为「我」**，传统固定规则）。
  final SixRelative? changedRelative;

  /// 本卦纳甲干支文本，如「丙寅」。
  String get ganZhi => '${gan.label}${branch.label}';

  /// 变卦纳甲干支文本；无变卦时为 null。
  String? get changedGanZhi =>
      (changedGan == null || changedBranch == null)
          ? null
          : '${changedGan!.label}${changedBranch!.label}';

  /// 世应标记：世 / 应 / 空串。
  String get shiYingLabel => isShi ? '世' : (isYing ? '应' : '');
}

/// 一次排盘的完整结果。
class CastChart {
  const CastChart({
    required this.original,
    required this.changed,
    required this.lines,
    required this.movingPositions,
    this.dayGan,
  });

  /// 本卦。
  final Hexagram original;

  /// 变卦；无动爻时为 null（静卦不变）。
  final Hexagram? changed;

  /// 六爻，自初爻至上爻（index 0 = 初爻）。
  final List<CastLine> lines;

  /// 动爻位置（升序）。
  final List<int> movingPositions;

  /// 排盘所用日干（六神起例依据）；未提供时为 null。
  final TianGan? dayGan;

  /// 是否存在变卦。
  bool get hasChanged => changed != null;

  /// 是否为静卦（无动爻）。
  bool get isStatic => movingPositions.isEmpty;

  /// 按爻位取爻（1..6）。
  CastLine lineAt(int position) => lines[position - 1];
}
