/// 六十四卦结构身份（纯结构真源）。
///
/// 位契约（显式端序，禁止隐含）：bit 0 = 初爻 … bit 5 = 上爻，
/// 与全局爻位方向契约（index = position - 1）一致。
/// 输入只允许 6 个阴阳位；卦名经 [hexagramName] 查表，
/// 禁止解析中文名、禁止依赖 UI / demo data / 日期 / 网络。
library;

import '../trigram.dart';
import 'hexagram_names.dart';

/// 六十四卦身份。
class HexagramIdentity {
  HexagramIdentity(this.bits) {
    if (bits < 0 || bits > 63) {
      throw ArgumentError.value(bits, 'bits', '卦身位必须为 6 bit（0..63）');
    }
  }

  static const int bitCount = 6;

  /// 6 bit 卦身位（bit0 = 初爻）。
  final int bits;

  /// 由自下而上阴阳序列构造（[yangBottomToTop][0] = 初爻）。
  factory HexagramIdentity.fromYangFlags(List<bool> yangBottomToTop) {
    if (yangBottomToTop.length != bitCount) {
      throw ArgumentError.value(
        yangBottomToTop.length,
        'yangBottomToTop',
        '必须恰为 6 爻（初爻..上爻）',
      );
    }
    var bits = 0;
    for (var i = 0; i < bitCount; i++) {
      if (yangBottomToTop[i]) bits |= 1 << i;
    }
    return HexagramIdentity(bits);
  }

  /// 由上下卦构造（上卦占 bit3..5，下卦占 bit0..2）。
  factory HexagramIdentity.fromTrigrams({
    required Trigram upper,
    required Trigram lower,
  }) =>
      HexagramIdentity(lower.code | (upper.code << 3));

  /// [position]（1..6）是否为阳爻。
  bool yangAt(int position) => (bits >> (position - 1)) & 1 == 1;

  /// 下卦（内卦：初爻~三爻）。
  Trigram get lowerTrigram => Trigram.fromCode(bits & 0x7);

  /// 上卦（外卦：四爻~上爻）。
  Trigram get upperTrigram => Trigram.fromCode((bits >> 3) & 0x7);

  /// 卦名（如「天风姤」）。
  String get name => hexagramName(upperTrigram, lowerTrigram);

  /// 翻转 [mask]（bit i = position i+1）指定爻后的新卦。
  HexagramIdentity flipped(int mask) => HexagramIdentity(bits ^ mask);

  @override
  bool operator ==(Object other) => other is HexagramIdentity && other.bits == bits;

  @override
  int get hashCode => bits;

  @override
  String toString() => 'HexagramIdentity(0b${bits.toRadixString(2).padLeft(6, '0')} $name)';
}
