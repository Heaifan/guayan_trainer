/// R4 基础关系引擎：从 [HexagramCase] 推导 [RelationInstance] 列表。
///
/// **确定性契约（R4 冻结）**：
/// ```text
/// 相同 HexagramCase + 相同 ruleVersion  =>  相同 RelationInstance 集合
/// ```
/// 正式输入只有 [HexagramCase] —— 一切影响关系结果的事实都必须能从它自身
/// 复现（含 [HexagramCase.calendar] 历法快照）。禁止第二隐式输入。
///
/// 不依赖 Flutter、不依赖页面、不依赖 Painter（纯 Dart Domain）。
///
/// 覆盖 §12.1 第一批九类关系，分四个模块：
/// ```text
/// changed_lines.dart   动变 · 回头生 · 回头克
/// branch_pairs.dart    六冲 · 六合
/// wu_xing_pairs.dart   五行相生 · 五行相克（本卦六爻两两，事实账本）
/// month_day.dart       月建基础作用 · 日辰基础作用
/// ```
/// 输出按 RelationKey canonical 稳定排序（同输入永远同序列）。
///
/// **本层是「事实账本」，不是「画箭头清单」**：只表达客观关系存在，
/// 不判断该关系在当前卦里是否真正发生作用（那属于后续 Effect / Rule 层）。
library;

import 'hexagram_case.dart';
import 'relation_diagnostics.dart';
import 'relation_instance.dart';
import 'relation_rules/branch_pairs.dart';
import 'relation_rules/changed_lines.dart';
import 'relation_rules/month_day.dart';
import 'relation_rules/wu_xing_pairs.dart';

/// 计算全部基础关系，并附带「为什么少了某类关系」的诊断。
RelationCalculationResult calculateRelationResult(HexagramCase hexagramCase) {
  final instances = <RelationInstance>[
    ...changedLineRelations(hexagramCase),
    ...chongHeRelations(hexagramCase),
    ...wuXingPairRelations(hexagramCase),
    ...monthDayRelations(hexagramCase),
  ];
  instances.sort((a, b) => a.key.canonical.compareTo(b.key.canonical));

  final warnings = <String>[];
  for (var i = 1; i < instances.length; i++) {
    if (instances[i].key == instances[i - 1].key) {
      warnings.add('重复 RelationKey（规则互相踩）：${instances[i].key.canonical}');
    }
  }

  return RelationCalculationResult(
    instances: instances,
    diagnostics: RelationCalculationDiagnostics(
      missingInputs: missingInputsOf(hexagramCase),
      warnings: warnings,
    ),
  );
}

/// 只要实例账本的便捷入口（既有调用点保持不变）。
List<RelationInstance> calculateRelations(HexagramCase hexagramCase) =>
    calculateRelationResult(hexagramCase).instances;

/// 列出缺失的输入项，供诊断与调试回答「为什么少了一类关系」。
///
/// 缺失是**显式状态**：旧卦例没有历法快照时不产出月日关系，
/// 但也不允许静默 —— 否则会把「缺输入」误读成「确实没有关系」。
List<String> missingInputsOf(HexagramCase hexagramCase) {
  final out = <String>[];
  if (hexagramCase.calendar == null) {
    out.add('calendar.monthBranch');
    out.add('calendar.dayBranch');
  }
  for (final line in hexagramCase.lines) {
    if (line.branch == null) out.add('line[${line.position}].branch');
    if (line.movementType.isMoving && line.changedBranch == null) {
      out.add('line[${line.position}].changedBranch');
    }
  }
  return out;
}
