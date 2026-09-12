/// 天文尺子（Meeus 太阳视黄经）与官方双源自检（自 `tools/selftest.dart` 拆出）。
///
/// 三块：
/// 1. 尺子的纪元往返与 coarse sanity（**不构成精度证明**）；
/// 2. HKO vs NAOJ 官方双源交叉；
/// 3. 数据包是否忠实转写官方分钟值。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import '../../astro/cross_source_rows.dart';
import '../../astro/sun_longitude.dart';
import '../../astro/sun_terms.dart';
import '../../core/formatting/format.dart';
import '../../data/hko_source.dart';
import '../../data/naoj_source.dart';
import '../../gate_a_context.dart';
import 'suite.dart';

Future<void> checkAstro() async {
  stdout.writeln('== 天文尺子（Meeus 太阳视黄经）自检 ==');
  // JD ↔ Unix 时标：曾经因为多加 0.5 天导致全部结果偏移 12 小时，
  // 因此把「纪元往返」固定为哨兵测试。
  check(
    'JD(2000-01-01T12:00Z) = 2451545.0',
    julianDayOfUtc(DateTime.utc(2000, 1, 1, 12)),
    2451545.0,
  );
  check(
    'JD(1970-01-01T00:00Z) = 2440587.5',
    julianDayOfUtc(DateTime.utc(1970, 1, 1)),
    2440587.5,
  );
  // 只作 coarse sanity check：0.01° ≈ 14.6 分钟时间，
  // **不能**作为分钟级/秒级精度证明（GATE-A-PREP-FIX2 §6）。
  const probes = <(SolarTermId, int, int, int, int)>[
    (SolarTermId.liChun, 2, 4, 4, 2),
    (SolarTermId.baiLu, 9, 7, 22, 41),
  ];
  for (final (id, month, day, hour, minute) in probes) {
    final utc = DateTime.utc(2026, month, day, hour - 8, minute);
    final lon = sunApparentLongitude(julianDayOfUtc(utc));
    final delta = angleDiff(lon, id.longitude.toDouble());
    check(
      'coarse sanity：HKO ${id.label} 时刻黄经偏差 < 0.01°',
      delta.abs() < 0.01,
      true,
    );
  }
  // 尺子对官方的**时间残差**必须如实记录（不得掩盖）。
  final liChunPredicted = solveSolarTermUtc(
    315,
    DateTime.utc(2026, 2, 1),
    maxDays: 20,
  );
  final residual = liChunPredicted
      .difference(DateTime.utc(2026, 2, 3, 20, 2, 8))
      .inSeconds;
  check('尺子对秒级公开值残差绝对值 > 60s（已知缺陷，不得当作已验证）', residual.abs() > 60, true);

  stdout.writeln('');
  stdout.writeln('== 官方双源交叉：HKO vs NAOJ（2026 二十四节气）==');
  stdout.writeln('（用的是官方原始发布件夹具，不是本仓库数据包）');
  final naoj = loadNaojFixture();
  check('NAOJ 夹具解析条数', naoj.length, 24);
  final hko = loadHkoFixture();
  check('HKO 夹具解析条数', hko.length, 24);
  final crossRows = buildCrossSourceRows();
  check('HKO vs NAOJ 日期一致', crossRows.where((r) => r.sameDate).length, 24);
  check('HKO vs NAOJ 分钟一致', crossRows.where((r) => r.sameMinute).length, 24);

  stdout.writeln('');
  stdout.writeln('== 数据包忠实转写官方分钟值（除已核实秒级项）==');
  final packCtx = await loadGateAContext();
  final packTerms = packCtx.engine.monthBranchResolver.provider.termsOfYear(
    2026,
  );
  var faithful = 0;
  for (var i = 0; i < 24; i++) {
    final t = packTerms.firstWhere((x) => x.id == SolarTermId.values[i]);
    final packMinute = hktOf(t.instantUtc);
    final official = hko[i];
    if (packMinute.hour == official.hour &&
        packMinute.minute == official.minute &&
        packMinute.day == official.day) {
      faithful++;
    }
  }
  check('数据包 24 条仍落在官方同一分钟（秒级细化不改变分钟）', faithful, 24);
}
