library;
import '../../facts/rule_value.dart';
import '../../vocabulary/condition_id.dart';
import '../../evidence/evidence_id.dart';
import '../predicate_result.dart';
import 'operator_impl.dart';

class GenerateOperator extends OperatorImpl {
  const GenerateOperator();
  @override String get operatorId => ConditionId.generate;
  @override PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext ctx) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isRef) return PredicateResult.fail;
    final f = ctx.snapshot.facts.where((f) => f.subject == operands[0].reference && f.predicateId == 'relation.generate' && f.value == RuleValue.string('${operands[1].reference!.kind}/${operands[1].reference!.key}')).firstOrNull;
    return f != null ? PredicateResult.match([EvidenceId(f.factId)]) : PredicateResult.fail;
  }
}

class EmptyOperator extends OperatorImpl {
  const EmptyOperator();
  @override String get operatorId => ConditionId.empty;
  @override PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext ctx) {
    if (operands.length != 1 || !operands[0].isRef) return PredicateResult.fail;
    final f = ctx.snapshot.facts.where((f) => f.subject == operands[0].reference && f.predicateId == 'state' && f.value == RuleValue.string('kong_wang')).firstOrNull;
    return f != null ? PredicateResult.match([EvidenceId(f.factId)]) : PredicateResult.fail;
  }
}

class HasTagOperator extends OperatorImpl {
  const HasTagOperator();
  @override String get operatorId => ConditionId.hasTag;
  @override PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext ctx) {
    if (operands.length != 3 || !operands[0].isRef || !operands[1].isLiteral || !operands[2].isLiteral) return PredicateResult.fail;
    final category = operands[1].literal!.value as String;
    final tag = operands[2].literal!.value as String;
    final f = ctx.snapshot.facts.where((f) => f.subject == operands[0].reference && f.predicateId == 'has_tag_$category' && f.value == RuleValue.string(tag)).firstOrNull;
    return f != null ? PredicateResult.match([EvidenceId(f.factId)]) : PredicateResult.fail;
  }
}

class RelativeOperator extends OperatorImpl {
  const RelativeOperator();
  @override String get operatorId => ConditionId.relative;
  @override PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext ctx) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isLiteral) return PredicateResult.fail;
    final f = ctx.snapshot.facts.where((f) => f.subject == operands[0].reference && f.predicateId == 'relative' && f.value == RuleValue.string(operands[1].literal!.value as String)).firstOrNull;
    return f != null ? PredicateResult.match([EvidenceId(f.factId)]) : PredicateResult.fail;
  }
}

class SimpleStateOperator extends OperatorImpl {
  const SimpleStateOperator(this._opId, this._stateId);
  final String _opId, _stateId;
  @override String get operatorId => _opId;
  @override PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext ctx) {
    if (operands.length != 1 || !operands[0].isRef) return PredicateResult.fail;
    final f = ctx.snapshot.facts.where((f) => f.subject == operands[0].reference && f.predicateId == 'state' && f.value == RuleValue.string(_stateId)).firstOrNull;
    return f != null ? PredicateResult.match([EvidenceId(f.factId)]) : PredicateResult.fail;
  }
}

class SimpleRelationOperator extends OperatorImpl {
  const SimpleRelationOperator(this._opId, this._relationId);
  final String _opId, _relationId;
  @override String get operatorId => _opId;
  @override PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext ctx) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isRef) return PredicateResult.fail;
    final f = ctx.snapshot.facts.where((f) => f.subject == operands[0].reference && f.predicateId == 'relation.$_relationId' && f.value == RuleValue.string('${operands[1].reference!.kind}/${operands[1].reference!.key}')).firstOrNull;
    return f != null ? PredicateResult.match([EvidenceId(f.factId)]) : PredicateResult.fail;
  }
}

class BinaryLiteralOperator extends OperatorImpl {
  const BinaryLiteralOperator(this._opId, this._predicateId);
  final String _opId, _predicateId;
  @override String get operatorId => _opId;
  @override PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext ctx) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isLiteral) return PredicateResult.fail;
    final f = ctx.snapshot.facts.where((f) => f.subject == operands[0].reference && f.predicateId == _predicateId && f.value == RuleValue.string(operands[1].literal!.value as String)).firstOrNull;
    return f != null ? PredicateResult.match([EvidenceId(f.factId)]) : PredicateResult.fail;
  }
}

class ChuMuOperator extends OperatorImpl {
  const ChuMuOperator();
  @override String get operatorId => ConditionId.chuMu;
  @override PredicateResult evaluate(List<ResolvedOperand> operands, OperatorContext ctx) {
    if (operands.length != 3 || !operands[0].isRef || !operands[1].isRef || !operands[2].isRef) return PredicateResult.fail;
    final ref2 = operands[1].reference!, ref3 = operands[2].reference!;
    final f = ctx.snapshot.facts.where((f) => f.subject == operands[0].reference && f.predicateId == 'relation.chu_mu' && f.value == RuleValue.string('${ref2.kind}/${ref2.key},${ref3.kind}/${ref3.key}')).firstOrNull;
    return f != null ? PredicateResult.match([EvidenceId(f.factId)]) : PredicateResult.fail;
  }
}
