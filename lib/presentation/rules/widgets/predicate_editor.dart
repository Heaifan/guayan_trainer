import 'package:flutter/material.dart';
import '../../../domain/rules/ast/rule_expr.dart';
import '../../../domain/rules/ast/rule_operand.dart';
import '../../../domain/rules/facts/rule_value.dart';

const _ops = [
  'relative',
  'spirit',
  'generate',
  'empty',
  'nayin_is',
  'xun_kong',
  'yue_po',
  'ri_po',
  'in_tomb',
  'ru_mu',
  'chong_mu',
  'chu_mu',
  'has_tag',
];

class PredicateEditor extends StatelessWidget {
  final PredicateExpr expr;
  final ValueChanged<RuleExpr?> onChange;
  const PredicateEditor({
    super.key,
    required this.expr,
    required this.onChange,
  });
  void _chgOp(String? v) {
    if (v == 'has_tag') {
      onChange(
        PredicateExpr(
          operatorId: 'has_tag',
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('common')),
            LiteralOperand(RuleValue.string('tag')),
          ],
        ),
      );
    } else {
      onChange(
        PredicateExpr(
          operatorId: v!,
          operands: [
            BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('')),
          ],
        ),
      );
    }
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
        ops[idx] = LiteralOperand(RuleValue.string(v));
        onChange(PredicateExpr(operatorId: expr.operatorId, operands: ops));
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    final op = expr.operatorId;
    final noVal = [
      'empty',
      'xun_kong',
      'yue_po',
      'ri_po',
      'in_tomb',
    ].contains(op);
    return Row(
      children: [
        DropdownButton<String>(
          value: op,
          items: _ops
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: _chgOp,
        ),
        if (!noVal && op != 'has_tag') _valFld(1),
        if (op == 'has_tag') _valFld(2),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => onChange(null),
        ),
      ],
    );
  }
}
