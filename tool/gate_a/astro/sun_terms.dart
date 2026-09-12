/// 太阳位置基础量：儒略日换算、有符号角差、视黄经（章动 + 光行差）。
///
/// 自 `sun_longitude.dart` 拆出，使数学公式与求根逻辑各自成文件。
/// **仅供 diagnostic 使用**，不进入产品、不作 Gate oracle。
library;

import 'dart:math' as math;

const double _deg2rad = math.pi / 180.0;

/// 儒略日序（含小数），入参为 UTC 时刻。
///
/// Unix 纪元 = JD 2440587.5，**不要再加 0.5**（多加会让结果整体偏移 12 小时）。
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

/// 有符号角差 `a - b`，规约到 (-180, 180]，用于跨 0° 求根。
double angleDiff(double a, double b) {
  var d = (a - b) % 360;
  if (d <= -180) d += 360;
  if (d > 180) d -= 360;
  return d;
}

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

/// 章动黄经 Δψ（角秒，Meeus 第 22 章取显著项，残差 < 1″ ≈ 2.5 秒时间）。
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
