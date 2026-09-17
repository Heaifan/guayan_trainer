import 'package:flutter/material.dart';
import '../../../domain/rules/editor/rule_editor_draft.dart';
import '../../../domain/rules/ast/rule_binding.dart';
import '../../../domain/rules/ast/binding_selector.dart';

class BindingEditor extends StatefulWidget {
  final RuleEditorDraft draft;
  const BindingEditor({super.key, required this.draft});
  @override
  State<BindingEditor> createState() => _State();
}

class _State extends State<BindingEditor> {
  @override
  void initState() {
    super.initState();
    if (widget.draft.bindings.isEmpty) {
      widget.draft.bindings.add(
        RuleBinding(name: 'A', selector: DirectSelector('line/2')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.draft.bindings[0];
    final sel = b.selector;
    return Scaffold(
      appBar: AppBar(title: const Text('Binding Editor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (sel is RelativeSelector)
            ListTile(
              title: Text('Relative: ${sel.baseBinding} -> ${sel.path} (只读)'),
            ),
          if (sel is DirectSelector)
            DropdownButton<String>(
              value:
                  [
                    'line/1',
                    'line/2',
                    'line/3',
                    'line/4',
                    'line/5',
                    'line/6',
                    'calendar/month',
                    'calendar/day',
                  ].contains(sel.target)
                  ? sel.target
                  : 'line/2',
              items: [
                'line/1',
                'line/2',
                'line/3',
                'line/4',
                'line/5',
                'line/6',
                'calendar/month',
                'calendar/day',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(
                () => widget.draft.bindings[0] = RuleBinding(
                  name: 'A',
                  selector: DirectSelector(v!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
