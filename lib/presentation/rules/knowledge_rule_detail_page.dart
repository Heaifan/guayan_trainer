import 'package:flutter/material.dart';
import '../../domain/rules/knowledge/knowledge_rule.dart';
import '../../domain/rules/knowledge/rule_variant.dart';

class KnowledgeRuleDetailPage extends StatelessWidget {
  const KnowledgeRuleDetailPage({super.key, required this.rule});

  final KnowledgeRule rule;

  @override
  Widget build(BuildContext context) {
    final executionCount = rule.variants.fold(
      0,
      (count, variant) => count + variant.executionRules.length,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('规则详情')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(rule.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('系统规则'),
          const SizedBox(height: 20),
          _FactRow(label: '规则变体', value: '${rule.variants.length} 个'),
          _FactRow(label: '版本', value: _versions(rule.variants)),
          const _FactRow(label: '执行范围', value: '六爻'),
          _FactRow(label: '执行规则', value: '$executionCount 条'),
          const SizedBox(height: 16),
          Text('规则变体', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...rule.variants.map((variant) => _VariantSection(variant: variant)),
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('高级信息'),
            children: [
              ListTile(
                title: const Text('KnowledgeRule ID'),
                subtitle: Text(rule.id),
              ),
              ...rule.variants.expand(
                (variant) => [
                  ListTile(
                    title: Text('Variant ID · ${variant.name}'),
                    subtitle: Text(variant.id),
                  ),
                  ...variant.executionRules.map(
                    (ref) => ListTile(
                      dense: true,
                      title: Text(ref.displayName),
                      subtitle: Text(ref.ruleId),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _versions(List<RuleVariant> variants) =>
      variants.map((variant) => variant.version).toSet().join('、');
}

class _VariantSection extends StatelessWidget {
  const _VariantSection({required this.variant});

  final RuleVariant variant;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(variant.name),
        subtitle: Text(
          'v${variant.version} · 执行规则 ${variant.executionRules.length} 条',
        ),
        children: [
          const ListTile(dense: true, title: Text('执行实例（只读）')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: variant.executionRules
                  .map((ref) => Text(ref.displayName))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(width: 88, child: Text(label)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
