/// 历法请求：一切输入显式传入。
///
/// 核心层**禁止**读取 `DateTime.now()`、系统当前时区、网络时间或在线时区 API。
/// 本类只做一件事：把「当地挂钟时间 + 偏移」确定性地折算成统一 UTC 瞬间。
library;

import 'day_boundary_rule.dart';

/// 一次历法求解的输入。
class CalendarRequest {
  const CalendarRequest({
    required this.localDateTime,
    required this.utcOffset,
    required this.dayBoundaryRule,
  });

  /// 当地挂钟时间（只取其年月日时分秒字段，不依赖宿主时区）。
  final DateTime localDateTime;

  /// 当地相对 UTC 的偏移（如东八区 = `Duration(hours: 8)`）。
  final Duration utcOffset;

  /// 日界规则；**无隐式默认值**，必须显式选定。
  final DayBoundaryRule dayBoundaryRule;

  /// 统一 UTC 瞬间。
  ///
  /// 先按字段重建成 UTC 墙钟再减偏移，避免宿主时区参与运算。
  DateTime get instantUtc => DateTime.utc(
    localDateTime.year,
    localDateTime.month,
    localDateTime.day,
    localDateTime.hour,
    localDateTime.minute,
    localDateTime.second,
    localDateTime.millisecond,
    localDateTime.microsecond,
  ).subtract(utcOffset);
}
