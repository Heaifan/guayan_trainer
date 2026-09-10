/// 十二地支领域模型（纯 Dart，零 Flutter 依赖）。
///
/// 地支是纳甲、六亲、旬空的共同底座：爻位所值地支由纳甲决定，
/// 五行由本表决定，旬空由日柱决定。严格禁止在其他模块重复定义地支表。
library;

import 'wu_xing.dart';

/// 十二地支（自子起，含五行与阴阳）。
enum DiZhi {
  zi('子', WuXing.shui, true),
  chou('丑', WuXing.tu, false),
  yin('寅', WuXing.mu, true),
  mao('卯', WuXing.mu, false),
  chen('辰', WuXing.tu, true),
  si('巳', WuXing.huo, false),
  wu('午', WuXing.huo, true),
  wei('未', WuXing.tu, false),
  shen('申', WuXing.jin, true),
  you('酉', WuXing.jin, false),
  xu('戌', WuXing.tu, true),
  hai('亥', WuXing.shui, false);

  const DiZhi(this.label, this.wuXing, this.isYang);

  /// 中文名，如「子」。
  final String label;

  /// 地支五行。
  final WuXing wuXing;

  /// 阳支 = true（子寅辰午申戌为阳）。
  final bool isYang;

  /// 按中文名反查；无法识别返回 null（不抛异常，便于校验外部数据）。
  static DiZhi? tryFromLabel(String label) {
    for (final z in DiZhi.values) {
      if (z.label == label) return z;
    }
    return null;
  }

  /// 按中文名反查；无法识别抛异常（用于内部常量表自检）。
  static DiZhi fromLabel(String label) {
    final z = tryFromLabel(label);
    if (z == null) {
      throw ArgumentError.value(label, 'label', '不是合法地支');
    }
    return z;
  }

  /// 六冲（子午、丑未、寅申、卯酉、辰戌、巳亥）。
  DiZhi get chong => DiZhi.values[(index + 6) % 12];

  /// 六合（子丑、寅亥、卯戌、辰酉、巳申、午未）。
  DiZhi get he => switch (this) {
        DiZhi.zi => DiZhi.chou,
        DiZhi.chou => DiZhi.zi,
        DiZhi.yin => DiZhi.hai,
        DiZhi.hai => DiZhi.yin,
        DiZhi.mao => DiZhi.xu,
        DiZhi.xu => DiZhi.mao,
        DiZhi.chen => DiZhi.you,
        DiZhi.you => DiZhi.chen,
        DiZhi.si => DiZhi.shen,
        DiZhi.shen => DiZhi.si,
        DiZhi.wu => DiZhi.wei,
        DiZhi.wei => DiZhi.wu,
      };
}
