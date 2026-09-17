import 'package:flutter/material.dart';

import '../../../domain/rules/core/rule_definition.dart';
import '../../../domain/rules/library/rule_folder.dart';
import '../../../domain/rules/library/rule_library_index.dart';

class RuleFolderTree extends StatelessWidget {
  const RuleFolderTree({
    super.key,
    required this.index,
    required this.rules,
    required this.onFolderToggle,
    required this.onRuleToggle,
    this.onFolderAction,
    this.onFolderExpanded,
    this.onRuleAction,
  });

  final RuleLibraryIndex index;
  final List<RuleDefinition> rules;
  final void Function(String folderId, bool enabled) onFolderToggle;
  final void Function(RuleDefinition rule, bool enabled) onRuleToggle;
  final void Function(RuleFolder folder, String action)? onFolderAction;
  final void Function(String folderId, bool expanded)? onFolderExpanded;
  final void Function(RuleDefinition rule, String action)? onRuleAction;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
    children: _children(null, 0),
  );

  List<Widget> _children(String? parentId, int depth, [Set<String>? path]) {
    final currentPath = {...?path};
    return [
      for (final folder in index.folders.where((item) => item.parentFolderId == parentId))
        if (!currentPath.contains(folder.folderId)) _folder(folder, depth, currentPath),
    ];
  }

  Widget _folder(RuleFolder folder, int depth, Set<String> path) {
    final nextPath = {...path, folder.folderId};
    final expanded = index.expandedFolderIds.contains(folder.folderId);
    final children = _children(folder.folderId, depth + 1, nextPath);
    final folderRules = rules.where((rule) => index.ruleFolderIds[rule.ruleId.id] == folder.folderId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.fromLTRB(depth * 16.0, 4, 0, 2),
          child: ListTile(
            dense: true,
            leading: Icon(expanded ? Icons.expand_more : Icons.chevron_right),
            title: Text(folder.name),
            subtitle: Text('${index.recursiveRuleCount(folder.folderId)} 条规则'),
            onTap: onFolderExpanded == null
                ? null
                : () => onFolderExpanded!(folder.folderId, !expanded),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: folder.enabled,
                  onChanged: (value) => onFolderToggle(folder.folderId, value),
                ),
                if (onFolderAction != null)
                  PopupMenuButton<String>(
                    onSelected: (action) => onFolderAction!(folder, action),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'child', child: Text('新建子文件夹')),
                      PopupMenuItem(value: 'rename', child: Text('重命名')),
                      PopupMenuItem(value: 'import', child: Text('导入 JSON')),
                      PopupMenuItem(value: 'move', child: Text('移动')),
                      PopupMenuItem(value: 'delete', child: Text('删除')),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (expanded)
          ...folderRules.map((rule) => _rule(rule, depth + 1)),
        if (expanded) ...children,
      ],
    );
  }

  Widget _rule(RuleDefinition rule, int depth) => ListTile(
    contentPadding: EdgeInsets.only(left: depth * 16.0 + 28, right: 8),
    dense: true,
    leading: const Icon(Icons.description_outlined, size: 20),
    title: Text(rule.title),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: rule.enabled,
          onChanged: (value) => onRuleToggle(rule, value),
        ),
        if (onRuleAction != null)
          PopupMenuButton<String>(
            onSelected: (action) => onRuleAction!(rule, action),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'move', child: Text('移动到文件夹')),
              PopupMenuItem(value: 'delete', child: Text('删除规则')),
            ],
          ),
      ],
    ),
  );
}
