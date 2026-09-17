import 'package:flutter/material.dart';
import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/core/rule_origin.dart';
import '../../domain/rules/editor/custom_rule_service.dart';
import 'presentation/rule_presentation_mapper.dart';
import 'rule_detail_page.dart';
import 'widgets/rule_category_filter.dart';
import 'widgets/rule_list_card.dart';
import 'widgets/rule_search_bar.dart';

class SystemRuleListPage extends StatefulWidget {
  const SystemRuleListPage({
    super.key,
    required this.service,
    required this.systemRules,
  });

  final CustomRuleService service;
  final List<RuleDefinition> systemRules;

  @override
  State<SystemRuleListPage> createState() => _SystemRuleListPageState();
}

class _SystemRuleListPageState extends State<SystemRuleListPage> {
  String _query = '';
  String _category = '全部';

  List<RuleDefinition> get _rules {
    final query = _query.trim().toLowerCase();
    return widget.systemRules.where((rule) {
      if (rule.origin != RuleOrigin.SYSTEM) return false;
      final display = RulePresentationMapper.map(rule);
      final matchesCategory =
          _category == '全部' ||
          (_category == '常用'
              ? rule.enabled && display.categoryLabel != '其他'
              : display.categoryLabel == _category);
      final matchesQuery =
          query.isEmpty ||
          display.title.toLowerCase().contains(query) ||
          display.ruleId.toLowerCase().contains(query) ||
          display.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _toggle(RuleDefinition rule, bool enabled) async {
    await widget.service.governance.setSystemRuleEnabled(rule.ruleId, enabled);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('系统规则')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('内置的基础规则，支持按分类浏览', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          RuleSearchBar(
            hintText: '搜索规则名称或编号',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          RuleCategoryFilter(
            value: _category,
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          Text('共 ${_rules.length} 条规则'),
          const SizedBox(height: 8),
          ..._rules.map(
            (rule) => RuleListCard(
              rule: rule,
              enabled: !widget.service.governance.isSystemRuleDisabled(
                rule.ruleId,
              ),
              onToggle: (value) => _toggle(rule, value),
              onView: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RuleDetailPage(rule: rule)),
              ),
            ),
          ),
          if (_rules.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('没有匹配的规则')),
            ),
        ],
      ),
    );
  }
}
