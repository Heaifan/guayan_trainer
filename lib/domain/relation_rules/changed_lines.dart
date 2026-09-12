/// 动变 / 回头生 / 回头克（R4 基础关系，有向）。
///
/// ```text
/// 动变    本卦 p 爻 -> 变卦 p 爻      （只依赖「该爻发动」，不需地支）
/// 回头生  变爻 -> 本爻，变爻五行生本爻五行
/// 回头克  变爻 -> 本爻，变爻五行克本爻五行
/// ```
/// 端点方向取 `changed-p -> original-p`（与既有 RelationKey 文档样例一致）。
///
/// 回头生 / 回头克需要**变爻地支**（[LineState.changedBranch]）。
/// 缺该输入时静爻不产出、动爻只产出动变 —— 缺失由诊断明确报告，
/// 绝不用「本爻地支」冒充变爻地支来凑一条关系。
library;

import '../hexagram_case.dart';
import '../relation_instance.dart';
import '../relation_type.dart';
import 'rule_support.dart';

/// 动变 / 回头生 / 回头克关系。
List<RelationInstance> changedLineRelations(HexagramCase c) {
  final out = <RelationInstance>[];
  for (final line in c.lines) {
    if (!line.movementType.isMoving) continue;
    final p = line.position;
    out.add(
      systemRelation(
        c: c,
        type: RelationType.dongBian,
        ruleId: SystemRuleIds.dongBian,
        source: originalYao(p),
        target: changedYao(p),
      ),
    );
    final original = zhiOf(line.branch);
    final changed = zhiOf(line.changedBranch);
    if (original == null || changed == null) continue;
    if (changed.wuXing.generates == original.wuXing) {
      out.add(
        _huiTou(c, p, RelationType.huiTouSheng, SystemRuleIds.huiTouSheng),
      );
    } else if (changed.wuXing.controls == original.wuXing) {
      out.add(_huiTou(c, p, RelationType.huiTouKe, SystemRuleIds.huiTouKe));
    }
  }
  return out;
}

RelationInstance _huiTou(
  HexagramCase c,
  int position,
  RelationType type,
  String ruleId,
) => systemRelation(
  c: c,
  type: type,
  ruleId: ruleId,
  source: changedYao(position),
  target: originalYao(position),
);
