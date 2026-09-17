import 'package:flutter/material.dart';
import 'rule_center_page_loader.dart';
import 'widgets/rule_entry_card.dart';
import 'widgets/rule_search_bar.dart';

class RuleLibraryPage extends StatefulWidget {
  const RuleLibraryPage({super.key});

  @override
  State<RuleLibraryPage> createState() => _RuleLibraryPageState();
}

class _RuleLibraryPageState extends State<RuleLibraryPage> {
  String _query = '';
  final List<String> _recent = ['旬空', '月破'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('规则库'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: RuleSearchBar(
              hintText: '搜索规则、规则包或关键词',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RuleEntryCard(
            icon: Icons.settings_rounded,
            title: '系统规则',
            description: '查看内置规则与说明',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RuleCenterPageLoader()),
            ),
          ),
          RuleEntryCard(
            icon: Icons.folder_copy_rounded,
            title: '规则包',
            description: '按主题组合规则',
            onTap: () {},
          ),
          RuleEntryCard(
            icon: Icons.add_rounded,
            title: '自定义规则',
            description: '创建与管理个人规则',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const RuleCenterPageLoader(openCustomRules: true),
              ),
            ),
          ),
          if (_query.isEmpty) ...[
            const SizedBox(height: 12),
            Text('最近使用', style: Theme.of(context).textTheme.titleMedium),
            ..._recent.map(
              (item) => ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(item),
                subtitle: const Text('系统规则'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('正在搜索：$_query'),
            ),
        ],
      ),
    );
  }
}
