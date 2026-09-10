/// 日界规则：决定「哪一天」在什么时刻切换。
///
/// 六爻不同软件存在 00:00 换日与 23:00 子初换日两种语义；
/// 仓库既有代码未冻结任何规则，因此本层**两种都实现**，
/// 且不提供隐式默认值 —— 必须由调用方显式传入，
/// 最终产品采用哪一种由业务层冻结。
library;

/// 日界规则。
enum DayBoundaryRule {
  /// 民用日：00:00 换日。
  midnight,

  /// 命理日：23:00（子初）换日。
  ziHourStart,
}

/// 该规则下，一个当地时刻所属「日」的起始偏移（小时）。
///
/// [midnight] 为 0；[ziHourStart] 为 23 —— 即 23:00 起已算次日。
int dayBoundaryStartHour(DayBoundaryRule rule) => switch (rule) {
  DayBoundaryRule.midnight => 0,
  DayBoundaryRule.ziHourStart => 23,
};
