import 'package:flutter/material.dart';
import '../../../domain/rules/editor/rule_editor_draft.dart';
import '../../../domain/rules/ast/rule_action.dart';

class ActionEditor extends StatefulWidget {
  final RuleEditorDraft draft;
  const ActionEditor({super.key, required this.draft});
  @override
  State<ActionEditor> createState() => _State();
}

class _State extends State<ActionEditor> {
  void _addTag() {
    setState(() {
      widget.draft.actions.add(
        TagAction(categoryId: 'exam', tagId: 'custom_tag', subjectBinding: 'A'),
      );
    });
  }

  void _remove(int idx) {
    setState(() => widget.draft.actions.removeAt(idx));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Action Editor')),
      body: ListView.builder(
        itemCount: widget.draft.actions.length,
        itemBuilder: (c, i) {
          final a = widget.draft.actions[i];
          if (a is TagAction) {
            return ListTile(
              title: Text('取象: A -> ${a.categoryId}:${a.tagId}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _remove(i),
              ),
              onTap: () {
                final catCtrl = TextEditingController(text: a.categoryId);
                final tagCtrl = TextEditingController(text: a.tagId);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: catCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                        ),
                        TextField(
                          controller: tagCtrl,
                          decoration: const InputDecoration(labelText: 'Tag'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(
                            () => widget.draft.actions[i] = TagAction(
                              categoryId: catCtrl.text,
                              tagId: tagCtrl.text,
                              subjectBinding: 'A',
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return ListTile(
            title: Text(a.runtimeType.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _remove(i),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTag,
        child: const Icon(Icons.add),
      ),
    );
  }
}
