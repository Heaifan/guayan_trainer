/// 旬空（空亡）：由日柱在六十甲子中的位置推导，不维护大型手抄表。
///
/// 六十甲子每 10 日为一旬，旬内天干配满十干，地支只走十位，
/// 余下两位地支即该旬「空亡」。
library;

import '../../di_zhi.dart';
import 'ganzhi_day.dart';

/// 旬空结果。
class XunKong {
  const XunKong._({
    required this.xunHeadIndex,
    required this.first,
    required this.second,
  });

  /// 旬首的六十甲子序号（0/10/20/30/40/50）。
  final int xunHeadIndex;

  /// 空亡第一支（按地支序在前者）。
  final DiZhi first;

  /// 空亡第二支。
  final DiZhi second;

  /// 旬首文本，如「甲子」。
  String get xunHeadLabel => GanZhiDay.fromCycleIndex(xunHeadIndex).label;

  /// 空亡文本，如「戌亥」。
  String get label => '${first.label}${second.label}';

  /// 某地支是否落空。
  bool contains(DiZhi zhi) => zhi == first || zhi == second;

  @override
  String toString() => 'XunKong($label)';
}

/// 由日柱求旬空。
///
/// 例：甲子旬（旬首序号 0）覆盖地支 子..酉，空 **戌亥**；
/// 甲戌旬空 **申酉**，甲申旬空 **午未**，
/// 甲午旬空 **辰巳**，甲辰旬空 **寅卯**，甲寅旬空 **子丑**。
XunKong xunKongOf(GanZhiDay day) {
  final head = (day.cycleIndex ~/ 10) * 10;
  // 旬首地支序号。
  final headZhi = head % 12;
  // 该旬十日的支序为 headZhi .. headZhi+9（模 12），
  // 故缺失的两位恰为 headZhi+10、headZhi+11。
  return XunKong._(
    xunHeadIndex: head,
    first: DiZhi.values[(headZhi + 10) % 12],
    second: DiZhi.values[(headZhi + 11) % 12],
  );
}
