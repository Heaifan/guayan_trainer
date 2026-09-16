import 'package:flutter/material.dart';
import '../../domain/rules/editor/rule_editor_draft.dart';
import '../../domain/rules/dsl/guayan_dsl_formatter.dart';
import '../../domain/rules/dsl/guayan_rule_body.dart';
import '../../domain/rules/core/rule_id.dart';
import 'widgets/condition_editor.dart';
import 'widgets/binding_editor.dart';
import 'widgets/action_editor.dart';

class RuleEditorForm extends StatelessWidget {
  final RuleEditorDraft draft;
  final VoidCallback onChange;

  const RuleEditorForm({
    super.key,
    required this.draft,
    required this.onChange,
  });

  Widget _btn(BuildContext context, String t, Widget p) => ElevatedButton(
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => p),
    ).then((_) => onChange()),
    child: Text(t),
  );

  @override
  Widget build(BuildContext context) {
    String preview = '未完成';
    try {
      preview = const GuayanDslFormatter().format(
        GuayanRuleBody(
          bindings: draft.bindings,
          condition: draft.condition!,
          actions: draft.actions,
        ),
      );
    } catch (_) {}
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '名称'),
          onChanged: (v) => draft.title = v,
          controller: TextEditingController(text: draft.title),
        ),
        DropdownButton<String>(
          value: draft.namespace.startsWith('topic.')
              ? draft.namespace.substring(6)
              : 'common',
          items: const [
            DropdownMenuItem(value: 'common', child: Text('COMMON')),
            DropdownMenuItem(value: 'exam', child: Text('考试·学业')),
          ],
          onChanged: (v) {
            draft.namespace = v == 'common' ? 'common' : 'topic.$v';
            draft.categoryId = v!;
            onChange();
          },
        ),
        SwitchListTile(
          title: const Text('覆盖系统规则'),
          value: draft.overrideTarget != null,
          onChanged: (v) {
            draft.overrideTarget = v ? RuleId('') : null;
            onChange();
          },
        ),
        if (draft.overrideTarget != null)
          TextField(
            decoration: const InputDecoration(labelText: '覆盖的 System Rule ID'),
            onChanged: (v) => draft.overrideTarget = RuleId(v),
            controller: TextEditingController(text: draft.overrideTarget!.id),
          ),
        Text('预览:\n$preview', style: const TextStyle(color: Colors.blue)),
        _btn(context, '编辑绑定(A)', BindingEditor(draft: draft)),
        _btn(context, '编辑条件', ConditionEditor(draft: draft)),
        _btn(context, '编辑动作', ActionEditor(draft: draft)),
      ],
    );
  }
}
