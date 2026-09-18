library;

import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';
import '../facts/fact_snapshot.dart';
import '../facts/semantic_ref.dart';
import 'binding_resolver.dart';
import 'operators/operator_impl.dart';
import 'operators/operator_registry.dart';

import 'predicate_result.dart';
import '../evidence/evidence_id.dart';
import '../objects/dynamic_object_resolver.dart';
import 'rule_trace.dart';
import 'trace_labels.dart';

/// 表达式求值异常
class EvaluationException implements Exception {
  final String message;
  EvaluationException(this.message);

  @override
  String toString() => 'EvaluationException: $message';
}

/// 执行 AST 条件求值
class PredicateEvaluator {
  const PredicateEvaluator(this.registry);

  final OperatorRegistry registry;

  PredicateResult evaluate(
    RuleExpr expr,
    BindingContext bindingContext,
    FactSnapshot snapshot,
  ) {
    if (expr is AllExpr) {
      final allSupports = <EvidenceId>[];
      final traces = <RuleTrace>[];
      var matchedBindings = <Map<String, SemanticRef>>[
        bindingContext.allBindings,
      ];
      for (final child in expr.nodes) {
        final result = evaluate(child, bindingContext, snapshot);
        if (result.trace != null) traces.add(result.trace!);
        if (!result.matched) {
          return PredicateResult(
            matched: false,
            trace: RuleTrace(
              kind: RuleTraceKind.all,
              label: 'ALL',
              status: RuleTraceStatus.notMatched,
              children: traces,
            ),
          );
        }
        allSupports.addAll(result.supports);
        if (result.matchedBindings.isNotEmpty) {
          matchedBindings = [
            for (final left in matchedBindings)
              for (final right in result.matchedBindings)
                {...left, ...right},
          ];
        }
      }
      return PredicateResult(
        matched: true,
        supports: allSupports,
        matchedBindings: matchedBindings,
        trace: RuleTrace(
          kind: RuleTraceKind.all,
          label: 'ALL',
          status: RuleTraceStatus.matched,
          children: traces,
        ),
      );
    } else if (expr is AnyExpr) {
      if (expr.nodes.isEmpty) {
        return PredicateResult(
          matched: false,
          trace: const RuleTrace(
            kind: RuleTraceKind.any,
            label: 'ANY',
            status: RuleTraceStatus.notMatched,
          ),
        );
      }
      bool matched = false;
      final anySupports = <EvidenceId>[];
      final traces = <RuleTrace>[];
      final matchedBindings = <Map<String, SemanticRef>>[];

      for (final child in expr.nodes) {
        final result = evaluate(child, bindingContext, snapshot);
        if (result.trace != null) traces.add(result.trace!);
        if (result.matched) {
          matched = true;
          anySupports.addAll(result.supports);
          matchedBindings.addAll(result.matchedBindings.isEmpty
              ? [bindingContext.allBindings]
              : result.matchedBindings);
        }
      }
      if (matched) {
        return PredicateResult(
          matched: true,
          supports: anySupports,
          matchedBindings: matchedBindings,
          trace: RuleTrace(
            kind: RuleTraceKind.any,
            label: 'ANY',
            status: RuleTraceStatus.matched,
            children: traces,
          ),
        );
      }
      return PredicateResult(
        matched: false,
        trace: RuleTrace(
          kind: RuleTraceKind.any,
          label: 'ANY',
          status: RuleTraceStatus.notMatched,
          children: traces,
        ),
      );
    } else if (expr is NotExpr) {
      final childResult = evaluate(expr.node, bindingContext, snapshot);
      if (!childResult.matched) {
        return PredicateResult(
          matched: true,
          matchedBindings: [bindingContext.allBindings],
          trace: RuleTrace(
            kind: RuleTraceKind.not,
            label: 'NOT',
            status: RuleTraceStatus.matched,
            children: [if (childResult.trace != null) childResult.trace!],
          ),
        );
      }
      return PredicateResult(
        matched: false,
        trace: RuleTrace(
          kind: RuleTraceKind.not,
          label: 'NOT',
          status: RuleTraceStatus.notMatched,
          children: [if (childResult.trace != null) childResult.trace!],
        ),
      );
    } else if (expr is QuantifiedExpr) {
      final resolution = const DynamicObjectResolver().resolve(
        expr.selector,
        snapshot,
      );
      final results = <PredicateResult>[];
      final matchedBindings = <Map<String, SemanticRef>>[];
      final quantifiedSupports = <EvidenceId>[];
      final candidateTraces = <RuleTrace>[];
      for (final candidate in resolution.candidates) {
        final scoped = BindingContext(
          Map.of(bindingContext.allBindings)..[expr.bindingName] = candidate,
        );
        for (final name in bindingContext.emptyBindingNames) {
          scoped.addEmpty(name);
        }
        final result = evaluate(expr.node, scoped, snapshot);
        results.add(result);
        candidateTraces.add(RuleTrace(
          kind: RuleTraceKind.binding,
          label: '${semanticRefLabel(candidate)} ${expr.bindingName}',
          status: result.matched
              ? RuleTraceStatus.matched
              : RuleTraceStatus.notMatched,
          children: [if (result.trace != null) result.trace!],
          resolvedObjects: [candidate],
        ));
        if (result.matched) matchedBindings.add(scoped.allBindings);
        if (result.matched) quantifiedSupports.addAll(result.supports);
      }
      final matches = results.where((result) => result.matched).length;
      final required = expr.count;
      final matched = switch (expr.kind) {
        QuantifierKind.any => matches > 0,
        QuantifierKind.all => results.isNotEmpty && matches == results.length,
        QuantifierKind.none => matches == 0,
        QuantifierKind.atLeast => matches >= required,
        QuantifierKind.exactly => matches == required,
      };
      return PredicateResult(
        matched: matched,
        supports: quantifiedSupports,
        matchedBindings: matchedBindings,
        trace: RuleTrace(
          kind: RuleTraceKind.quantified,
          label: '${_quantifierLabel(expr.kind)} ${expr.bindingName} · '
              '${resolution.candidates.length} 个候选 · $matches 个命中',
          status: matched
              ? RuleTraceStatus.matched
              : RuleTraceStatus.notMatched,
          children: candidateTraces,
          resolvedObjects: resolution.candidates,
        ),
      );
    } else if (expr is PredicateExpr) {
      return _evaluatePredicate(expr, bindingContext, snapshot);
    }

    throw EvaluationException('Unsupported RuleExpr type: ${expr.runtimeType}');
  }

