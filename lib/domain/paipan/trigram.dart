/// 八卦唯一真源（R6 排盘底盘）。
///
/// 编码契约：3 bit，bit0 = 初爻（下爻）、bit2 = 三爻（上爻）——
/// 与全局爻位方向契约（index = position - 1）一致，显式端序、禁止隐含。
/// 先天卦形（自下而上）：
/// 乾☰阳阳阳 兑☱阳阳阴 离☲阳阴阳 震☳阳阴阴
/// 巽☴阴阳阳 坎☵阴阳阴 艮☶阴阴阳 坤☷阴阴阴。
/// 八卦五行：乾兑金、震巽木、坎水、离火、艮坤土。
/// 禁止其他模块自建八卦编码表。
library;

import 'wuxing.dart';

/// 八卦。
enum Trigram {
  qian('乾', 7, FiveElement.metal), // 0b111
  dui('兑', 3, FiveElement.metal), // 0b011
  li('离', 5, FiveElement.fire), // 0b101
  zhen('震', 1, FiveElement.wood), // 0b001
  xun('巽', 6, FiveElement.wood), // 0b110
  kan('坎', 2, FiveElement.water), // 0b010
  gen('艮', 4, FiveElement.earth), // 0b100
  kun('坤', 0, FiveElement.earth); // 0b000

  const Trigram(this.name, this.code, this.element);

  /// 卦名（单字，与卦名表键一致）。
  final String name;

  /// 3 bit 编码（bit0 = 初爻）。
  final int code;

  /// 卦五行（宫五行 / 纳甲五行推导的上游真源）。
  final FiveElement element;

  /// 自下而上第 [lineIndex]（0..2）爻是否为阳。
  bool yangAt(int lineIndex) => (code >> lineIndex) & 1 == 1;

  static Trigram fromCode(int code) {
    for (final t in values) {
      if (t.code == code) return t;
    }
    throw ArgumentError.value(code, 'code', '八卦编码必须为 0..7');
  }

  static Trigram fromName(String name) {
    for (final t in values) {
      if (t.name == name) return t;
    }
    throw ArgumentError.value(name, 'name', '非法卦名');
  }
}
