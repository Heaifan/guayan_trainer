/// Gate A 案例的**类型定义与构造规则**（不含具体案例数据）。
///
/// 拆出原因：案例数据与「位串 → 六爻动静」的构造规则是两件事，
/// 分开后各自可独立阅读与核对。边界类的类型见 `boundary_cases.dart`。
library;

import 'package:guayan_trainer/domain/line_state.dart';

/// 少阳 / 少阴 / 老阳 / 老阴 的惯用数字记法（7/8/9/6）。
int movementDigit(MovementType m) => switch (m) {
  MovementType.shaoYang => 7,
  MovementType.shaoYin => 8,
  MovementType.laoYang => 9,
  MovementType.laoYin => 6,
};

/// 位串 → 十进位值（与八卦表同构），供人工快速核对位串写成。
int bitsValue(String bits) {
  var v = 0;
  for (var i = 0; i < 6; i++) {
    if (bits[i] == '1') v += 1 << i;
  }
  return v;
}

/// 用位串构造全部为「少」的静卦输入。
///
/// 用位串而非手写枚举，是因为手写 6 个枚举值已多次把卦写错 ——
/// 位串与 `resolveHexagram` 的键完全同构，肉眼可直接核对。
List<MovementType> movesOf(String bits) => <MovementType>[
  for (final ch in bits.split(''))
    if (ch == '1') MovementType.shaoYang else MovementType.shaoYin,
];

/// 一个六爻输入案例。
class GateACase {
  const GateACase({
    required this.id,
    required this.group,
    required this.localTime,
    required this.originalBits,
    this.movingPositions = const <int>[],
    required this.expectedOriginal,
    this.expectedChanged,
    required this.purpose,
  });

  /// 案例编号，如 `GA-01`。
  final String id;

  /// 所属分组：`GA-1` / `GA-2`。
  final String group;

  /// 当地挂钟时间文本 `YYYY-MM-DD HH:mm:ss`。
  final String localTime;

  /// 本卦六爻阴阳位串。
  ///
  /// 键约定与 `resolveHexagram` 的 `_key` **完全一致：index 0 = 初爻 … index 5 = 上爻**，
  /// 即前三位是**下卦（内卦）**、后三位是**上卦（外卦）**。
  /// 例：泽地萃 = 下坤 000 + 上兑 110 = `000110`。
  final String originalBits;

  /// 动爻下标（**0..5，与 [originalBits] 的字符下标严格一致**）；
  /// 空 = 静卦。展示时统一 +1 转成人读的 1..6 爻位。
  final List<int> movingPositions;

  /// 本卦卦名（用于**锁定**案例，防止位串写错）。
  final String expectedOriginal;

  /// 变卦卦名；静卦为 null。
  final String? expectedChanged;

  /// 本例要覆盖的点。
  final String purpose;

  /// 六爻动静（自初爻至上爻）。
  List<MovementType> get movements {
    final out = <MovementType>[];
    for (var i = 0; i < 6; i++) {
      final yang = originalBits[i] == '1';
      final moving = movingPositions.contains(i);
      out.add(switch ((yang, moving)) {
        (true, false) => MovementType.shaoYang,
        (true, true) => MovementType.laoYang,
        (false, false) => MovementType.shaoYin,
        (false, true) => MovementType.laoYin,
      });
    }
    return out;
  }

  /// 六爻输入的可读文本，如 `7 8 9 8 7 6`。
  String get inputText => movements.map((m) => movementDigit(m)).join(' ');

  /// 动爻显示文本（1 基爻位，人读）。
  String get movingText => movingPositions.isEmpty
      ? '静卦'
      : '${movingPositions.map((i) => i + 1).join('、')} 爻动';
}
