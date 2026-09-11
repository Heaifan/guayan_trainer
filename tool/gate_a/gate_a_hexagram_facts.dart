/// 卦例事实计算：一个 [GateACase] → 完整可对照的排盘事实（含旁证四柱）。
///
/// 只算事实，不渲染；渲染见 `gate_a_case_report.dart`。
library;

import 'package:guayan_trainer/domain/calendar/calendar_context.dart';
import 'package:guayan_trainer/domain/casting/cast_chart.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/tian_gan.dart';

import 'gate_a_cases.dart';
import 'gate_a_context.dart';
import 'gate_a_hexagram_audit.dart';
import 'gate_a_pillars.dart';

/// 一个卦例的全部对照事实。
class CaseFacts {
  const CaseFacts({
    required this.def,
    required this.calendar,
    required this.chart,
    required this.beforeLiChun,
    required this.auditProblems,
  });

  final GateACase def;
  final CalendarContext calendar;
  final CastChart chart;

  /// 该时刻是否尚未交立春（决定年柱/月干的「年」）。
  final bool beforeLiChun;

  /// 结构自检问题（本卦/变卦纳甲组装顺序）。
  final List<String> auditProblems;

  /// 本卦。
  Hexagram get original => chart.original;

  /// 变卦；静卦为 null。
  Hexagram? get changed => chart.changed;

  /// 六爻地支自初爻至上爻。
  List<dynamic> get branches => branchesOf(chart);

  /// 年柱文本。
  String get yearPillarText =>
      yearPillar(parseWallClock(def.localTime).year, beforeLiChun);

  /// 月柱文本（五虎遁 + 月建）。
  String get monthPillarText =>
      monthPillar(yearGanOf(), calendar.monthBranch);

  /// 时柱文本（按当日日干起例；23 时后即「晚子时」口径）。
  String get hourPillarText =>
      hourPillar(calendar.day.gan, parseWallClock(def.localTime).hour);

  /// 是否落在 23:00—23:59（时干口径存在流派差异的窗口）。
  bool get isLateZiHour => parseWallClock(def.localTime).hour == 23;

  /// 时柱的另一种口径（按次日日干起例；仅供 23 时后对照）。
  String get hourPillarNextDayText => hourPillar(
    nextDayGan(calendar.day.gan),
    parseWallClock(def.localTime).hour,
  );

  /// 年干（立春换年后的年干）。
  TianGan yearGanOf() => yearGan(parseWallClock(def.localTime).year, beforeLiChun);

  /// 卦体特征标签。
  String get bodyLabelText => bodyLabel(original, branchesOf(chart));

  /// 动爻显示文本。
  String get movingText => def.movingText;

  /// 是否为六冲卦。
  bool get isLiuChong => isLiuChongBranches(branchesOf(chart));

  /// 是否为六合卦。
  bool get isLiuHe => isLiuHeBranches(branchesOf(chart));

  /// 变卦是否为六合卦（静卦为 false）。
  bool get isChangedLiuHe {
    if (chart.changed == null) return false;
    return isLiuHeBranches(<DiZhi>[
      for (final l in chart.lines) l.changedBranch!,
    ]);
  }

  /// 变卦是否为六冲卦（静卦为 false）。
  bool get isChangedLiuChong {
    if (chart.changed == null) return false;
    return isLiuChongBranches(<DiZhi>[
      for (final l in chart.lines) l.changedBranch!,
    ]);
  }
}

/// 计算一个卦例的全部事实。
///
/// 同时**锁定案例**：本卦 / 变卦卦名必须与案例声明的期望一致，
/// 否则把问题记进 [CaseFacts.auditProblems]（不静默通过）。
CaseFacts computeCaseFacts(GateAContext ctx, GateACase def) {
  final local = parseWallClock(def.localTime);
  final calendar = ctx.engine.resolve(
    calendarRequestFor(local, dayBoundaryRuleMidnight),
  );
  final chart = CastingEngine.cast(def.movements, dayGan: calendar.day.gan);
  final before = isBeforeLiChun(ctx, calendar.instantUtc, local.year);

  final problems = <String>[
    if (chart.original.name != def.expectedOriginal)
      '案例锁定失败：本卦期望「${def.expectedOriginal}」，'
          '实际「${chart.original.name}」（位串 ${def.originalBits}）',
    if (def.expectedChanged != null && chart.changed?.name != def.expectedChanged)
      '案例锁定失败：变卦期望「${def.expectedChanged}」，'
          '实际「${chart.changed?.name ?? '（静卦）'}」',
    if (def.expectedChanged == null && chart.changed != null)
      '案例锁定失败：声明为静卦但产生了变卦',
    ...verifyNajiaAssembly(chart.original, branchesOf(chart)),
    if (chart.changed != null)
      ...verifyNajiaAssembly(chart.changed!, <DiZhi>[
        for (final l in chart.lines) l.changedBranch!,
      ]),
  ];

  return CaseFacts(
    def: def,
    calendar: calendar,
    chart: chart,
    beforeLiChun: before,
    auditProblems: problems,
  );
}

/// 全部卦例事实（GA-1 + GA-2）。
List<CaseFacts> computeAllCaseFacts(GateAContext ctx) => [
  for (final c in normalCases) computeCaseFacts(ctx, c),
  for (final c in classicCases) computeCaseFacts(ctx, c),
];
