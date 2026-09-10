/// 历法求解结果：排盘所需的历法上下文。
library;

import '../di_zhi.dart';
import 'day/ganzhi_day.dart';
import 'day/xun_kong.dart';

/// 起卦时间对应的历法上下文。
class CalendarContext {
  const CalendarContext({
    required this.instantUtc,
    required this.monthBranch,
    required this.day,
    required this.xunKong,
  });

  /// 归算后的 UTC 瞬间（月建判定基准）。
  final DateTime instantUtc;

  /// 月建（由十二「节」切换，非公历月）。
  final DiZhi monthBranch;

  /// 日柱 / 日辰。
  final GanZhiDay day;

  /// 旬空（由日柱推导）。
  final XunKong xunKong;

  /// 日辰干支文本，如「甲子」。
  String get dayGanZhi => day.label;

  /// 月建地支文本，如「酉」。
  String get monthBranchLabel => monthBranch.label;

  /// 旬空文本，如「申酉」。
  String get xunKongLabel => xunKong.label;

  @override
  String toString() =>
      'CalendarContext(月建 $monthBranchLabel, '
      '日辰 $dayGanZhi, 旬空 $xunKongLabel)';
}
