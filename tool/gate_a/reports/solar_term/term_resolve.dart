/// 从数据包解析官方参照（自 `solar_term_report.dart` 拆出）。
///
/// 只做一件事：把数据包里的交节瞬间 + 秒级哨兵表合成
/// `OfficialTermReference`。数据包缺该年时返回 `null`，由调用方决定怎么记。
library;

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

import '../../core/formatting/format.dart';
import '../../gate_a_context.dart';
import 'term_reference.dart';

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
    if (resolveOfficialReference(ctx, id, year)
        case final OfficialTermReference r)
      r,
];
