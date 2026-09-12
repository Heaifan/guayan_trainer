/// 月建 / 日辰的**基础作用**（R4 基础关系，有向）。
///
/// 口径（第一批只做基础作用，不含旺衰 / 墓库 / 空破）：
/// ```text
/// 月建五行生爻五行 → month -> 本卦某爻 · sheng
/// 月建五行克爻五行 → month -> 本卦某爻 · ke
/// 日辰同上门（day）
/// ```
/// 只产出「生」「克」两种：比和（同五行）与「爻生月日 / 爻克月日」
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
List<RelationInstance> monthDayRelations(HexagramCase c) {
  final calendar = c.calendar;
  if (calendar == null) return const <RelationInstance>[];
  final out = <RelationInstance>[];
  final month = zhiOf(calendar.monthBranch);
  final day = zhiOf(calendar.dayBranch);
  for (final line in c.lines) {
    final z = zhiOf(line.branch);
    if (z == null) continue;
    _effects(
      out,
      c,
      month,
      const MonthEndpoint(),
      SystemRuleIds.monthBranch,
      z,
      line.position,
    );
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
        type: RelationType.sheng,
        ruleId: ruleId,
        source: from,
        target: to,
      ),
    );
  } else if (ruler.wuXing.controls == target.wuXing) {
    out.add(
      systemRelation(
        c: c,
        type: RelationType.ke,
        ruleId: ruleId,
        source: from,
        target: to,
      ),
    );
  }
}
