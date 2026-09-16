import 'package:flutter/material.dart';
import '../../../domain/rules/ast/rule_expr.dart';
import '../../../domain/rules/ast/rule_operand.dart';

class CompoundExprEditor extends StatelessWidget {
  final RuleExpr expr;
  final ValueChanged<RuleExpr?> onChange;
  final Widget Function(RuleExpr, Function(RuleExpr?)) buildNode;

  const CompoundExprEditor({
    super.key,
    required this.expr,
    required this.onChange,
    required this.buildNode,
  });

  void _onChild(int i, RuleExpr? n, List<RuleExpr> nodes, String type) {
    final next = List.of(nodes);
    if (n == null) {
      next.removeAt(i);
      if (next.isEmpty) return onChange(null);
      if (next.length == 1) return onChange(next.first);
    } else {
      next[i] = n;
    }
    onChange(type == 'ALL' ? AllExpr(next) : AnyExpr(next));
  }

  void _onNotChild(RuleExpr? n) => onChange(n == null ? null : NotExpr(n));

  @override
  Widget build(BuildContext context) {
    if (expr is NotExpr) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('非 (NOT)'),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: buildNode((expr as NotExpr).node, _onNotChild),
          ),
        ],
      );
    }
    final isAll = expr is AllExpr;
    final nodes = isAll ? (expr as AllExpr).nodes : (expr as AnyExpr).nodes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isAll ? '且 (ALL)' : '或 (ANY)'),
        ...nodes.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(left: 16),
            child: buildNode(
              e.value,
              (n) => _onChild(e.key, n, nodes, isAll ? 'ALL' : 'ANY'),
            ),
          ),
        ),
        TextButton(
          onPressed: () => onChange(
            isAll
                ? AllExpr([
                    ...nodes,
                    PredicateExpr(
                      operatorId: 'empty',
                      operands: [BindingRefOperand('A')],
                    ),
                  ])
                : AnyExpr([
                    ...nodes,
                    PredicateExpr(
                      operatorId: 'empty',
                      operands: [BindingRefOperand('A')],
                    ),
                  ]),
          ),
          child: const Text('+ 条件'),
        ),
      ],
    );
  }
}
