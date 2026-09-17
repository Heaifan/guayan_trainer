import 'package:flutter/material.dart';

class RuleDslPreview extends StatelessWidget {
  const RuleDslPreview({super.key, required this.dsl});

  final String dsl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SelectableText(dsl.isEmpty ? '尚未设置规则条件' : dsl),
    );
  }
}
