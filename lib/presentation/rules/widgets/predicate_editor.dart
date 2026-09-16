import 'package:flutter/material.dart';
import '../../../domain/rules/ast/rule_expr.dart';
import '../../../domain/rules/ast/rule_operand.dart';
import '../../../domain/rules/facts/rule_value.dart';
import '../../../domain/rules/vocabulary/condition_registry.dart';

class PredicateEditor extends StatelessWidget {
  final PredicateExpr expr;
  final ValueChanged<RuleExpr?> onChange;

  const PredicateEditor({
    super.key,
    required this.expr,
    required this.onChange,
  });

  void _chgOp(String? v) {
    if (v == null) return;
    final def = CanonicalConditionRegistry.getDefinition(v);
    if (def == null) return;
    final ops = <RuleOperand>[BindingRefOperand('A')];
    for (int i = 1; i < def.operandCount; i++) {
      ops.add(LiteralOperand(RuleValue.string('')));
    }
    onChange(PredicateExpr(operatorId: v, operands: ops));
  }

  Widget _valFld(int idx) => Expanded(
    child: TextField(
      controller: TextEditingController(
        text: expr.operands.length > idx
            ? (expr.operands[idx] as LiteralOperand).value.value.toString()
            : '',
      ),
      onChanged: (v) {
        final ops = List.of(expr.operands);
        if (ops.length <= idx) {
          while (ops.length <= idx)
            ops.add(LiteralOperand(RuleValue.string('')));
        }
        ops[idx] = LiteralOperand(RuleValue.string(v));
        onChange(PredicateExpr(operatorId: expr.operatorId, operands: ops));
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final def = CanonicalConditionRegistry.getDefinition(expr.operatorId);
    return Row(
      children: [
        DropdownButton<String>(
          value: expr.operatorId,
          items: CanonicalConditionRegistry.allConditions
              .map(
                (e) => DropdownMenuItem(
                  value: e.operatorId,
                  child: Text(e.displayName),
                ),
              )
              .toList(),
          onChanged: _chgOp,
        ),
        if (def != null && def.operandCount > 1) _valFld(1),
        if (def != null && def.operandCount > 2) _valFld(2),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => onChange(null),
        ),
      ],
    );
  }
}
