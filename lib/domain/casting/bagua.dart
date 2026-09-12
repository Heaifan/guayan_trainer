/// 八卦领域模型（纯 Dart，零 Flutter 依赖）。
///
/// 三爻自下而上（index 0 = 初爻）；重卦由上下两卦叠加而成，
/// 下卦（内卦）占初二三爻，上卦（外卦）占四五六爻。
library;

import '../wu_xing.dart';

/// 八卦。
enum Bagua {
  qian('乾', '☰', WuXing.jin, [true, true, true]),
  dui('兑', '☱', WuXing.jin, [true, true, false]),
  li('离', '☲', WuXing.huo, [true, false, true]),
  zhen('震', '☳', WuXing.mu, [true, false, false]),
  xun('巽', '☴', WuXing.mu, [false, true, true]),
  kan('坎', '☵', WuXing.shui, [false, true, false]),
  gen('艮', '☶', WuXing.tu, [false, false, true]),
  kun('坤', '☷', WuXing.tu, [false, false, false]);

  const Bagua(this.label, this.symbol, this.wuXing, this.lines);

  /// 卦名，如「乾」。
  final String label;

  /// Unicode 卦符，如「☰」。
  final String symbol;

  /// 卦本体五行（注意：六亲取的是**宫位**五行，不是卦本体五行）。
  final WuXing wuXing;

  /// 三爻阴阳，**自下而上**（index 0 = 初爻）；true = 阳。
  final List<bool> lines;

  /// 由三爻阴阳（自下而上）反查卦；非法组合抛异常。
  static Bagua fromLines(List<bool> ls) {
    if (ls.length != 3) {
      throw ArgumentError.value(ls, 'ls', '八卦必须恰好 3 爻');
    }
    for (final b in Bagua.values) {
      if (b.lines[0] == ls[0] && b.lines[1] == ls[1] && b.lines[2] == ls[2]) {
        return b;
      }
    }
    throw StateError('无法识别的三爻组合：$ls');
  }

  /// 先天八卦序（乾一 兑二 离三 震四 巽五 坎六 艮七 坤八）。
  int get xianTianIndex =>
      const [
        Bagua.qian,
        Bagua.dui,
        Bagua.li,
        Bagua.zhen,
        Bagua.xun,
        Bagua.kan,
        Bagua.gen,
        Bagua.kun,
      ].indexOf(this) +
      1;
}
