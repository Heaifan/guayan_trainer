/// GA-3 节气边界渲染：以**实测差异窗口**为单位，而非以「与数据包差几分钟」为单位。
///
/// 设计要点（GATE-A-PREP-FIX1）：
/// 1. 判据锚点必须是「两条月建曲线何时分歧」，即
///    `[min(HKO, 天算), max(HKO, 天算))` 这个**差异窗口**；
/// 2. 因此每个节气的高价值测试点恰好是窗口起点的 `-1s / ±0`，
///    以及数据包自己的边界 `-1s / ±0`；
/// 3. 天算时刻来自 `gate_a_sun_longitude.dart`（Meeus 章动+光行差），
///    是**第三方尺子**，不进产品、不改架构。
library;

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

import 'gate_a_cases.dart';
import 'gate_a_context.dart';
import 'gate_a_format.dart';
import 'gate_a_sun_longitude.dart';

/// 一个节气的三方参照：数据包 / 天算 / 差异窗口。
class TermReference {
  const TermReference({
    required this.caseDef,
    required this.term,
    required this.packHkt,
    required this.astroHkt,
  });

  final SolarTermBoundaryCase caseDef;
  final SolarTerm term;

  /// 数据包分钟值（HKT）。
  final DateTime packHkt;

  /// Meeus 天算交节时刻（HKT）。
  final DateTime astroHkt;

  /// 天算 − 数据包（秒）。正 = 天算更晚。
  int get residualSeconds => astroHkt.difference(packHkt).inSeconds;

  /// 差异窗口起点（较早的那个边界）。
  DateTime get windowStart =>
      astroHkt.isBefore(packHkt) ? astroHkt : packHkt;

  /// 差异窗口终点（较晚的那个边界）。
  DateTime get windowEnd => astroHkt.isBefore(packHkt) ? packHkt : astroHkt;

  /// 窗口时长（秒）—— 这就是「分钟精度可能造成多少秒错判」的实测值。
  int get windowSeconds => windowEnd.difference(windowStart).inSeconds;

  /// 两套边界是否落在同一分钟（同分钟则窗口 < 60s，且月建切换时刻一致）。
  bool get sameMinute =>
      packHkt.year == astroHkt.year &&
      packHkt.month == astroHkt.month &&
      packHkt.day == astroHkt.day &&
      packHkt.hour == astroHkt.hour &&
      packHkt.minute == astroHkt.minute;
}

/// 取计算某节气所需的搜索锚点（UTC），保证锚点尚未越过目标黄经。
DateTime anchorFor(SolarTermId id, int year) {
  final index = SolarTermId.values.indexOf(id);
  // 节气序自小寒起、约 15.2 天一个，故锚点取该序的起始日往前推 5 天。
  final approxMonth = 1 + (index * 15.2 / 30.4).floor();
  return DateTime.utc(year, approxMonth.clamp(1, 12), 1);
}

/// 解析某年某个「节」的三方参照；数据包缺该年时返回 null。
///
/// 天算时刻用 [solveSolarTermAtOrBefore]，即「不晚于数据包时刻的最后一次交节」，
/// 与产品边界语义一致；若两者相差极小（<2s），说明天算落在数据包之后，
/// 再取其后一次交节。
TermReference? resolveTermReference(
  GateAContext ctx,
  SolarTermId id,
  int year,
) {
  if (!ctx.installedYears.contains(year)) return null;
  final terms = ctx.engine.monthBranchResolver.provider.termsOfYear(year);
  final SolarTerm? term = terms.where((t) => t.id == id).firstOrNull;
  if (term == null) return null;

  final packHkt = hktOf(term.instantUtc);
  // 数据包的月建切换时刻 = 其记录的瞬间（HKT 挂钟）。天算取不晚于它的最后一次交节。
  final packWall = DateTime.utc(
    packHkt.year,
    packHkt.month,
    packHkt.day,
    packHkt.hour,
    packHkt.minute,
    packHkt.second,
  );
  var astro = solveSolarTermAtOrBefore(id.longitude.toDouble(), packWall);
  // 若天算恰好等于/晚于数据包（分钟舍入把边界挪到了交节之后），再往后取一次。
  if (astro.isAfter(packWall) ||
      astro.difference(packWall).inSeconds.abs() < 2) {
    astro = solveSolarTermUtc(
      id.longitude.toDouble(),
      packWall.subtract(const Duration(minutes: 5)),
      maxDays: 3,
    );
  }
  return TermReference(
    caseDef: SolarTermBoundaryCase(
      id: 'GA-ST-${id.index.toString().padLeft(2, '0')}',
      term: id,
      year: year,
      purpose: '${id.label}：${previousMonthBranch(id).label}月→'
          '${id.monthBranch!.label}月',
    ),
    term: term,
    packHkt: packHkt,
    astroHkt: hktOf(astro),
  );
}

