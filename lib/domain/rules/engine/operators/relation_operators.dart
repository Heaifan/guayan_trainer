import '../../vocabulary/condition_id.dart';
import '../../evidence/evidence_id.dart';
import '../predicate_result.dart';
import 'operator_impl.dart';

class GenerateOperator extends OperatorImpl {
  const GenerateOperator();
  @override
  String get operatorId => ConditionId.generate;
  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isRef)
      { return PredicateResult.fail; }
    final r = ctx.snapshot.relations
        .where(
          (r) =>
              r.relationId == 'generate' &&
              r.subjects.length == 2 &&
              r.subjects[0] == '${operands[0].reference!.kind}/${operands[0].reference!.key}' &&
              r.subjects[1] == '${operands[1].reference!.kind}/${operands[1].reference!.key}',
        )
        .firstOrNull;
    return r != null
        ? PredicateResult.match([EvidenceId(r.evidenceId)])
        : PredicateResult.fail;
  }
}

class SimpleRelationOperator extends OperatorImpl {
  const SimpleRelationOperator(this._opId, this._relationId);
  final String _opId, _relationId;
  @override
  String get operatorId => _opId;
  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isRef)
      { return PredicateResult.fail; }
    final r = ctx.snapshot.relations
        .where(
          (r) =>
              r.relationId == _relationId &&
              r.subjects.length == 2 &&
              r.subjects[0] == '${operands[0].reference!.kind}/${operands[0].reference!.key}' &&
              r.subjects[1] == '${operands[1].reference!.kind}/${operands[1].reference!.key}',
        )
        .firstOrNull;
    return r != null
        ? PredicateResult.match([EvidenceId(r.evidenceId)])
        : PredicateResult.fail;
  }
}

class ChuMuOperator extends OperatorImpl {
  const ChuMuOperator();
  @override
  String get operatorId => ConditionId.chuMu;
  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 3 ||
        !operands[0].isRef ||
        !operands[1].isRef ||
        !operands[2].isRef)
      { return PredicateResult.fail; }
    final r = ctx.snapshot.relations
        .where(
          (r) =>
              r.relationId == 'chu_mu' &&
              r.subjects.length == 3 &&
              r.subjects[0] == '${operands[0].reference!.kind}/${operands[0].reference!.key}' &&
              r.subjects[1] == '${operands[1].reference!.kind}/${operands[1].reference!.key}' &&
              r.subjects[2] == '${operands[2].reference!.kind}/${operands[2].reference!.key}',
        )
        .firstOrNull;
    return r != null
        ? PredicateResult.match([EvidenceId(r.evidenceId)])
        : PredicateResult.fail;
  }
}
