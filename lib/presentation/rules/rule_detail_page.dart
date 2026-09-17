import 'package:flutter/material.dart';
import '../../domain/rules/core/rule_definition.dart';
import 'presentation/rule_presentation_mapper.dart';
import 'widgets/rule_dsl_preview.dart';

class RuleDetailPage extends StatelessWidget {
  const RuleDetailPage({super.key, required this.rule});

  final RuleDefinition rule;

  @override
  Widget build(BuildContext context) {
    final display = RulePresentationMapper.map(rule);
    return Scaffold(
      appBar: AppBar(title: const Text('规则详情')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(display.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '${display.originLabel} · ${display.categoryLabel} · v${display.version}',
          ),
          const SizedBox(height: 4),
          Text(display.ruleId, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          _Section(title: '规则说明', child: Text(display.description)),
          _Section(
            title: '规则绑定',
            child: Text(rule.bindings.map((b) => b.name).join('、')),
          ),
          _Section(
            title: '规则条件',
            child: Text(rule.condition.runtimeType.toString()),
          ),
          _Section(
            title: '规则动作',
            child: Text(rule.actions.map((a) => a.runtimeType).join('、')),
          ),
          _Section(
            title: '规则内容（中文 DSL）',
            child: RuleDslPreview(dsl: display.dsl),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
