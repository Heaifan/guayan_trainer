library;

import '../../evidence/evidence_id.dart';
import '../../vocabulary/condition_id.dart';
import '../predicate_result.dart';
import 'operator_impl.dart';

class StructureFormedOperator extends OperatorImpl {
  const StructureFormedOperator();

  @override
  String get operatorId => ConditionId.structureFormed;

  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 1 || !operands[0].isLiteral) {
      return PredicateResult.fail;
    }
    final target = operands[0].literal!.value as String;
    final fact = ctx.snapshot.structures.where((structure) {
      return structure.state.name == 'formed' &&
          '${structure.kind.name}.${structure.element}' == target;
    }).firstOrNull;
    return fact == null
        ? PredicateResult.fail
        : PredicateResult.match([EvidenceId(fact.id)]);
  }
}
