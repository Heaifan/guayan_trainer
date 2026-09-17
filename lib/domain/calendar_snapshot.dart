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

import 'shensha/shensha_models.dart';

/// 不可变的历法快照：月建支 + 日辰干支。
class CalendarSnapshot {
  const CalendarSnapshot({
    required this.monthBranch,
    required this.dayGanZhi,
    this.lunarDate,
    this.shichen,
    this.yearGanZhi,
    this.hourGanZhi,
    this.shenShaResults = const [],
  });

  /// 月建地支（单字），如 `寅`。
  final String monthBranch;

  /// 日辰干支（两字），如 `己酉`。
  final String dayGanZhi;

  /// 农历日期文本，如「丙午年八月初七」。
  final String? lunarDate;

  /// 起卦当地时辰地支，如「亥」。
  final String? shichen;

  final String? yearGanZhi;

  final String? hourGanZhi;

  final List<ShenShaResult> shenShaResults;

  CalendarSnapshot copyWith({List<ShenShaResult>? shenShaResults}) =>
      CalendarSnapshot(
        monthBranch: monthBranch,
        dayGanZhi: dayGanZhi,
        lunarDate: lunarDate,
        shichen: shichen,
        yearGanZhi: yearGanZhi,
        hourGanZhi: hourGanZhi,
        shenShaResults: shenShaResults ?? this.shenShaResults,
      );

  /// 日辰地支（`dayGanZhi` 的第二字）。
  String get dayBranch => dayGanZhi.substring(1);

  /// 日辰天干（`dayGanZhi` 的第一字）。
  String get dayGan => dayGanZhi.substring(0, 1);

  Map<String, Object?> toJson() => {
    'monthBranch': monthBranch,
    'dayGanZhi': dayGanZhi,
    if (lunarDate != null) 'lunarDate': lunarDate,
    if (shichen != null) 'shichen': shichen,
    if (yearGanZhi != null) 'yearGanZhi': yearGanZhi,
    if (hourGanZhi != null) 'hourGanZhi': hourGanZhi,
    if (shenShaResults.isNotEmpty)
      'shenShaResults': shenShaResults
          .map((result) => result.toJson())
          .toList(),
  };

  factory CalendarSnapshot.fromJson(Map<String, Object?> json) =>
      CalendarSnapshot(
        monthBranch: json['monthBranch'] as String,
        dayGanZhi: json['dayGanZhi'] as String,
        lunarDate: json['lunarDate'] as String?,
        shichen: json['shichen'] as String?,
        yearGanZhi: json['yearGanZhi'] as String?,
        hourGanZhi: json['hourGanZhi'] as String?,
        shenShaResults: [
          for (final item
              in (json['shenShaResults'] as List<Object?>? ?? const []))
            ShenShaResult.fromJson(item as Map<String, Object?>),
        ],
      );

  @override
  bool operator ==(Object other) =>
      other is CalendarSnapshot &&
      other.monthBranch == monthBranch &&
      other.dayGanZhi == dayGanZhi &&
      other.lunarDate == lunarDate &&
      other.shichen == shichen &&
      other.yearGanZhi == yearGanZhi &&
      other.hourGanZhi == hourGanZhi &&
      _sameResults(other.shenShaResults, shenShaResults);

  @override
  int get hashCode => Object.hash(
    monthBranch,
    dayGanZhi,
    lunarDate,
    shichen,
    yearGanZhi,
    hourGanZhi,
    shenShaResults.map((result) => result.hashCode).join(','),
  );

  @override
  String toString() => 'CalendarSnapshot($monthBranch月, $dayGanZhi日)';
}

bool _sameResults(List<ShenShaResult> first, List<ShenShaResult> second) =>
    first.length == second.length &&
    first.asMap().entries.every((entry) => entry.value == second[entry.key]);
