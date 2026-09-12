/// 自建天文尺子的**时间残差**评估：预测交节时刻 vs 官方发布时刻。
///
/// 这是 GATE-A-PREP-FIX2 §7 要求的报告口径：**报告时间残差，而不是角度残差**。
///
/// 官方真值只用于「测量残差」，**不**用于反推常数（禁止调常数贴答案）。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import '../gate_a_context.dart';
import '../core/format.dart';
import '../data/naoj_source.dart';
import '../astro/sun_longitude.dart';

/// 「节」的搜索锚点（UTC），保证起点尚未越过目标黄经。
const Map<SolarTermId, (int, int)> _anchor = <SolarTermId, (int, int)>{
  SolarTermId.xiaoHan: (1, 1),
  SolarTermId.liChun: (2, 1),
  SolarTermId.jingZhe: (3, 1),
  SolarTermId.qingMing: (3, 30),
  SolarTermId.liXia: (4, 30),
  SolarTermId.mangZhong: (5, 30),
  SolarTermId.xiaoShu: (6, 30),
  SolarTermId.liQiu: (8, 1),
  SolarTermId.baiLu: (8, 31),
  SolarTermId.hanLu: (9, 30),
  SolarTermId.liDong: (11, 1),
  SolarTermId.daXue: (12, 1),
};

String _two(int v) => v.toString().padLeft(2, '0');

String _hktText(DateTime utc) {
  final t = utc.add(const Duration(hours: 8));
  return '${t.year}-${_two(t.month)}-${_two(t.day)} '
      '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
}

Future<void> main(List<String> args) async {
  final ctx = await loadGateAContext();
  const year = 2026;
  final terms = ctx.engine.monthBranchResolver.provider.termsOfYear(year);

  stdout.writeln('=== 自建尺子时间残差：预测 vs 官方（$year，HKT）===');
  stdout.writeln('残差 = 天算 − 官方；正 = 天算偏晚。');
  stdout.writeln('');
  stdout.writeln('| 节气 | 官方发布(HKT, 分钟) | 天算预测(HKT, 秒) | 时间残差 |');
  stdout.writeln('| --- | --- | --- | --- |');

  var maxAbs = 0;
  var worst = '';
  for (final id in SolarTermId.monthStartTerms) {
    final official = terms.firstWhere((t) => t.id == id).instantUtc;
    final anchor = _anchor[id]!;
    final predicted = solveSolarTermUtc(
      id.longitude.toDouble(),
      DateTime.utc(year, anchor.$1, anchor.$2),
      maxDays: 35,
    );
    final residual = predicted.difference(official).inSeconds;
    if (residual.abs() > maxAbs) {
      maxAbs = residual.abs();
      worst = id.label;
    }
    stdout.writeln(
      '| ${id.label} | ${_hktText(official).substring(0, 16)} '
      '| ${_hktText(predicted)} | ${residual >= 0 ? '+' : ''}${residual}s |',
    );
  }
  stdout.writeln('');
  stdout.writeln('最大绝对时间残差：$maxAbs 秒（$worst）');
  stdout.writeln(
    '对应角度残差量级：${(maxAbs * 0.9856 / 86400).toStringAsFixed(5)}° '
    '（对比旧自检阈值 0.01° ≈ 14.6 分钟）',
  );
  stdout.writeln('');

  // 独立秒级哨兵：紫金山天文台公开值（2026 立春 04:02:08 +08:00）。
  const sentinelHkt = '2026-02-04 04:02:08';
  final predictedLiChun = solveSolarTermUtc(
    315,
    DateTime.utc(2026, 2, 1),
    maxDays: 20,
  );
  stdout.writeln('=== 秒级哨兵 ===');
  stdout.writeln('来源：中国科学院紫金山天文台科普部公开值');
  stdout.writeln('公布值：$sentinelHkt (+08:00)');
  stdout.writeln('天算预测：${_hktText(predictedLiChun)} (+08:00)');
  stdout.writeln(
    '时间残差：'
    '${predictedLiChun.difference(DateTime.utc(2026, 2, 3, 20, 2, 8)).inSeconds}s',
  );
  stdout.writeln('');

  // NAOJ 双源交叉（用于确认官方分钟值本身可靠）。
  final naoj = loadNaojFixture();
  var agree = 0;
  for (final id in SolarTermId.values) {
    final official = hktOf(
      terms.firstWhere((t) => t.id == id).instantUtc,
    );
    final n = naoj.firstWhere((t) => t.longitude == id.longitude).hktJstShifted;
    if (official.hour == n.hour &&
        official.minute == n.minute &&
        official.day == n.day) {
      agree++;
    }
  }
  stdout.writeln('=== 官方双源交叉（HKO vs NAOJ）===');
  stdout.writeln('分钟级一致：$agree / 24');
}
