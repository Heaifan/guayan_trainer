/// 自建天文尺子的 diagnostic 诊断（变率校验 + 中间量对账）。
///
/// **状态：REJECTED AS GATE ORACLE** —— 这些脚本只用于研究尺子为何不准，
/// 不产生任何 Gate 真值。合并自原 diag_rate / diag_sun_longitude 两份文件。
library;

import 'dart:io';
import 'dart:math' as math;

import 'sun_terms.dart';

// ---------------------------------------------------------------------------
// 一、视黄经日变率 vs 官方交节间隔
// ---------------------------------------------------------------------------

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

void reportRates() {
  stdout.writeln('== 视黄经日变率（数值微分） ==');
  for (final e in <String, DateTime>{
    '小寒 2026-01-05T08:23Z': DateTime.utc(2026, 1, 5, 8, 23),
    '立春 2026-02-03T20:02Z': DateTime.utc(2026, 2, 3, 20, 2),
    '立夏 2026-05-05T11:49Z': DateTime.utc(2026, 5, 5, 11, 49),
    '冬至 2026-12-21T20:50Z': DateTime.utc(2026, 12, 21, 20, 50),
  }.entries) {
    final r = ratePerDay(julianDayOfUtc(e.value));
    stdout.writeln('  ${e.key}  ${r.toStringAsFixed(6)} °/日');
  }
  stdout.writeln('');
  stdout.writeln('== 直接算：官方时刻的视黄经 ==');
  for (final e in <String, (DateTime, double)>{
    '小寒 官方 16:23 HKT': (DateTime.utc(2026, 1, 5, 8, 23), 285),
    '立春 官方 04:02:08 HKT': (DateTime.utc(2026, 2, 3, 20, 2, 8), 315),
    '立夏 官方 19:49 HKT': (DateTime.utc(2026, 5, 5, 11, 49), 45),
  }.entries) {
    final delta = angleDiff(
      sunApparentLongitude(julianDayOfUtc(e.value.$1)),
      e.value.$2,
    );
    stdout.writeln(
      '  ${e.key}  偏差 ${(delta * 3600).toStringAsFixed(1)} 角秒'
      ' = ${(delta / 0.9856 * 86400).toStringAsFixed(0)} 秒时间',
    );
  }
  stdout.writeln('');
  stdout.writeln('math.pi = ${math.pi}（用于排除常量误值）');
}

// ---------------------------------------------------------------------------
// 二、指定时刻的中间量对账
// ---------------------------------------------------------------------------

/// 逐项打印中间量，便于与天文手册手算对账。
void reportIntermediate(String label, DateTime utc, double target) {
  final jd = julianDayOfUtc(utc);
  final t = julianCenturies(jd);
  final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
  final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
  final app = sunApparentLongitude(jd);
  final delta = angleDiff(app, target);
  stdout.writeln('--- $label  ${utc.toIso8601String()}');
  stdout.writeln('    JD=${jd.toStringAsFixed(6)}  T=${t.toStringAsFixed(8)}');
  stdout.writeln(
    '    L0=${l0.toStringAsFixed(6)}  M=${(m % 360).toStringAsFixed(6)}',
  );
  stdout.writeln(
    '    视黄经=${app.toStringAsFixed(6)}  目标=$target  '
    '偏差=${(delta * 3600).toStringAsFixed(1)} 角秒',
  );
}

void main() {
  reportRates();
  stdout.writeln('');
  reportIntermediate(
    '立春 官方哨兵 04:02:08 HKT',
    DateTime.utc(2026, 2, 3, 20, 2, 8),
    315,
  );
  reportIntermediate(
    '立春 数据包 04:02:08 HKT',
    DateTime.utc(2026, 2, 3, 20, 2, 8),
    315,
  );
}
