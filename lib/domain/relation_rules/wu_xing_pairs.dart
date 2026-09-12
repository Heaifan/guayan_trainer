/// 五行相生 / 五行相克（R4 基础关系，有向，**事实账本**）。
///
/// 冻结口径（§12.1）：本卦六爻执行无序两两组合，共 C(6,2) = 15 对；
/// 对每一对：
/// ```text
/// A 生 B → A -> B · sheng
/// B 生 A → B -> A · sheng
/// A 克 B → A -> B · ke
/// B 克 A → B -> A · ke
/// 同五行 → 本层不产出生/克关系
/// ```
/// 一对最多产出一条（生与克对同一对互斥），因此本模块最多 15 条。
///
/// **本层只表达「客观五行关系存在」，不判断该关系是否具有断卦作用力。**
/// 静爻与静爻之间同样产出事实关系；「谁真正作用于谁」由后续
/// Effect / Rule 层判定。UI 通过筛选器控制可视关系，
/// 不得为了图面简洁反向裁剪 Domain 数据。
///
/// 变爻与其它爻、月建、日辰的五行关系各由 `changed_lines.dart` /
/// `month_day.dart` 承担（它们属于不同的事实类别）。
library;

import '../hexagram_case.dart';
import '../relation_instance.dart';
import '../relation_type.dart';
import 'rule_support.dart';

/// 本卦六爻两两之间的五行相生 / 相克事实关系。
List<RelationInstance> wuXingPairRelations(HexagramCase c) {
  final out = <RelationInstance>[];
  final lines = c.lines;
  for (var i = 0; i < lines.length; i++) {
    for (var j = i + 1; j < lines.length; j++) {
      final a = zhiOf(lines[i].branch);
      final b = zhiOf(lines[j].branch);
      if (a == null || b == null) continue;
      final ai = lines[i].position;
      final bj = lines[j].position;
      if (a.wuXing.generates == b.wuXing) {
        out.add(_sheng(c, ai, bj));
      } else if (b.wuXing.generates == a.wuXing) {
        out.add(_sheng(c, bj, ai));
      } else if (a.wuXing.controls == b.wuXing) {
        out.add(_ke(c, ai, bj));
      } else if (b.wuXing.controls == a.wuXing) {
        out.add(_ke(c, bj, ai));
      }
    }
  }
  return out;
}

RelationInstance _sheng(HexagramCase c, int from, int to) => systemRelation(
  c: c,
  type: RelationType.sheng,
  ruleId: SystemRuleIds.sheng,
  source: originalYao(from),
  target: originalYao(to),
);

RelationInstance _ke(HexagramCase c, int from, int to) => systemRelation(
  c: c,
  type: RelationType.ke,
  ruleId: SystemRuleIds.ke,
  source: originalYao(from),
  target: originalYao(to),
);