  PredicateResult _evaluatePredicate(
    PredicateExpr expr,
    BindingContext bindingContext,
    FactSnapshot snapshot,
  ) {
    final operatorImpl = registry.getOperator(expr.operatorId);
    if (operatorImpl == null) {
      throw EvaluationException(
        'Operator implementation not found: ${expr.operatorId}',
      );
    }

    final resolvedOperands = <ResolvedOperand>[];
    for (final op in expr.operands) {
      if (op is BindingRefOperand) {
        final ref = bindingContext.get(op.bindingName);
        if (ref == null) {
          if (bindingContext.isEmpty(op.bindingName)) {
            return PredicateResult(
              matched: false,
              trace: RuleTrace(
                kind: RuleTraceKind.predicate,
                label: expr.operatorId,
                status: RuleTraceStatus.notMatched,
                reason: 'NO_MATCH',
              ),
            );
          }
          if (!bindingContext.contains(op.bindingName)) {
            throw EvaluationException(
              'Unresolved binding reference in predicate: ${op.bindingName}',
            );
          }
          throw EvaluationException(
            'Unresolved binding reference in predicate: ${op.bindingName}',
          );
        }
        resolvedOperands.add(ResolvedOperand.ref(ref));
      } else if (op is LiteralOperand) {
        resolvedOperands.add(ResolvedOperand.literal(op.value));
      } else {
        throw EvaluationException(
          'Unsupported operand type: ${op.runtimeType}',
        );
      }
    }

    final context = OperatorContext(
      snapshot: snapshot,
      bindingContext: bindingContext,
    );
    final result = operatorImpl.evaluate(resolvedOperands, context);
    final actual = _actualValue(expr.operatorId, resolvedOperands, snapshot);
    final references = [
      for (final operand in resolvedOperands)
        if (operand.reference != null) operand.reference!,
    ];
    final literals = [
      for (final operand in resolvedOperands)
        if (operand.literal != null) operand.literal!.value,
    ];
    return PredicateResult(
      matched: result.matched,
      supports: result.supports,
      matchedBindings: result.matched
          ? [bindingContext.allBindings]
          : result.matchedBindings,
      trace: RuleTrace(
        kind: RuleTraceKind.predicate,
        label: predicateLabel(expr.operatorId, references, literals, actual),
        operatorId: expr.operatorId,
        status: result.matched
            ? RuleTraceStatus.matched
            : RuleTraceStatus.notMatched,
        expected: resolvedOperands.length > 1
            ? resolvedOperands[1].literal?.value
            : null,
        actual: actual,
        resolvedObjects: [
          ...references,
        ],
      ),
    );
  }

  Object? _actualValue(
    String operatorId,
    List<ResolvedOperand> operands,
    FactSnapshot snapshot,
  ) {
    if (operands.isEmpty || operands.first.reference == null) return null;
    if (operatorId == 'branch_clashes' && operands.length > 1 &&
        operands[1].reference != null) {
      return [
        _factValue(operatorId, operands.first.reference!, snapshot),
        _factValue(operatorId, operands[1].reference!, snapshot),
      ];
    }
    final predicate = switch (operatorId) {
      'branch_is' => 'branch',
      'spirit' => 'spirit',
      'element_is' => 'element',
      'relative_is' => 'relative',
      'stem_is' => 'stem',
      _ => null,
    };
    if (predicate == null) return null;
    return snapshot.facts
        .where((fact) =>
            fact.subject == operands.first.reference &&
            fact.predicateId == predicate)
        .map((fact) => fact.value.value)
        .firstOrNull;
  }

  Object? _factValue(
    String operatorId,
    SemanticRef ref,
    FactSnapshot snapshot,
  ) {
    final predicate = operatorId == 'branch_clashes' ? 'branch' : operatorId;
    return snapshot.facts
        .where((fact) => fact.subject == ref && fact.predicateId == predicate)
        .map((fact) => fact.value.value)
        .firstOrNull;
  }

  String _quantifierLabel(QuantifierKind kind) => switch (kind) {
        QuantifierKind.any => '任一爻',
        QuantifierKind.all => '全部爻',
        QuantifierKind.none => '不存在爻',
        QuantifierKind.atLeast => '至少',
        QuantifierKind.exactly => '恰好',
      };
}
