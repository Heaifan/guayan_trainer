/// 关系计算的**诊断信息**：明确报告「为什么少了一类关系」。
///
/// 冻结原则：缺失输入不得静默。
/// 旧卦例没有历法快照时，月建 / 日辰关系**不产出** —— 但必须能回答
/// 「是这个卦确实没有月日关系，还是这个卦缺输入？」，
/// 而不是让 UI / 调试者误以为「确实没有关系」。
library;

import 'relation_instance.dart';

/// 关系计算诊断（非错误型）。
class RelationCalculationDiagnostics {
  const RelationCalculationDiagnostics({
    this.missingInputs = const [],
    this.warnings = const [],
  });

  /// 缺失的输入项（稳定机器名），如 `calendar.monthBranch`、`line[3].branch`。
  final List<String> missingInputs;

  /// 其它需要暴露的异常情况（如规则互相踩导致重复 key）。
  final List<String> warnings;

  bool get isComplete => missingInputs.isEmpty && warnings.isEmpty;

  @override
  String toString() =>
      'RelationCalculationDiagnostics('
      'missing: ${missingInputs.length}, warnings: ${warnings.length})';
}

/// 关系计算结果：实例账本 + 诊断。
class RelationCalculationResult {
  const RelationCalculationResult({
    required this.instances,
    required this.diagnostics,
  });

  final List<RelationInstance> instances;

  final RelationCalculationDiagnostics diagnostics;
}
