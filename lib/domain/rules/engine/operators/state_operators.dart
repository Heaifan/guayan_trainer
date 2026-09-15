import '../../facts/rule_value.dart';
import '../../vocabulary/condition_id.dart';
import '../../evidence/evidence_id.dart';
import '../predicate_result.dart';
import 'operator_impl.dart';

class EmptyOperator extends OperatorImpl {
  const EmptyOperator();
  @override
  String get operatorId => ConditionId.empty;
  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 1 || !operands[0].isRef) return PredicateResult.fail;
    final f = ctx.snapshot.facts
        .where(
          (f) =>
              f.subject == operands[0].reference &&
              f.predicateId == 'state' &&
              f.value == RuleValue.string('kong_wang'),
        )
        .firstOrNull;
    return f != null
        ? PredicateResult.match([EvidenceId(f.factId)])
        : PredicateResult.fail;
  }
}

class SimpleStateOperator extends OperatorImpl {
  const SimpleStateOperator(this._opId, this._stateId);
  final String _opId, _stateId;
  @override
  String get operatorId => _opId;
  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 1 || !operands[0].isRef) return PredicateResult.fail;
    final f = ctx.snapshot.facts
        .where(
          (f) =>
              f.subject == operands[0].reference &&
              f.predicateId == 'state' &&
              f.value == RuleValue.string(_stateId),
        )
        .firstOrNull;
    return f != null
        ? PredicateResult.match([EvidenceId(f.factId)])
        : PredicateResult.fail;
  }
}
