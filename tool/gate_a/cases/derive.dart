/// 卦例事实的**推导**与案例集合（模型见 `logic/case_facts.dart`）。
///
/// 锁定规则：本卦 / 变卦卦名必须与案例声明的一致，否则记入 `auditProblems`；
/// 另外复核纳甲组装顺序（下卦内三支 + 上卦外三支）。
library;

import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

import '../core/audit/hexagram_audit.dart';
import '../core/time/time_input.dart';
import '../gate_a_context.dart';
import 'data/classic_cases.dart';
import 'data/normal_cases_a.dart';
import 'data/normal_cases_b.dart';
import 'logic/case_facts.dart';
import 'logic/case_model.dart';

export 'data/boundary_cases.dart';
export 'data/classic_cases.dart';
export 'data/normal_cases_a.dart';
export 'data/normal_cases_b.dart';
export 'logic/case_facts.dart';
export 'logic/case_model.dart';

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
    if (def.expectedChanged != null &&
        chart.changed?.name != def.expectedChanged)
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
