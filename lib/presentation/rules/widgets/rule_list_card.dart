import 'package:flutter/material.dart';
import '../../../domain/rules/core/rule_definition.dart';
import '../presentation/rule_presentation_mapper.dart';

class RuleListCard extends StatelessWidget {
  const RuleListCard({
    super.key,
    required this.rule,
    required this.enabled,
    required this.onToggle,
    required this.onView,
  });

  final RuleDefinition rule;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final display = RulePresentationMapper.map(rule);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    display.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(display.categoryLabel)),
                const SizedBox(width: 6),
                Text(
                  'v${display.version}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            Text(display.ruleId, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(display.description),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onView, child: const Text('查看')),
                Switch(value: enabled, onChanged: onToggle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
