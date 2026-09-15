import '../../facts/rule_value.dart';
import '../../vocabulary/condition_id.dart';
import '../../evidence/evidence_id.dart';
import '../predicate_result.dart';
import 'operator_impl.dart';

class HasTagOperator extends OperatorImpl {
  const HasTagOperator();
  @override
  String get operatorId => ConditionId.hasTag;
  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 3 ||
        !operands[0].isRef ||
        !operands[1].isLiteral ||
        !operands[2].isLiteral)
      return PredicateResult.fail;
    final category = operands[1].literal!.value as String;
    final tag = operands[2].literal!.value as String;
    final f = ctx.snapshot.facts
        .where(
          (f) =>
              f.subject == operands[0].reference &&
              f.predicateId == 'has_tag_$category' &&
              f.value == RuleValue.string(tag),
        )
        .firstOrNull;
    return f != null
        ? PredicateResult.match([EvidenceId(f.factId)])
        : PredicateResult.fail;
  }
}
