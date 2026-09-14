library;

import 'rule_operand.dart';

/// Rule AST 绑定的逻辑条件表达式。
/// 只允许 ALL(且), ANY(或), NOT(非), PREDICATE(具体谓词) 四种节点。
abstract class RuleExpr {
  const RuleExpr();
}

class AllExpr extends RuleExpr {
  const AllExpr(this.nodes);
  final List<RuleExpr> nodes;
}

class AnyExpr extends RuleExpr {
  const AnyExpr(this.nodes);
  final List<RuleExpr> nodes;
}

class NotExpr extends RuleExpr {
  const NotExpr(this.node);
  final RuleExpr node;
}

class PredicateExpr extends RuleExpr {
  const PredicateExpr({
    required this.operatorId,
    required this.operands,
  });
  final String operatorId;
  final List<RuleOperand> operands;
}


