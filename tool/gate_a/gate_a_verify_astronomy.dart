/// 一次性核准：Meeus 太阳视黄经算出的 24 节气 vs HKO 数据包（分钟值）。
///
/// 若每个节气的 `|HKO - 天算| <= 30 秒`，说明「HKO = 四舍五入到分钟」成立，
/// 天算尺子可用于定位差异窗口；若某条超出，则该条需单独存疑。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import 'gate_a_context.dart';
import 'gate_a_format.dart';
import 'gate_a_sun_longitude.dart';

/// 每个节气在公历年内的大致起始月日（用于选定搜索起点）。
const Map<SolarTermId, (int, int)> searchAnchor = <SolarTermId, (int, int)>{
  SolarTermId.xiaoHan: (1, 1),
  SolarTermId.daHan: (1, 16),
  SolarTermId.liChun: (2, 1),
  SolarTermId.yuShui: (2, 14),
  SolarTermId.jingZhe: (3, 1),
  SolarTermId.chunFen: (3, 15),
  SolarTermId.qingMing: (3, 30),
  SolarTermId.guYu: (4, 15),
  SolarTermId.liXia: (4, 30),
  SolarTermId.xiaoMan: (5, 16),
  SolarTermId.mangZhong: (5, 30),
  SolarTermId.xiaZhi: (6, 15),
  SolarTermId.xiaoShu: (6, 30),
  SolarTermId.daShu: (7, 16),
  SolarTermId.liQiu: (8, 1),
  SolarTermId.chuShu: (8, 15),
  SolarTermId.baiLu: (8, 31),
  SolarTermId.qiuFen: (9, 15),
  SolarTermId.hanLu: (9, 30),
  SolarTermId.shuangJiang: (10, 16),
  SolarTermId.liDong: (11, 1),
  SolarTermId.xiaoXue: (11, 16),
  SolarTermId.daXue: (12, 1),
  SolarTermId.dongZhi: (12, 15),
};

Future<void> main(List<String> args) async {
  final ctx = await loadGateAContext();
  final years = args.isEmpty ? <int>[2026] : args.map(int.parse).toList();

  for (final year in years) {
    stdout.writeln('=== $year 年：HKO 数据包（分钟） vs 天算（Meeus 章动+光行差）===');
    var maxAbs = 0.0;
    SolarTermId? worst;
    for (final id in SolarTermId.values) {
      final term = ctx.engine.monthBranchResolver.provider
          .termsOfYear(year)
          .firstWhere((t) => t.id == id);
      final hkoHkt = hktOf(term.instantUtc);
      final anchor = searchAnchor[id]!;
      final from = DateTime.utc(year, anchor.$1, anchor.$2);
      final computedHkt = hktOf(
        solveSolarTermUtc(id.longitude.toDouble(), from),
      );

      final diff = computedHkt.difference(hkoHkt).inMilliseconds / 1000.0;
      if (diff.abs() > maxAbs) {
        maxAbs = diff.abs();
        worst = id;
      }
      // 同一分钟 → 数据包与天算一致（分钟舍入内）。
      final sameMinute =
          diff.abs() < 60 &&
          computedHkt.hour == hkoHkt.hour &&
          computedHkt.minute == hkoHkt.minute;
      stdout.writeln(
        '${id.label.padRight(3)} HKO ${_hmss(hkoHkt)}  '
        '天算 ${_hmss(computedHkt)}  差 ${diff.toStringAsFixed(1)}s  '
        '${sameMinute ? '同一分钟' : '⚠️ 不同分钟'}',
      );
    }
    stdout.writeln('最大绝对偏差 ${maxAbs.toStringAsFixed(1)} 秒（${worst?.label}）');
  }
}

String _hmss(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}:'
      '${two(t.second)}${t.millisecond > 0 ? '.${t.millisecond.toString().padLeft(3, '0')}' : ''}';
}
