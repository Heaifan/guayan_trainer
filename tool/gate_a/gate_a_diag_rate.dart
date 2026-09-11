/// 尺子根因定位：比较「太阳视黄经的日变率」与官方交节间隔。
///
/// 若日变率正确，则用官方相邻交节时刻反推的瞬时变率也应与之一致；
/// 若二者差出一个量级，说明黄经公式本身有系数错误。
library;

import 'dart:io';
import 'dart:math' as math;

import 'gate_a_sun_longitude.dart';

/// 数值微分：某时刻视黄经的日变率（度/日）。
double ratePerDay(double jd) {
  const h = 0.01; // 0.01 日 ≈ 14.4 分钟
  var a = sunApparentLongitude(jd - h);
  var b = sunApparentLongitude(jd + h);
  var d = (b - a) % 360;
  if (d > 180) d -= 360;
  if (d <= -180) d += 360;
  return d / (2 * h);
}

void main() {
  stdout.writeln('== 视黄经日变率（数值微分） ==');
  for (final label in <String, DateTime>{
    '小寒 2026-01-05T08:23Z': DateTime.utc(2026, 1, 5, 8, 23),
    '立春 2026-02-03T20:02Z': DateTime.utc(2026, 2, 3, 20, 2),
    '立夏 2026-05-05T11:49Z': DateTime.utc(2026, 5, 5, 11, 49),
    '冬至 2026-12-21T20:50Z': DateTime.utc(2026, 12, 21, 20, 50),
  }.entries) {
    final jd = julianDayOfUtc(label.value);
    final r = ratePerDay(jd);
    stdout.writeln(
      '  ${label.key}  日变率 = ${r.toStringAsFixed(6)} °/日  '
      '（理论 0.9856 的偏差 ${((r - 0.9856) * 3600).toStringAsFixed(0)} 角秒/日）',
    );
  }

  stdout.writeln('');
  stdout.writeln('== 由官方相邻交节时刻反推的平均日变率 ==');
  // 十五度一个节气，用官方分钟值算平均日变率。
  final pairs = <(String, DateTime, DateTime)>[
    ('小寒→大寒', DateTime.utc(2026, 1, 5, 8, 23), DateTime.utc(2026, 1, 20, 1, 45)),
    ('立春→雨水', DateTime.utc(2026, 2, 3, 20, 2),
        DateTime.utc(2026, 2, 18, 15, 52)),
    ('立夏→小满', DateTime.utc(2026, 5, 5, 11, 49), DateTime.utc(2026, 5, 21, 0, 37)),
  ];
  for (final (a, ta, tb) in pairs) {
    final days = tb.difference(ta).inMinutes / 1440.0;
    var delta = (sunApparentLongitude(julianDayOfUtc(tb)) -
            sunApparentLongitude(julianDayOfUtc(ta))) %
        360;
    if (delta > 180) delta -= 360;
    if (delta <= -180) delta += 360;
    stdout.writeln(
      '  $a  间隔 ${days.toStringAsFixed(4)} 日  '
      '官方黄经增量 ${delta.toStringAsFixed(4)}°  '
      '→ 平均 ${(delta / days).toStringAsFixed(6)} °/日',
    );
  }

  stdout.writeln('');
  stdout.writeln('== 直接算：官方时刻的视黄经 ==');
  for (final e in <String, (DateTime, double)>{
    '小寒 官方 16:23 HKT': (DateTime.utc(2026, 1, 5, 8, 23), 285),
    '立春 官方 04:02:08 HKT': (DateTime.utc(2026, 2, 3, 20, 2, 8), 315),
    '立夏 官方 19:49 HKT': (DateTime.utc(2026, 5, 5, 11, 49), 45),
  }.entries) {
    final lon = sunApparentLongitude(julianDayOfUtc(e.value.$1));
    var d = (lon - e.value.$2) % 360;
    if (d > 180) d -= 360;
    if (d <= -180) d += 360;
    stdout.writeln(
      '  ${e.key}  视黄经 ${lon.toStringAsFixed(6)}°  偏差 '
      '${(d * 3600).toStringAsFixed(1)} 角秒 = ${(d / 0.9856 * 86400).toStringAsFixed(0)} 秒时间'
      '   [0.9856°/日 换算]',
    );
  }

  stdout.writeln('');
  stdout.writeln('（参考：sin(2M) 等项若系数误为单位，误差量级见下）');
  for (final mult in <double>[1, 60, 3600]) {
    stdout.writeln('  1.9146° 的 1/$mult = ${(1.9146 / mult).toStringAsFixed(6)}°');
  }
  stdout.writeln('  math.pi 误值检查：${math.pi}');
  stdout.writeln('  60 秒/分 与 度/角秒换算：1° = 3600 角秒');
}
