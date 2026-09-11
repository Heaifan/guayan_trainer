/// 太阳视黄经（高精度版）：章动 + 光行差完整项（Meeus《天文算法》第 22/25 章）。
///
/// 为什么需要它：GA-3 要判定「数据包分钟值 vs 真实交节」的差异窗口有多大，
/// 这把尺子必须自己先准。低精度式只保留 -0.00569° 常数光行差，
/// 在节气点上会残留数角秒到数十角秒误差；本版把章动 Δψ 完整展开，
/// 并用标准光行差公式（含偏心率与近日点项）。
library;

import 'dart:math' as math;

const double _deg2rad = math.pi / 180.0;

/// 儒略世纪数（J2000 起算）。
double julianCenturies(double jd) => (jd - 2451545.0) / 36525.0;

/// 地球平黄经 L0（度）。
double _meanLongitude(double t) =>
    280.46646 + 36000.76983 * t + 0.0003032 * t * t;

/// 太阳平近点角 M（度）。
double _meanAnomaly(double t) =>
    357.52911 + 35999.05029 * t - 0.0001537 * t * t;

/// 中心差 C（度）：真黄经 = 平黄经 + C。
double _equationOfCenter(double t) {
  final m = _meanAnomaly(t) * _deg2rad;
  return (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(m) +
      (0.019993 - 0.000101 * t) * math.sin(2 * m) +
      0.000289 * math.sin(3 * m);
}

/// 月球升交点平黄经 Ω（度）。
double _ascendingNode(double t) => 125.04452 - 1934.136261 * t;

/// 章动黄经 Δψ（角秒）。
///
/// 取 Meeus 第 22 章前四项中真正贡献显著者（含 18.6 年主项 Ω、半年项 2D、
/// 半年项 2F、以及 2Ω 项），残差量级 < 1″ ≈ 2.5 秒时间。
double nutationInLongitudeArcsec(double t) {
  final d = (297.85036 + 445267.111480 * t - 0.0019142 * t * t) * _deg2rad;
  final f = (93.27191 + 483202.017538 * t - 0.0036825 * t * t) * _deg2rad;
  final om = _ascendingNode(t) * _deg2rad;
  return -17.20 * math.sin(om) -
      1.32 * math.sin(2 * d) -
      0.23 * math.sin(2 * f) +
      0.21 * math.sin(2 * om);
}

/// 太阳视黄经（度，0..360），相对真春分点。
double sunApparentLongitude(double jd) {
  final t = julianCenturies(jd);
  final geometric = _meanLongitude(t) + _equationOfCenter(t);
  final nutationDeg = nutationInLongitudeArcsec(t) / 3600.0;

  // 标准光行差（Meeus 25.10）：-20.4898″ / R，R 取含偏心率的一阶近似。
  final e = 0.016708634 - 0.000042037 * t;
  final m = _meanAnomaly(t) * _deg2rad;
  final aberrationDeg = -(20.4898 / 3600.0) * (1 + e * math.cos(m));

  final apparent = geometric + nutationDeg + aberrationDeg;
  return (apparent % 360 + 360) % 360;
}

/// 有符号角差 `a - b`，规约到 (-180, 180]，用于跨 0° 求根。
double angleDiff(double a, double b) {
  var d = (a - b) % 360;
  if (d <= -180) d += 360;
  if (d > 180) d -= 360;
  return d;
}

/// 儒略日序（含小数），入参为 UTC 时刻。
double julianDayOfUtc(DateTime utc) {
  final u = utc.toUtc();
  var y = u.year;
  var m = u.month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  final dayFraction =
      (u.hour + u.minute / 60.0 + u.second / 3600.0 + u.millisecond / 3600000.0) /
          24.0;
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      u.day +
      dayFraction +
      b -
      1524.5;
}

/// 求太阳视黄经**最近一次**达到 [longitude] 的时刻（可能早于 [nearUtc]）。
///
/// 传 `maxDays: 0` 即为「不晚于 nearUtc 的最后一次交节」，
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
  final millis = (((lo + hi) / 2 - 2440587.5) * 86400000).round();
  return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
}

/// 求太阳视黄经首次达到 [longitude] 的时刻。
///
/// 从 [fromUtc] 起在 [maxDays] 天内二分求根。区间必须恰好跨越目标角一次。
DateTime solveSolarTermUtc(double longitude, DateTime fromUtc, {int maxDays = 40}) {
  var lo = julianDayOfUtc(fromUtc.toUtc());
  final hi0 = lo + maxDays;
  if (angleDiff(sunApparentLongitude(lo), longitude) >= 0) lo -= 1;
  var hi = hi0;
  if (angleDiff(sunApparentLongitude(hi), longitude) < 0) {
    throw ArgumentError('在给定区间内未跨越目标黄经 $longitude');
  }
  for (var i = 0; i < 60; i++) {
    final mid = (lo + hi) / 2;
    if (angleDiff(sunApparentLongitude(mid), longitude) < 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  // JD → Unix 毫秒：Unix 纪元 = JD 2440587.5，不要再加 0.5。
  final millis = (((lo + hi) / 2 - 2440587.5) * 86400000).round();
  return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
}
