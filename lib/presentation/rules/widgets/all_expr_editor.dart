import 'package:flutter/material.dart';
import '../../../domain/rules/ast/rule_expr.dart';
import '../../../domain/rules/ast/rule_operand.dart';

class AllExprEditor extends StatelessWidget {
  final AllExpr expr;
  final ValueChanged<RuleExpr?> onChange;
  final Widget Function(RuleExpr, Function(RuleExpr?)) buildNode;

  const AllExprEditor({
    super.key,
    required this.expr,
    required this.onChange,
    required this.buildNode,
  });

  void _onChildChange(int i, RuleExpr? n) {
    if (n == null) {
      final next = List.of(expr.nodes)..removeAt(i);
      onChange(
        next.length == 1 ? next.first : (next.isEmpty ? null : AllExpr(next)),
      );
    } else {
      final next = List.of(expr.nodes);
      next[i] = n;
      onChange(AllExpr(next));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('且 (ALL)'),
        ...expr.nodes.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(left: 16),
            child: buildNode(e.value, (n) => _onChildChange(e.key, n)),
          ),
        ),
        TextButton(
          onPressed: () => onChange(
            AllExpr([
              ...expr.nodes,
              PredicateExpr(
                operatorId: 'empty',
                operands: [BindingRefOperand('A')],
              ),
            ]),
          ),
          child: const Text('+ 添加条件'),
        ),
      ],
    );
  }
}
