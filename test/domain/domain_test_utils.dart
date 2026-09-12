/// 领域测试共享用例。
library;

import 'package:guayan_trainer/domain/calendar_snapshot.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_instance.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';

/// 某规则产出的 canonical 集合（便于在断言里逐条肉眼核对）。
Set<String> canonicalsOf(List<RelationInstance> all, String ruleId) => {
  for (final r in all)
    if (r.key.ruleId == ruleId) r.key.canonical,
};

/// 演示卦例：三爻卯木发动（老阳），上爻酉金与三爻卯木相冲。
///
/// 五行：亥水 · 丑土 · 卯木 · 午火 · 申金 · 酉金。
/// R4 基础关系引擎产出 16 条：
/// ```text
/// 动变      1 条   三爻 original → changed
/// 六冲      1 条   三爻卯 ↔ 上爻酉
/// 六合      0 条   本卦六爻无合对
/// 五行生克 14 条   C(6,2)=15 对，仅「申金 vs 酉金」同五行不产出
/// 回头生克  0 条   本用例未记录变爻地支（changedBranch）
/// 月建/日辰 0 条   本用例未记录历法快照（calendar）
/// ```
/// 缺口不是静默的：`missingInputsOf` 会报出 calendar 与 changedBranch 缺失。
HexagramCase buildDemoCase({
  String id = 'case-demo-001',
  RuleExecutionContext ruleContext = const RuleExecutionContext.empty(),
}) => HexagramCase(
  id: id,
  question: '本次考试成绩如何？',
  createdAt: DateTime.utc(2026, 8, 27, 20, 11),
  ruleContext: ruleContext,
  lines: [
    LineState(position: 1, movementType: MovementType.shaoYin, branch: '亥'),
    LineState(position: 2, movementType: MovementType.shaoYang, branch: '丑'),
    LineState(position: 3, movementType: MovementType.laoYang, branch: '卯'),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '午'),
    LineState(position: 5, movementType: MovementType.shaoYang, branch: '申'),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '酉'),
  ],
);

/// R4 九类关系的受控用例（覆盖全部关系家族）。
///
/// ```text
/// 爻位  地支  五行  动静 / 变爻地支
///  1    亥    水    静
///  2    辰    土    静      ┐ 辰酉六合（2-5）
///  3    卯    木    老阳动  变申(金)   → 申金克卯木 = 回头克
///  4    午    火    静
///  5    酉    金    老阴动  变丑(土)   → 丑土生酉金 = 回头生  ┘ 且卯酉六冲（3-5）
///  6    丑    土    静
/// ```
/// 历法快照默认：月建 **寅(木)**、日辰 **甲子(日支 子水)**。
///
/// [calendar] 传 null 可模拟「旧卦例没有历法快照」；
/// [withChangedBranch] = false 可模拟「动爻没有记录变爻地支」；
/// [withMoving] = false 可模拟**静卦**（三、五爻改为少阴/少阳）。
HexagramCase buildR4Case({
  CalendarSnapshot? calendar = const CalendarSnapshot(
    monthBranch: '寅',
    dayGanZhi: '甲子',
  ),
  bool withChangedBranch = true,
  bool withMoving = true,
  String id = 'case-r4-001',
}) => HexagramCase(
  id: id,
  question: 'R4 关系引擎受控用例',
  createdAt: DateTime.utc(2026, 3, 1, 10, 0),
  calendar: calendar,
  lines: [
    LineState(position: 1, movementType: MovementType.shaoYin, branch: '亥'),
    LineState(position: 2, movementType: MovementType.shaoYang, branch: '辰'),
    LineState(
      position: 3,
      movementType: withMoving ? MovementType.laoYang : MovementType.shaoYang,
      branch: '卯',
      changedBranch: withMoving && withChangedBranch ? '申' : null,
    ),
    LineState(position: 4, movementType: MovementType.shaoYin, branch: '午'),
    LineState(
      position: 5,
      movementType: withMoving ? MovementType.laoYin : MovementType.shaoYin,
      branch: '酉',
      changedBranch: withMoving && withChangedBranch ? '丑' : null,
    ),
    LineState(position: 6, movementType: MovementType.shaoYin, branch: '丑'),
  ],
);
