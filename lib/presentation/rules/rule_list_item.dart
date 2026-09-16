import 'package:flutter/material.dart';
import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/core/rule_origin.dart';

class RuleListItem extends StatelessWidget {
  final RuleDefinition r;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const RuleListItem({
    super.key,
    required this.r,
    required this.onToggle,
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${r.title} (${r.ruleId.id})'),
      subtitle: Text('${r.origin.name} · ${r.categoryId} · ${r.version}'),
      trailing: Switch(value: r.enabled, onChanged: onToggle),
      onTap: () => r.origin == RuleOrigin.CUSTOM ? onEdit() : null,
      onLongPress: () => showModalBottomSheet(
        context: context,
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (r.origin == RuleOrigin.SYSTEM)
              ListTile(
                title: const Text('复制为自定义规则'),
                onTap: () {
                  Navigator.pop(context);
                  onCopy();
                },
              ),
            if (r.origin == RuleOrigin.CUSTOM)
              ListTile(
                title: const Text('删除'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }
}
