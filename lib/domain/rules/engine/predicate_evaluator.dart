library;

import '../ast/rule_expr.dart';
import '../ast/rule_operand.dart';
import '../facts/fact_snapshot.dart';
import 'binding_resolver.dart';
import 'operators/operator_impl.dart';
import 'operators/operator_registry.dart';

import 'predicate_result.dart';
import '../evidence/evidence_id.dart';
import '../objects/dynamic_object_resolver.dart';

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
      for (final child in expr.nodes) {
        final result = evaluate(child, bindingContext, snapshot);
        if (!result.matched) {
          return PredicateResult.fail;
        }
        allSupports.addAll(result.supports);
      }
      return PredicateResult.match(allSupports);
    } else if (expr is AnyExpr) {
      if (expr.nodes.isEmpty) return PredicateResult.fail;
      bool matched = false;
      final anySupports = <EvidenceId>[];

      for (final child in expr.nodes) {
        final result = evaluate(child, bindingContext, snapshot);
        if (result.matched) {
          matched = true;
          anySupports.addAll(result.supports);
        }
      }
      if (matched) {
        return PredicateResult.match(anySupports);
      }
      return PredicateResult.fail;
    } else if (expr is NotExpr) {
      final childResult = evaluate(expr.node, bindingContext, snapshot);
      if (!childResult.matched) {
        return PredicateResult.match(
          const [],
        ); // Negative provenance, no evidence
      }
      return PredicateResult.fail;
    } else if (expr is QuantifiedExpr) {
      final resolution = const DynamicObjectResolver().resolve(
        expr.selector,
        snapshot,
      );
      final results = <PredicateResult>[];
      for (final candidate in resolution.candidates) {
        final scoped = BindingContext(
          Map.of(bindingContext.allBindings)..[expr.bindingName] = candidate,
        );
        results.add(evaluate(expr.node, scoped, snapshot));
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
      return matched ? PredicateResult.match(const []) : PredicateResult.fail;
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
    return operatorImpl.evaluate(resolvedOperands, context);
  }
}
