import 'package:flutter/material.dart';
import '../../../domain/rules/editor/rule_editor_draft.dart';
import '../../../domain/rules/ast/rule_expr.dart';
import '../../../domain/rules/ast/rule_operand.dart';
import '../../../domain/rules/facts/rule_value.dart';
import 'predicate_editor.dart';
import 'all_expr_editor.dart';

class ConditionEditor extends StatefulWidget {
  final RuleEditorDraft draft;
  const ConditionEditor({super.key, required this.draft});
  @override
  State<ConditionEditor> createState() => _State();
}

class _State extends State<ConditionEditor> {
  @override
  void initState() {
    super.initState();
    if (widget.draft.condition == null) {
      widget.draft.condition = PredicateExpr(
        operatorId: 'relative',
        operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('fuMu')),
        ],
      );
    }
  }

  Widget _buildNode(RuleExpr expr, Function(RuleExpr?) onChange) {
    if (expr is AllExpr)
      return AllExprEditor(
        expr: expr,
        onChange: onChange,
        buildNode: _buildNode,
      );
    if (expr is PredicateExpr)
      return PredicateEditor(expr: expr, onChange: onChange);
    return Text(expr.runtimeType.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Condition Editor')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: widget.draft.condition != null
              ? _buildNode(
                  widget.draft.condition!,
                  (n) => setState(() => widget.draft.condition = n),
                )
              : const Text('Empty'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(
          () => widget.draft.condition = AllExpr(
            widget.draft.condition == null ? [] : [widget.draft.condition!],
          ),
        ),
        child: const Icon(Icons.wrap_text),
      ),
    );
  }
}
