/// 起卦当时的**历法快照**（R4 冻结契约）。
///
/// 存的是「当时认定的**结果**」，不是计算器：
/// ```text
/// 起卦时 CalendarEngine → CalendarSnapshot → 写进 HexagramCase
/// 以后 RelationEngine 只读快照，不再重新调用 CalendarEngine
/// ```
/// 理由：历法数据包将来会升级（例如某边界案例由丑月改判寅月）。
/// 若历史卦例每次打开都重算，就会出现「同一个已保存的卦，几年后月建变了」——
/// 复盘系统不能接受这种漂移。
///
/// 只存 `dayGanZhi`（完整干支）而不是只存日支：日干还要供六神等后续能力使用，
/// 既然是快照就不要只截取当前恰好要用的半个字段。
/// 旬空**不重复存** —— 它可由 `dayGanZhi` 确定性推导。
library;

/// 不可变的历法快照：月建支 + 日辰干支。
class CalendarSnapshot {
  const CalendarSnapshot({required this.monthBranch, required this.dayGanZhi});

  /// 月建地支（单字），如 `寅`。
  final String monthBranch;

  /// 日辰干支（两字），如 `己酉`。
  final String dayGanZhi;

  /// 日辰地支（`dayGanZhi` 的第二字）。
  String get dayBranch => dayGanZhi.substring(1);

  /// 日辰天干（`dayGanZhi` 的第一字）。
  String get dayGan => dayGanZhi.substring(0, 1);

  Map<String, Object?> toJson() => {
    'monthBranch': monthBranch,
    'dayGanZhi': dayGanZhi,
  };

  factory CalendarSnapshot.fromJson(Map<String, Object?> json) =>
      CalendarSnapshot(
        monthBranch: json['monthBranch'] as String,
        dayGanZhi: json['dayGanZhi'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is CalendarSnapshot &&
      other.monthBranch == monthBranch &&
      other.dayGanZhi == dayGanZhi;

  @override
  int get hashCode => Object.hash(monthBranch, dayGanZhi);

  @override
  String toString() => 'CalendarSnapshot($monthBranch月, $dayGanZhi日)';
}
