import 'package:flutter/material.dart';
import '../../../domain/rules/editor/rule_editor_draft.dart';
import '../../../domain/rules/ast/rule_expr.dart';
import '../../../domain/rules/ast/rule_operand.dart';
import 'predicate_editor.dart';
import 'compound_expr_editor.dart';

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
    widget.draft.condition ??= PredicateExpr(
      operatorId: 'empty',
      operands: [BindingRefOperand('A')],
    );
  }

  Widget _buildNode(RuleExpr expr, Function(RuleExpr?) onChange) {
    if (expr is AllExpr || expr is AnyExpr || expr is NotExpr) {
      return CompoundExprEditor(
        expr: expr,
        onChange: onChange,
        buildNode: _buildNode,
      );
    }
    if (expr is PredicateExpr) {
      return PredicateEditor(expr: expr, onChange: onChange);
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('条件编辑器')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: widget.draft.condition != null
              ? _buildNode(
                  widget.draft.condition!,
                  (n) => setState(() => widget.draft.condition = n),
                )
              : const Text('无条件'),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => setState(
                () => widget.draft.condition = AllExpr(
                  widget.draft.condition == null
                      ? []
                      : [widget.draft.condition!],
                ),
              ),
              child: const Text('+ 且组'),
            ),
            TextButton(
              onPressed: () => setState(
                () => widget.draft.condition = AnyExpr(
                  widget.draft.condition == null
                      ? []
                      : [widget.draft.condition!],
                ),
              ),
              child: const Text('+ 或组'),
            ),
            TextButton(
              onPressed: () => setState(
                () => widget.draft.condition = widget.draft.condition == null
                    ? null
                    : NotExpr(widget.draft.condition!),
              ),
              child: const Text('+ 非'),
            ),
          ],
        ),
      ),
    );
  }
}
