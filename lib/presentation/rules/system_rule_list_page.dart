import 'package:flutter/material.dart';
import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/editor/custom_rule_service.dart';
import '../../domain/rules/knowledge/knowledge_rule.dart';
import '../../domain/rules/knowledge/system_knowledge_rule_catalog.dart';
import 'knowledge_rule_detail_page.dart';
import 'presentation/knowledge_rule_display_model.dart';
import 'presentation/knowledge_rule_presentation_mapper.dart';
import 'rule_center_page.dart';
import 'widgets/rule_search_bar.dart';

class SystemRuleListPage extends StatefulWidget {
  const SystemRuleListPage({
    super.key,
    required this.service,
    required this.systemRules,
    this.knowledgeRules,
  });

  final CustomRuleService service;
  final List<RuleDefinition> systemRules;
  final List<KnowledgeRule>? knowledgeRules;

  @override
  State<SystemRuleListPage> createState() => _SystemRuleListPageState();
}

class _SystemRuleListPageState extends State<SystemRuleListPage> {
  String _query = '';

  List<KnowledgeRuleDisplayModel> get _models =>
      KnowledgeRulePresentationMapper.search(
        KnowledgeRulePresentationMapper.mapAll(
          widget.knowledgeRules ?? SystemKnowledgeRuleCatalog.rules,
        ),
        _query,
      );

  Map<String, List<KnowledgeRuleDisplayModel>> get _groups {
    final groups = <String, List<KnowledgeRuleDisplayModel>>{};
    for (final model in _models) {
      for (final variantName in model.variantNames) {
        groups.putIfAbsent(variantName, () => []).add(model);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('规则库')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('基于真实知识规则目录，按规则变体浏览'),
          const SizedBox(height: 16),
          RuleSearchBar(
            hintText: '搜索规则名称、变体或 ID',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          _ScopeSwitcher(onCustomRules: _openCustomRules),
          const SizedBox(height: 16),
          Text('共 ${_models.length} 个知识规则'),
          const SizedBox(height: 8),
          ..._groups.entries.expand(
            (entry) => [
              _VariantHeading(name: entry.key),
              ...entry.value.map(
                (model) => _KnowledgeRuleCard(
                  model: model,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KnowledgeRuleDetailPage(rule: model.rule),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_models.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('没有匹配的知识规则')),
            ),
        ],
      ),
    );
  }

  void _openCustomRules() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RuleCenterPage(
          service: widget.service,
          systemRules: widget.systemRules,
        ),
      ),
    );
  }
}

class _ScopeSwitcher extends StatelessWidget {
  const _ScopeSwitcher({required this.onCustomRules});

  final VoidCallback onCustomRules;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    children: [
      const ChoiceChip(label: Text('全部'), selected: true),
      const ChoiceChip(label: Text('系统规则'), selected: false),
      ChoiceChip(
        label: const Text('自定义规则'),
        selected: false,
        onSelected: (_) => onCustomRules(),
      ),
    ],
  );
}

class _VariantHeading extends StatelessWidget {
  const _VariantHeading({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Text(name, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _KnowledgeRuleCard extends StatelessWidget {
  const _KnowledgeRuleCard({required this.model, required this.onTap});

  final KnowledgeRuleDisplayModel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(model.name),
      subtitle: Text(
        '${model.variantNames.join('、')} · 执行规则 ${model.executionRuleCount} 条',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
