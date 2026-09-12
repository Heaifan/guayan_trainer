/// GA-3 节气边界渲染（**官方真值版**）。
///
/// 设计原则（GATE-A-PREP-FIX2）：
/// 1. 测试点只以**官方发布值**（HKO / NAOJ）为准；
/// 2. 自建天文尺子一律标 `UNVERIFIED TOOL OUTPUT`，**不**参与建窗、不做真值；
/// 3. 有可追溯秒级公开值的节气，才追加 `exact −1s / exact / exact +1s`；
/// 4. 精度结论记在 `Gate A-Truth` 下，且只能是
///    `PARTIALLY SECOND-LEVEL VERIFIED`（立春秒级已核实，其余仅分钟级）。
library;

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

import 'gate_a_context.dart';
import 'gate_a_format.dart';

/// 可追溯的秒级公开值（来源必须写明；来源不明者**不得**收录）。
class SecondLevelReference {
  const SecondLevelReference({
    required this.term,
    required this.year,
    required this.hkt,
    required this.source,
    required this.note,
  });

  final SolarTermId term;
  final int year;

  /// 公布时刻（+08:00 挂钟）。
  final DateTime hkt;
  final String source;
  final String note;
}

/// 秒级哨兵表。
///
/// 只收录**能指明发布机构**的值。`04:01:51` 因无法确认来源，已被排除。
final List<SecondLevelReference> secondLevelReferences = <SecondLevelReference>[
  SecondLevelReference(
    term: SolarTermId.liChun,
    year: 2026,
    // 2026-02-04 04:02:08 (+08:00)
    hkt: DateTime.utc(2026, 2, 4, 4, 2, 8),
    source: '中国科学院紫金山天文台科普部公开值',
    note: '与 HKO 分钟值 04:02、NAOJ 换算值 04:02 同分钟一致',
  ),
];

/// 某年某节的官方参照（数据包 = HKO）。
class OfficialTermReference {
  const OfficialTermReference({
    required this.term,
    required this.year,
    required this.packHkt,
    required this.isSecondPrecise,
    this.secondLevel,
  });

  final SolarTermId term;
  final int year;

  /// 数据包（HKO，分钟精度）交节时刻（HKT）。
  final DateTime packHkt;

  /// 该瞬间在数据包中的记录精度是否为秒级。
  final bool isSecondPrecise;

  /// 可追溯秒级公开值（若存在）。
  final SecondLevelReference? secondLevel;

  /// 该节切换出去的旧月建。
  DiZhi get oldMonth => previousMonthBranch(term);

  /// 该节开入的新月建。
  DiZhi get newMonth => term.monthBranch!;
}

/// 解析某年某节的官方参照；数据包缺该年返回 null。
OfficialTermReference? resolveOfficialReference(
  GateAContext ctx,
  SolarTermId id,
  int year,
) {
  if (!ctx.installedYears.contains(year)) return null;
  final SolarTerm? t = ctx.engine.monthBranchResolver.provider
      .termsOfYear(year)
      .where((x) => x.id == id)
      .firstOrNull;
  if (t == null) return null;
  return OfficialTermReference(
    term: id,
    year: year,
    packHkt: hktOf(t.instantUtc),
    isSecondPrecise: t.isSecondPrecise,
    secondLevel: secondLevelReferences
        .where((r) => r.term == id && r.year == year)
        .firstOrNull,
  );
}

/// 全部十二「节」的官方参照。
List<OfficialTermReference> resolveOfficialReferences(
  GateAContext ctx,
  int year,
) => [
  for (final id in SolarTermId.monthStartTerms)
    if (resolveOfficialReference(ctx, id, year) case final OfficialTermReference r)
      r,
];

String _full(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)} '
      '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
}

(String, DateTime, String) _probe(String a, DateTime b, String c) => (a, b, c);

/// 渲染单个「节」的官方测试点矩阵。
String renderOfficialTermCase(GateAContext ctx, OfficialTermReference r) {
  final b = StringBuffer();
  b.writeln('### ${r.term.label} ${r.year} · '
      '${r.oldMonth.label}月 → ${r.newMonth.label}月');
  b.writeln();
  b.writeln('```text');
  b.writeln('数据包边界（HKT）     ${_full(r.packHkt)}');
  b.writeln('记录精度              ${r.isSecondPrecise ? 'second' : 'minute'}');
  if (r.secondLevel != null) {
    b.writeln('秒级公开值（HKT）     ${_full(r.secondLevel!.hkt)}');
    b.writeln('秒级来源              ${r.secondLevel!.source}');
    b.writeln('备注                  ${r.secondLevel!.note}');
  } else {
    b.writeln('秒级公开值            无（未收录可追溯来源）');
  }
  b.writeln('```');
  b.writeln();
  if (!r.isSecondPrecise) {
    b.writeln(
      '> ⚠️ 本节气为**分钟级**：`instantUtc` 秒位为 `:00` 只表示'
      '「该分钟内交节」，**不**表示「恰在第 0 秒交节」。'
      '在取得可信秒级真值前，不追加秒级测试点。',
    );
    b.writeln();
  }

  final boundary = r.packHkt.subtract(const Duration(minutes: 1));
  final probes = <(String, DateTime, String)>[
    _probe('边界 −1min', boundary, '官方边界前 1 分钟 → 应给${r.oldMonth.label}月'),
    _probe('边界', r.packHkt, '官方边界 → 应给${r.newMonth.label}月'),
    _probe(
      '边界 +1min',
      r.packHkt.add(const Duration(minutes: 1)),
      '官方边界后 1 分钟 → 应给${r.newMonth.label}月',
    ),
  ];
  if (r.secondLevel != null) {
    final exact = r.secondLevel!.hkt;
    probes.addAll(<(String, DateTime, String)>[
      _probe(
        '秒级 exact −1s',
        exact.subtract(const Duration(seconds: 1)),
        '秒级真值前 1 秒 → 应给${r.oldMonth.label}月',
      ),
      _probe('秒级 exact', exact, '秒级真值 → 应给${r.newMonth.label}月'),
      _probe(
        '秒级 exact +1s',
        exact.add(const Duration(seconds: 1)),
        '秒级真值后 1 秒 → 应给${r.newMonth.label}月',
      ),
    ]);
  }

  b.writeln('| 测试点 | 时间（+08:00） | 卦眼月建 | 期望月建 | 专业软件月建 '
      '| 一致 | 说明 |');
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
    final month = resolveCalendar(ctx, local).monthBranchLabel;
    final expected = at.isBefore(r.packHkt)
        ? r.oldMonth.label
        : r.newMonth.label;
    b.writeln(
      '| $label | ${wallClockWithOffsetText(local)} | $month | $expected '
      '| | | $note |',
    );
  }
  b.writeln();
  if (r.secondLevel == null) {
    b.writeln('> 本节气**暂无**可追溯秒级真值，因此不设秒级测试点。'
        '若日后取得官方秒级发布值，按同一表格追加 `exact −1s / exact / exact +1s`。');
    b.writeln();
  }
  return b.toString();
}

/// 该「节」所切换出去的月建。
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
