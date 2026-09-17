import 'package:flutter/material.dart';
import '../../../domain/rules/editor/rule_editor_draft.dart';
import '../../../domain/rules/ast/rule_action.dart';
import '../../../domain/rules/facts/rule_value.dart';

class ActionEditor extends StatefulWidget {
  final RuleEditorDraft draft;
  const ActionEditor({super.key, required this.draft});
  @override
  State<ActionEditor> createState() => _State();
}

class _State extends State<ActionEditor> {
  void _add(RuleAction a) => setState(() => widget.draft.actions.add(a));
  void _rm(int idx) => setState(() => widget.draft.actions.removeAt(idx));

  Widget _editDialog(RuleAction a, Function(RuleAction) onSave) {
    if (a is TagAction) {
      final c1 = TextEditingController(text: a.categoryId);
      final c2 = TextEditingController(text: a.tagId);
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c1,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: c2,
              decoration: const InputDecoration(labelText: 'TagId'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => onSave(
              TagAction(
                categoryId: c1.text,
                tagId: c2.text,
                subjectBinding: 'A',
              ),
            ),
            child: const Text('保存'),
          ),
        ],
      );
    }
    if (a is DeriveAction) {
      final c = TextEditingController(text: a.factKey);
      return AlertDialog(
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'FactKey'),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                onSave(DeriveAction(targetBinding: 'A', factKey: c.text)),
            child: const Text('保存'),
          ),
        ],
      );
    }
    if (a is StructureAction) {
      final c = TextEditingController(text: a.structureId);
      return AlertDialog(
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'StructureId'),
        ),
        actions: [
          TextButton(
            onPressed: () => onSave(
              StructureAction(structureId: c.text, memberBindings: ['A']),
            ),
            child: const Text('保存'),
          ),
        ],
      );
    }
    if (a is RecordAction) {
      final c = TextEditingController(text: a.recordType);
      return AlertDialog(
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'RecordType'),
        ),
        actions: [
          TextButton(
            onPressed: () => onSave(
              RecordAction(
                recordType: c.text,
                content: {'val': RuleValue.string('v')},
              ),
            ),
            child: const Text('保存'),
          ),
        ],
      );
    }
    return const AlertDialog(content: Text('不可编辑'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Action Editor')),
      body: ListView.builder(
        itemCount: widget.draft.actions.length,
        itemBuilder: (c, i) {
          final a = widget.draft.actions[i];
          return ListTile(
            title: Text(a.runtimeType.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _rm(i),
            ),
            onTap: () => showDialog(
              context: context,
              builder: (_) => _editDialog(a, (na) {
                setState(() => widget.draft.actions[i] = na);
                Navigator.pop(context);
              }),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => _add(
                TagAction(
                  categoryId: 'exam',
                  tagId: 'tag',
                  subjectBinding: 'A',
                ),
              ),
              child: const Text('+ 取象(Tag)'),
            ),
            TextButton(
              onPressed: () =>
                  _add(DeriveAction(targetBinding: 'A', factKey: 'fk')),
              child: const Text('+ 得(Derive)'),
            ),
            TextButton(
              onPressed: () => _add(
                StructureAction(structureId: 'sid', memberBindings: ['A']),
              ),
              child: const Text('+ 成局(Structure)'),
            ),
            TextButton(
              onPressed: () =>
                  _add(RecordAction(recordType: 'rt', content: {})),
              child: const Text('+ 记(Record)'),
            ),
          ],
        ),
      ),
    );
  }
}
