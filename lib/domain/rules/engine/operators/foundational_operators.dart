import '../../../di_zhi.dart';
import '../../../wu_xing.dart';
import '../../facts/fact_snapshot.dart';
import '../../facts/fact_record.dart';
import '../../facts/semantic_ref.dart';
import '../../facts/rule_value.dart';
import '../../evidence/evidence_id.dart';
import '../predicate_result.dart';
import 'operator_impl.dart';

class FactValueOperator extends OperatorImpl {
  const FactValueOperator(this._id, this._predicate);
  final String _id;
  final String _predicate;
  @override
  String get operatorId => _id;

  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isLiteral) {
      return PredicateResult.fail;
    }
    final wanted = operands[1].literal!.value;
    final fact = _fact(
      ctx.snapshot,
      operands[0].reference!,
      _predicate,
      wanted,
    );
    return fact == null
        ? PredicateResult.fail
        : PredicateResult.match([EvidenceId(fact.factId)]);
  }
}

class ElementControlsOperator extends OperatorImpl {
  const ElementControlsOperator(this._id);
  final String _id;
  @override
  String get operatorId => _id;

  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isRef) {
      return PredicateResult.fail;
    }
    final left = _fact(ctx.snapshot, operands[0].reference!, 'element', null);
    final right = _fact(ctx.snapshot, operands[1].reference!, 'element', null);
    if (left == null || right == null) return PredicateResult.fail;
    final a = _element(left.value);
    final b = _element(right.value);
    if (a == null || b == null || a.controls != b) return PredicateResult.fail;
    return PredicateResult.match([
      EvidenceId(left.factId),
      EvidenceId(right.factId),
    ]);
  }
}

class BranchRelationOperator extends OperatorImpl {
  const BranchRelationOperator(this._id, this._matches);
  final String _id;
  final bool Function(DiZhi, DiZhi) _matches;
  @override
  String get operatorId => _id;

  @override
  PredicateResult evaluate(
    List<ResolvedOperand> operands,
    OperatorContext ctx,
  ) {
    if (operands.length != 2 || !operands[0].isRef || !operands[1].isRef) {
      return PredicateResult.fail;
    }
    final left = _fact(ctx.snapshot, operands[0].reference!, 'branch', null);
    final right = _fact(ctx.snapshot, operands[1].reference!, 'branch', null);
    if (left == null || right == null) return PredicateResult.fail;
    final a = _branch(left.value);
    final b = _branch(right.value);
    if (a == null || b == null || !_matches(a, b)) return PredicateResult.fail;
    return PredicateResult.match([
      EvidenceId(left.factId),
      EvidenceId(right.factId),
    ]);
  }
}

FactRecord? _fact(
  FactSnapshot snapshot,
  SemanticRef subject,
  String predicate,
  Object? value,
) {
  for (final fact in snapshot.facts) {
    if (fact.subject == subject &&
        fact.predicateId == predicate &&
        (value == null || fact.value.value == value)) {
      return fact;
    }
  }
  return null;
}

WuXing? _element(RuleValue value) => WuXing.values
    .where((item) => item.label == value.value || item.name == value.value)
    .firstOrNull;
DiZhi? _branch(RuleValue value) => DiZhi.tryFromLabel(value.value.toString());

bool _pair(DiZhi a, DiZhi b, List<List<DiZhi>> pairs) => pairs.any(
  (pair) => (pair[0] == a && pair[1] == b) || (pair[0] == b && pair[1] == a),
);

bool branchClashes(DiZhi a, DiZhi b) => a.chong == b;
bool branchCombines(DiZhi a, DiZhi b) => a.he == b;
bool branchHarms(DiZhi a, DiZhi b) => _pair(a, b, const [
  [DiZhi.zi, DiZhi.wei],
  [DiZhi.chou, DiZhi.wu],
  [DiZhi.yin, DiZhi.si],
  [DiZhi.mao, DiZhi.chen],
  [DiZhi.shen, DiZhi.hai],
  [DiZhi.you, DiZhi.xu],
]);
bool branchBreaks(DiZhi a, DiZhi b) => _pair(a, b, const [
  [DiZhi.zi, DiZhi.you],
  [DiZhi.chou, DiZhi.chen],
  [DiZhi.yin, DiZhi.hai],
  [DiZhi.mao, DiZhi.wu],
  [DiZhi.si, DiZhi.shen],
  [DiZhi.wei, DiZhi.xu],
]);
bool branchPunishes(DiZhi a, DiZhi b) =>
    a == b && const {DiZhi.chen, DiZhi.wu, DiZhi.you, DiZhi.hai}.contains(a) ||
    _pair(a, b, const [
      [DiZhi.yin, DiZhi.si],
      [DiZhi.si, DiZhi.shen],
      [DiZhi.yin, DiZhi.shen],
      [DiZhi.chou, DiZhi.xu],
      [DiZhi.xu, DiZhi.wei],
      [DiZhi.chou, DiZhi.wei],
      [DiZhi.zi, DiZhi.mao],
    ]);
