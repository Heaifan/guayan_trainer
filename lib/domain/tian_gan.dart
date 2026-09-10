/// 十天干领域模型（纯 Dart，零 Flutter 依赖）。
///
/// 天干用于四柱（年/月/日/时柱）与六神起例（按日干起青龙）。
library;

import 'wu_xing.dart';

/// 十天干（甲..癸）。
enum TianGan {
  jia('甲', WuXing.mu, true),
  yi('乙', WuXing.mu, false),
  bing('丙', WuXing.huo, true),
  ding('丁', WuXing.huo, false),
  wu('戊', WuXing.tu, true),
  ji('己', WuXing.tu, false),
  geng('庚', WuXing.jin, true),
  xin('辛', WuXing.jin, false),
  ren('壬', WuXing.shui, true),
  gui('癸', WuXing.shui, false);

  const TianGan(this.label, this.wuXing, this.isYang);

  /// 中文名，如「甲」。
  final String label;

  /// 天干五行。
  final WuXing wuXing;

  /// 阳干 = true（甲丙戊庚壬）。
  final bool isYang;

  /// 由六十甲子序号（0..59）取天干。
  static TianGan fromCycleIndex(int cycleIndex) =>
      TianGan.values[cycleIndex % 10];

  /// 按中文名反查；无法识别返回 null。
  static TianGan? tryFromLabel(String label) {
    for (final g in TianGan.values) {
      if (g.label == label) return g;
    }
    return null;
  }

  /// 按中文名反查；无法识别抛异常（内部常量表自检用）。
  static TianGan fromLabel(String label) {
    final g = tryFromLabel(label);
    if (g == null) {
      throw ArgumentError.value(label, 'label', '不是合法天干');
    }
    return g;
  }
}