/// 指定年份全部十二「节」的三方参照。
List<TermReference> resolveTermReferencesForYear(
  GateAContext ctx,
  int year,
) => [
  for (final id in SolarTermId.monthStartTerms)
    if (resolveTermReference(ctx, id, year) case final TermReference r) r,
];

/// 全部 GA-3 案例的三方参照（顺序与 [solarTermCases] 一致）。
List<TermReference> resolveAllTermReferences(GateAContext ctx) => [
  for (final c in solarTermCases)
    if (resolveTermReference(ctx, c.term, c.year) case final TermReference r) r,
];

String _hmss(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)} '
      '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
}

/// 渲染单个节气的差异窗口与探测矩阵。
String renderSolarTermCase(GateAContext ctx, TermReference r) {
  final b = StringBuffer();
  final id = r.caseDef.term;
  b.writeln('### ${r.caseDef.id} · ${id.label} ${r.caseDef.year}');
  b.writeln();
  b.writeln('```text');
  b.writeln('覆盖点            ${r.caseDef.purpose}');
  b.writeln('数据包交节（HKT）  ${_hmss(r.packHkt)}   '
      '（来源 HKO，分钟精度，秒位恒 :00）');
  b.writeln('天算交节（HKT）    ${_hmss(r.astroHkt)}   '
      '（Meeus 章动+光行差，第三方尺子）');
  b.writeln('残差              天算 − 数据包 = ${r.residualSeconds} 秒');
  b.writeln('差异窗口          [${_hmss(r.windowStart)}, ${_hmss(r.windowEnd)}) '
      '共 ${r.windowSeconds} 秒');
  b.writeln('窗口语义          该区间内「以数据包为准的月建」与「以天算为准的月建」不同');
  b.writeln('```');
  b.writeln();

  // 四个决定性测试点：窗口起点 ±1s、数据包边界 ±1s。
  final probes = <(String, DateTime, String)>[
    ('窗口起点 −1s', r.windowStart.subtract(const Duration(seconds: 1)),
        '天算尚未交节 → 旧月建'),
    ('窗口起点', r.windowStart, '天算已交节 → 新月建'),
    ('数据包边界 −1s', r.packHkt.subtract(const Duration(seconds: 1)),
        '数据包仍为旧月建（此即错判窗口内）'),
    ('数据包边界', r.packHkt, '两套口径均为新月建'),
  ];

  final newMonth = r.term.id.monthBranch!.label;
  final oldMonth = previousMonthBranch(r.term.id).label;

  b.writeln('| 测试点 | 时间（+08:00） | 卦眼月建（数据包口径） | '
      '天算应有月建 | 专业软件月建 | 一致 | 说明 |');
  b.writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final (label, at, note) in probes) {
    final local = DateTime(
      at.year,
      at.month,
      at.day,
      at.hour,
      at.minute,
      at.second,
    );
    final engineMonth = resolveCalendar(ctx, local).monthBranchLabel;
    final astroMonth = at.isBefore(r.astroHkt) ? oldMonth : newMonth;
    b.writeln(
      '| $label | ${wallClockWithOffsetText(local)} | $engineMonth '
      '| $astroMonth | | | $note |',
    );
  }
  b.writeln();
  b.writeln(
    '> 判读：若专业软件在「窗口起点」一行已给出**$newMonth 月建**，'
    '说明它与天算一致、而卦眼（数据包口径）落后 ${r.windowSeconds} 秒 '
    '→ 归类 **F8 节气数据精度差异**，修复对象是**数据源**，'
    '不是 `MonthBranchResolver`。',
  );
  b.writeln();
  return b.toString();
}

/// 该「节」所切换出去的**上一个**月建（十二节与月建的固定对应）。
DiZhi previousMonthBranch(SolarTermId id) => switch (id) {
  SolarTermId.xiaoHan => DiZhi.zi,
  SolarTermId.liChun => DiZhi.chou,
  SolarTermId.jingZhe => DiZhi.yin,
  SolarTermId.qingMing => DiZhi.mao,
  SolarTermId.liXia => DiZhi.chen,
  SolarTermId.mangZhong => DiZhi.si,
  SolarTermId.xiaoShu => DiZhi.wu,
  SolarTermId.liQiu => DiZhi.wei,
  SolarTermId.baiLu => DiZhi.shen,
  SolarTermId.hanLu => DiZhi.you,
  SolarTermId.liDong => DiZhi.xu,
  SolarTermId.daXue => DiZhi.hai,
  _ => throw ArgumentError.value(id, 'id', '不是十二「节」之一'),
};
