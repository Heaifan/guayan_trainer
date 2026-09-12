/// 卦例事实：模型 + 计算 + 案例锁定（合并自 case_facts / derive 两份文件）。
///
/// 锁定规则：本卦 / 变卦卦名必须与案例声明的一致，否则记入 `auditProblems`；
/// 另外复核纳甲组装顺序（下卦内三支 + 上卦外三支）。
library;

import 'package:guayan_trainer/domain/calendar/calendar_context.dart';
import 'package:guayan_trainer/domain/casting/cast_chart.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

import '../core/audit/hexagram_audit.dart';
import '../gate_a_context.dart';
import 'logic/case_model.dart';
import '../core/time/time_input.dart';

import 'data/classic_cases.dart';
import 'data/normal_cases_a.dart';
import 'data/normal_cases_b.dart';

export 'data/boundary_cases.dart';
export 'logic/case_model.dart';
export 'data/classic_cases.dart';
export 'data/normal_cases_a.dart';
export 'data/normal_cases_b.dart';

/// 一个卦例的全部对照事实。
class CaseFacts {
  const CaseFacts({
    required this.def,
    required this.local,
    required this.calendar,
    required this.chart,
    required this.beforeLiChun,
    required this.auditProblems,
  });

  final GateACase def;

  /// 起卦当地挂钟时间（已解析，供派生取值复用）。
  final DateTime local;

  final CalendarContext calendar;
  final CastChart chart;

  /// 该时刻是否尚未交立春（决定年柱/月干的「年」）。
  final bool beforeLiChun;

  /// 结构自检问题（案例锁定 + 纳甲组装顺序）。
  final List<String> auditProblems;

  /// 本卦。
  Hexagram get original => chart.original;

  /// 变卦；静卦为 null。
  Hexagram? get changed => chart.changed;

  /// 六爻地支自初爻至上爻。
  List<DiZhi> get branches => branchesOf(chart);

  /// 卦体特征标签。
  String get bodyLabelText => bodyLabel(original, branches);

  /// 动爻显示文本。
  String get movingText => def.movingText;

  /// 是否为六冲卦。
  bool get isLiuChong => isLiuChongBranches(branches);

  /// 是否为六合卦。
  bool get isLiuHe => isLiuHeBranches(branches);

  /// 变卦六爻地支；静卦为 null。
  List<DiZhi>? get changedBranches =>
      chart.changed == null ? null : changedBranchList;

  /// 变卦六爻地支（仅变卦存在时有意义）。
  List<DiZhi> get changedBranchList =>
      [for (final l in chart.lines) l.changedBranch!];

  /// 变卦是否为六合卦 / 六冲卦（静卦为 false）。
  bool get isChangedLiuHe {
    final b = changedBranches;
    return b != null && isLiuHeBranches(b);
  }

  bool get isChangedLiuChong {
    final b = changedBranches;
    return b != null && isLiuChongBranches(b);
  }
}

/// 计算一个卦例的全部事实。
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
    local: local,
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

/// GA-1 全量十三例（a 册 + b 册）。
final List<GateACase> normalCases = <GateACase>[
  ...normalCasesA,
  ...normalCasesB,
];
