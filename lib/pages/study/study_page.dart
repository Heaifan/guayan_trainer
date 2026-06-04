import 'package:flutter/material.dart';

import '../../theme/wuxing_colors.dart';
import 'bagua_study_page.dart';
import 'wuxing_study_menu_page.dart';
import 'dizhi_study_page.dart';
import 'relation_study_page.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学习'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            context,
            icon: Icons.auto_awesome_mosaic_outlined,
            label: '五行模块',
            subtitle: '认识颜色、意象、生克与关系',
            color: WuxingColors.getColor('木'),
            bgColor: WuxingColors.getSoftColor('木'),
            page: const WuxingStudyMenuPage(),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: Icons.token_outlined,
            label: '八卦模块',
            subtitle: '总览卦象、五行、方位、人体与病象',
            color: const Color(0xFF2B4A3F),
            bgColor: const Color(0xFFE9F0E6),
            page: const BaguaStudyPage(),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: Icons.radio_button_checked,
            label: '十二地支',
            subtitle: '用方位记地支，用颜色记五行',
            color: WuxingColors.getColor('土'),
            bgColor: WuxingColors.getSoftColor('土'),
            page: const DizhiStudyPage(),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: Icons.compare_arrows,
            label: '六冲六合',
            subtitle: '用对手和朋友记冲合关系',
            color: WuxingColors.getColor('火'),
            bgColor: WuxingColors.getSoftColor('火'),
            page: const RelationStudyPage(),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required Widget page,
  }) {
    return Card(
      color: bgColor,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w800, color: color),
        ),
        subtitle: Text(subtitle, style: const TextStyle(height: 1.4)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
