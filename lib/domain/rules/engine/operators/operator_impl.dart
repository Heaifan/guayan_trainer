library;

import '../../facts/fact_snapshot.dart';
import '../../facts/semantic_ref.dart';
import '../../facts/rule_value.dart';
import '../binding_resolver.dart';

import '../predicate_result.dart';

/// 运算符执行上下文
class OperatorContext {
  const OperatorContext({
    required this.snapshot,
    required this.bindingContext,
  });

  final FactSnapshot snapshot;
  final BindingContext bindingContext;
}

/// 运算数包装，可能是 resolved 的 SemanticRef，或者是 RuleValue 字面量
class ResolvedOperand {
  final SemanticRef? reference;
  final RuleValue? literal;

  const ResolvedOperand.ref(this.reference) : literal = null;
  const ResolvedOperand.literal(this.literal) : reference = null;

  bool get isRef => reference != null;
  bool get isLiteral => literal != null;

  @override
  String toString() {
    if (isRef) return reference.toString();
    return literal.toString();
  }
}

/// 具体的条件运算符实现接口
abstract class OperatorImpl {
  const OperatorImpl();

  /// 对应的 conditionId
  String get operatorId;

  /// 执行运算
  PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext context);
}
