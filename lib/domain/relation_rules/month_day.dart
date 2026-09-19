/// 月建 / 日辰的**基础作用**（R4 基础关系，有向）。
///
/// 口径（第一批只做基础作用，不含旺衰 / 墓库 / 空破）：
/// ```text
/// 月建五行生爻五行 → month -> 本卦某爻 · month_generate
/// 月建五行克爻五行 → month -> 本卦某爻 · month_control
/// 日辰同上门（day），对应 `day_generate` / `day_control`。
/// ```
/// 只产出月日语义的四种作用类型：比和（同五行）与「爻生月日 / 爻克月日」
/// 属后续高级规则层，本层不产出，避免把「客观五行关系」与
/// 「断卦作用力」混为一谈。
///
/// 数据来源是 [HexagramCase.calendar] 快照（**只读快照，不重新调用历法引擎**）：
/// 历法数据包将来升级时，历史卦例的月建 / 日辰不得漂移。
/// 快照缺失 → 本模块返回空列表，并由诊断报告 `calendar.monthBranch` /
/// `calendar.dayBranch` 缺失；**禁止**自动补算或猜测。
library;

import '../di_zhi.dart';
import '../hexagram_case.dart';
import '../relation_endpoint.dart';
import '../relation_instance.dart';
import '../relation_type.dart';
import 'rule_support.dart';

/// 月建 / 日辰对六爻的基础作用关系。
///
/// “入卦”严格只看主卦六个明爻的 [LineState.branch]：
/// 月支/日支与任一主卦明爻同支，才取得本层的主动生克资格。
/// 变爻、伏神即使临月/临日，也不作为“月建入卦/日建入卦”的依据。
List<RelationInstance> monthDayRelations(HexagramCase c) {
  final calendar = c.calendar;
  if (calendar == null) return const <RelationInstance>[];
  final out = <RelationInstance>[];
  final month = zhiOf(calendar.monthBranch);
  final day = zhiOf(calendar.dayBranch);
  final originalBranches = {
    for (final line in c.lines)
      if (line.branch != null) line.branch,
  };
  final monthEntered = originalBranches.contains(calendar.monthBranch);
  final dayEntered = originalBranches.contains(calendar.dayBranch);
  for (final line in c.lines) {
    final z = zhiOf(line.branch);
    if (z == null) continue;
    if (monthEntered) {
      _effects(
        out,
        c,
        month,
        const MonthEndpoint(),
        SystemRuleIds.monthBranch,
        z,
        line.position,
      );
    }
    if (dayEntered) {
      _effects(
        out,
        c,
        day,
        const DayEndpoint(),
        SystemRuleIds.dayBranch,
        z,
        line.position,
      );
    }
  }
  return out;
}

/// [ruler]（月建或日辰）对 [target] 爻的五行作用。
void _effects(
  List<RelationInstance> out,
  HexagramCase c,
  DiZhi? ruler,
  RelationEndpoint from,
  String ruleId,
  DiZhi target,
  int position,
) {
  if (ruler == null) return;
  final to = originalYao(position);
  if (ruler.wuXing.generates == target.wuXing) {
    out.add(
      systemRelation(
        c: c,
        type: from is MonthEndpoint
            ? RelationType.monthGenerate
            : RelationType.dayGenerate,
        ruleId: ruleId,
        source: from,
        target: to,
      ),
    );
  } else if (ruler.wuXing.controls == target.wuXing) {
    out.add(
      systemRelation(
        c: c,
        type: from is MonthEndpoint
            ? RelationType.monthControl
            : RelationType.dayControl,
        ruleId: ruleId,
        source: from,
        target: to,
      ),
    );
  }
}
