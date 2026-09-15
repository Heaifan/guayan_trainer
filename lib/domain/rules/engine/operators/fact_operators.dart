import '../../facts/rule_value.dart';
import '../../vocabulary/condition_id.dart';
import '../../evidence/evidence_id.dart';
import '../predicate_result.dart';
import 'operator_impl.dart';

class RelativeOperator extends OperatorImpl {
  const RelativeOperator();
  @override
  String get operatorId => ConditionId.relative;
  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isLiteral)
      return PredicateResult.fail;
    final f = ctx.snapshot.facts
        .where(
          (f) =>
              f.subject == operands[0].reference &&
              f.predicateId == 'relative' &&
              f.value == RuleValue.string(operands[1].literal!.value as String),
        )
        .firstOrNull;
    return f != null
        ? PredicateResult.match([EvidenceId(f.factId)])
        : PredicateResult.fail;
  }
}

class BinaryLiteralOperator extends OperatorImpl {
  const BinaryLiteralOperator(this._opId, this._predicateId);
  final String _opId, _predicateId;
  @override
  String get operatorId => _opId;
  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isLiteral)
      return PredicateResult.fail;
    final f = ctx.snapshot.facts
        .where(
          (f) =>
              f.subject == operands[0].reference &&
              f.predicateId == _predicateId &&
              f.value == RuleValue.string(operands[1].literal!.value as String),
        )
        .firstOrNull;
    return f != null
        ? PredicateResult.match([EvidenceId(f.factId)])
        : PredicateResult.fail;
  }
}
