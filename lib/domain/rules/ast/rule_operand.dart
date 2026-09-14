library;

import '../facts/rule_value.dart';

/// PredicateExpr 中的操作数，可以是 Binding 引用，或者是字面量。
abstract class RuleOperand {
  const RuleOperand();
}

class BindingRefOperand extends RuleOperand {
  const BindingRefOperand(this.bindingName);
  final String bindingName;
}

class LiteralOperand extends RuleOperand {
  const LiteralOperand(this.value);
  /// 字面量必须是受 RuleValue 支持的类型，不能是函数或任何带有行为的表达式。
  final RuleValue value;
}
