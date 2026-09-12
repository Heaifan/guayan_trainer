/// 太阳视黄经 → 交节时刻求根。
///
/// **第三方尺子的状态：REJECTED AS GATE ORACLE**（保留为 diagnostic tool）。
/// 它与官方发布时刻的时间残差最大约 729 秒（2026 立夏）、
/// 对 2026 立春秒级公开值约 −343 秒；根因是绝对项偏差且随季节变化。
/// 因此：**不得**用它建 Gate 真值、不得据此判定数据源有误。
/// 数学基础量见 `sun_terms.dart`。
library;

import 'sun_terms.dart';

/// 求太阳视黄经**最近一次**达到 [longitude] 的时刻（可能早于 [nearUtc]）。
///
/// 与 `MonthBranchResolver` 的边界语义（`instant >= 交节` 才换）严格一致。
DateTime solveSolarTermAtOrBefore(double longitude, DateTime nearUtc) {
  var lo = julianDayOfUtc(nearUtc.toUtc());
  // 先向前退到「尚未交节」的一刻。
  var guard = 0;
  while (angleDiff(sunApparentLongitude(lo), longitude) >= 0) {
    lo -= 1;
    if (++guard > 400) {
      throw ArgumentError('在 400 天内未找到目标黄经 $longitude 的交节前时刻');
    }
  }
  var hi = lo + 1;
  for (var i = 0; i < 60; i++) {
    final mid = (lo + hi) / 2;
    if (angleDiff(sunApparentLongitude(mid), longitude) < 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return _jdToUtc((lo + hi) / 2);
}

/// 求太阳视黄经首次达到 [longitude] 的时刻。
///
/// 从 [fromUtc] 起在 [maxDays] 天内二分求根，区间须恰好跨越目标角一次。
DateTime solveSolarTermUtc(
  double longitude,
  DateTime fromUtc, {
  int maxDays = 40,
}) {
  var lo = julianDayOfUtc(fromUtc.toUtc());
  final hi0 = lo + maxDays;
  if (angleDiff(sunApparentLongitude(lo), longitude) >= 0) lo -= 1;
  final hi = hi0;
  if (angleDiff(sunApparentLongitude(hi), longitude) < 0) {
    throw ArgumentError('在给定区间内未跨越目标黄经 $longitude');
  }
  var a = lo;
  var b = hi;
  for (var i = 0; i < 60; i++) {
    final mid = (a + b) / 2;
    if (angleDiff(sunApparentLongitude(mid), longitude) < 0) {
      a = mid;
    } else {
      b = mid;
    }
  }
  return _jdToUtc((a + b) / 2);
}

/// JD → UTC。Unix 纪元 = JD 2440587.5，**不要再加 0.5**。
DateTime _jdToUtc(double jd) => DateTime.fromMillisecondsSinceEpoch(
  ((jd - 2440587.5) * 86400000).round(),
  isUtc: true,
);
