/// 动变 / 回头生 / 回头克（R4 基础关系，有向）。
///
/// ```text
/// 动变    本卦 p 爻 -> 变卦 p 爻      （只依赖「该爻发动」，不需地支）
/// 回头生  变爻 -> 本爻，变爻五行生本爻五行
/// 回头克  变爻 -> 本爻，变爻五行克本爻五行
/// ```
///
/// 本模块只识别关系事实，不把“回头生 / 回头克”写成状态标签。
/// 对原动爻主动行为资格的影响，由 action_resolution.dart 单独裁决。
///
/// 冻结边界：变爻只参与同位“回头生 / 回头克”判定。
/// 无论本位是否形成回头关系，变爻都不得向其他原卦爻外放普通生克，
/// 也不得与其他变爻发生普通生克。
/// 端点方向取 `changed-p -> original-p`（与既有 RelationKey 文档样例一致）。
///
/// 回头生 / 回头克需要**变爻地支**（[LineState.changedBranch]）。
/// 缺该输入时静爻不产出、动爻只产出动变 —— 缺失由诊断明确报告，
/// 绝不用「本爻地支」冒充变爻地支来凑一条关系。
library;

import '../hexagram_case.dart';
import '../line_state.dart';
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
    final type = classifyBackRelation(
      original: line,
      changedPosition: p,
      changedBranch: line.changedBranch,
    );
    if (type != null) {
      out.add(_huiTou(c, p, type, _ruleIdFor(type)));
    }
  }
  return out;
}

/// 唯一的回头生克分类入口。
///
/// 方向永远是 `changed.element → original.element`；[changedPosition] 只
/// 接受与原动爻相同的 Domain line number，绝不使用 UI 行号或列表反转。
RelationType? classifyBackRelation({
  required LineState original,
  required int changedPosition,
  required String? changedBranch,
}) {
  if (!original.movementType.isMoving || original.position != changedPosition) {
    return null;
  }
  final originalZhi = zhiOf(original.branch);
  final changedZhi = zhiOf(changedBranch);
  if (originalZhi == null || changedZhi == null) return null;
  if (changedZhi.wuXing.generates == originalZhi.wuXing) {
    return RelationType.huiTouSheng;
  }
  if (changedZhi.wuXing.controls == originalZhi.wuXing) {
    return RelationType.huiTouKe;
  }
  return null;
}

String _ruleIdFor(RelationType type) => switch (type) {
  RelationType.huiTouSheng => SystemRuleIds.huiTouSheng,
  RelationType.huiTouKe => SystemRuleIds.huiTouKe,
  _ => throw StateError('不是回头生克类型：${type.machineName}'),
};

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
