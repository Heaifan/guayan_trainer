import 'package:flutter/material.dart';
import '../../domain/rules/editor/rule_editor_draft.dart';
import '../../domain/rules/dsl/guayan_dsl_formatter.dart';
import '../../domain/rules/dsl/guayan_rule_body.dart';
import 'widgets/condition_editor.dart';
import 'widgets/binding_editor.dart';
import 'widgets/action_editor.dart';
import 'widgets/rule_editor_action_card.dart';
import 'widgets/rule_dsl_preview.dart';

class RuleEditorForm extends StatelessWidget {
  final RuleEditorDraft draft;
  final VoidCallback onChange;

  const RuleEditorForm({
    super.key,
    required this.draft,
    required this.onChange,
  });

  Widget _btn(
    BuildContext context,
    String t,
    String description,
    IconData icon,
    Widget p,
  ) => RuleEditorActionCard(
    icon: icon,
    title: t,
    description: description,
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => p),
    ).then((_) => onChange()),
  );

  @override
  Widget build(BuildContext context) {
    String preview = '';
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
        TextFormField(
          decoration: const InputDecoration(labelText: '名称'),
          onChanged: (v) => draft.title = v,
          initialValue: draft.title,
        ),
        const SizedBox(height: 12),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('归属'),
          trailing: Text('CUSTOM'),
        ),
        DropdownButtonFormField<String>(
          initialValue: draft.categoryId == 'common'
              ? 'status'
              : draft.categoryId,
          decoration: const InputDecoration(labelText: '分类'),
          items: const [
            DropdownMenuItem(value: 'status', child: Text('状态')),
            DropdownMenuItem(value: 'relation', child: Text('关系')),
            DropdownMenuItem(value: 'image', child: Text('取象')),
          ],
          onChanged: (v) {
            // COMMON 的领域边界仍要求 categoryId=common；展示分类属于
            // presentation 层，不能把 UI 文案写进保存契约。
            draft.categoryId = 'common';
            onChange();
          },
        ),
        const SizedBox(height: 12),
        Text('优先级', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
            const Text('1'),
            IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          ],
        ),
        const SizedBox(height: 12),
        Text('规则预览（中文 DSL）', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        RuleDslPreview(dsl: preview),
        const SizedBox(height: 12),
        _btn(
          context,
          '编辑绑定',
          '设置规则的作用范围与绑定对象',
          Icons.link,
          BindingEditor(draft: draft),
        ),
        _btn(
          context,
          '编辑条件',
          '设置触发规则的条件逻辑',
          Icons.filter_alt_outlined,
          ConditionEditor(draft: draft),
        ),
        _btn(
          context,
          '编辑动作',
          '设置触发后执行的动作与结果',
          Icons.bolt,
          ActionEditor(draft: draft),
        ),
      ],
    );
  }
}
