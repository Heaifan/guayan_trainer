/// 诊断：把太阳视黄经的**中间量**全部打印出来，与手册手算逐项对账。
///
/// 目的：定位自建尺子 5～12 分钟偏差的根因，而不是「调常数贴答案」。
library;

import 'dart:io';
import 'dart:math' as math;

import 'gate_a_sun_longitude.dart';

const double _deg = math.pi / 180.0;

/// 逐项打印中间量。
void report(String label, DateTime utc, double targetLongitude) {
  final jd = julianDayOfUtc(utc);
  final t = (jd - 2451545.0) / 36525.0;

  final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
  final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
  final e = 0.016708634 - 0.000042037 * t;
  final om = 125.04452 - 1934.136261 * t;

  final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(m * _deg) +
      (0.019993 - 0.000101 * t) * math.sin(2 * m * _deg) +
      0.000289 * math.sin(3 * m * _deg);
  final nutArcsec = nutationInLongitudeArcsec(t);
  final aber = -(20.4898 / 3600.0) * (1 + e * math.cos(m * _deg));

  final geo = l0 + c;
  final app = sunApparentLongitude(jd);
  var delta = (app - targetLongitude) % 360;
  if (delta > 180) delta -= 360;
  if (delta <= -180) delta += 360;

  stdout.writeln('--- $label');
  stdout.writeln('    UTC   = ${utc.toIso8601String()}');
  stdout.writeln('    JD    = ${jd.toStringAsFixed(6)}    T = ${t.toStringAsFixed(8)}');
  stdout.writeln('    L0    = ${l0.toStringAsFixed(6)}°');
  stdout.writeln('    M     = ${(m % 360).toStringAsFixed(6)}°');
  stdout.writeln('    e     = ${e.toStringAsFixed(8)}');
  stdout.writeln('    Omega = ${om.toStringAsFixed(6)}°');
  stdout.writeln(
    '    C     = ${c.toStringAsFixed(6)}°  (${(c * 3600).toStringAsFixed(1)} 角秒)',
  );
  stdout.writeln(
    '    章动  = ${nutArcsec.toStringAsFixed(3)} 角秒 = '
    '${(nutArcsec / 3600).toStringAsFixed(6)}°',
  );
  stdout.writeln(
    '    光行差 = ${aber.toStringAsFixed(6)}°  (${(aber * 3600).toStringAsFixed(2)} 角秒)',
  );
  stdout.writeln('    几何黄经 = ${geo.toStringAsFixed(6)}°');
  stdout.writeln('    视黄经   = ${app.toStringAsFixed(6)}°');
  stdout.writeln(
    '    目标 ${targetLongitude.toStringAsFixed(0)}° 偏差 = '
    '${delta.toStringAsFixed(6)}° = ${(delta * 3600).toStringAsFixed(1)} 角秒 '
    '≈ ${(delta * 24 * 3600 / 0.9856).toStringAsFixed(1)} 秒时间',
  );
}

void main() {
  // 官方秒级哨兵：紫金山天文台公开 2026 立春 04:02:08 (+08:00)。
  report('立春 官方哨兵 04:02:08 HKT', DateTime.utc(2026, 2, 3, 20, 2, 8), 315);
  // HKO 分钟值 04:02:00 (+08:00)。
  report('立春 HKO 分钟值 04:02:00 HKT', DateTime.utc(2026, 2, 3, 20, 2), 315);
  // 自建工具输出版 03:56:24 (+08:00)。
  report('立春 自建输出 03:56:24 HKT', DateTime.utc(2026, 2, 3, 19, 56, 24), 315);
  stdout.writeln('');
  stdout.writeln('== 反查：让视黄经等于目标角的时刻 ==');
  for (final entry in <String, (double, DateTime)>{
    '立春 315°': (315, DateTime.utc(2026, 1, 1)),
    '立夏 45°': (45, DateTime.utc(2026, 4, 20)),
    '冬至 270°': (270, DateTime.utc(2026, 12, 1)),
  }.entries) {
    final solved = solveSolarTermUtc(entry.value.$1, entry.value.$2, maxDays: 40);
    stdout.writeln(
      '  ${entry.key} → ${solved.add(const Duration(hours: 8)).toIso8601String()}'
      ' (HKT)',
    );
  }
}
