import 'package:flutter/material.dart';

/// 规则库（Rule Library）Skeleton。
///
/// 规则是配置能力，不是主导航。
/// 本阶段只展示三类规则的入口卡片，不做 CRUD。
class RuleLibraryPage extends StatelessWidget {
  const RuleLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('规则库')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _RuleEntryCard(
            icon: Icons.tune_rounded,
            title: '自定义规则',
            description: '用户自己创建的象义规则',
          ),
          _RuleEntryCard(
            icon: Icons.folder_copy_rounded,
            title: '规则包',
            description: '按场景组织规则',
          ),
          _RuleEntryCard(
            icon: Icons.verified_rounded,
            title: '系统规则',
            description: '查看系统计算规则',
          ),
        ],
      ),
    );
  }
}

class _RuleEntryCard extends StatelessWidget {
  const _RuleEntryCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Text('后续开放'),
        enabled: false,
      ),
    );
  }
}
