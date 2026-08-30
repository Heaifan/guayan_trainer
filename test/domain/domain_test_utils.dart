/// 领域测试共享用例。
library;

import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';

/// 演示卦例：三爻卯木发动（老阳），上爻酉金与三爻卯木相冲。
/// 产出 2 条关系：动变(original-3 → changed-3) + 六冲(original-3 ↔ original-6)。
HexagramCase buildDemoCase({
  String id = 'case-demo-001',
  RuleExecutionContext ruleContext = const RuleExecutionContext.empty(),
}) =>
    HexagramCase(
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
