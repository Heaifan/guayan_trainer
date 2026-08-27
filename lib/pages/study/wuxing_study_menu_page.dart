import 'package:flutter/material.dart';

import '../../theme/wuxing_colors.dart';
import '../practice/practice_setup_page.dart';
import 'wuxing_color_page.dart';
import 'wuxing_imagery_page.dart';
import 'wuxing_generate_page.dart';
import 'wuxing_control_page.dart';
import 'wuxing_center_page.dart';

class WuxingStudyMenuPage extends StatelessWidget {
  const WuxingStudyMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('五行模块')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _introCard(),
          const SizedBox(height: 16),
          _menuCard(
            context,
            index: '1',
            title: '五行颜色',
            subtitle: '先用颜色建立木、火、土、金、水的第一印象',
            color: WuxingColors.getColor('木'),
            bgColor: WuxingColors.getSoftColor('木'),
            page: const WuxingColorPage(),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context,
            index: '2',
            title: '五行意象',
            subtitle: '总览颜色、五味、脏腑、方位、品质、数字、四季与地支',
            color: WuxingColors.getColor('水'),
            bgColor: WuxingColors.getSoftColor('水'),
            page: const WuxingImageryPage(),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context,
            index: '3',
            title: '五行相生',
            subtitle: '记住谁生谁，掌握相生顺序',
            color: WuxingColors.getColor('火'),
            bgColor: WuxingColors.getSoftColor('火'),
            page: const WuxingGeneratePage(),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context,
            index: '4',
            title: '五行相克',
            subtitle: '记住谁克谁，掌握制约关系',
            color: WuxingColors.getColor('土'),
            bgColor: WuxingColors.getSoftColor('土'),
            page: const WuxingControlPage(),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context,
            index: '5',
            title: '以我为中心',
            subtitle: '练生我、我生、克我、我克、同我',
            color: WuxingColors.getColor('水'),
            bgColor: WuxingColors.getSoftColor('水'),
            page: const WuxingCenterPage(),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context,
            index: '★',
            title: '综合练习',
            subtitle: '自由选择相生、相克、以我为中心、旺相休囚死混合训练',
            color: const Color(0xFF2F6F5E),
            bgColor: const Color(0xFFE9F5EF),
            page: const PracticeSetupPage(
              title: '综合练习',
              subtitle: '自由选择五行相生、相克、以我为中心、旺相休囚死混合训练。',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0C28A)),
            ),
            child: const Text(
              '建议按顺序学习：先认颜色，再记意象，再学生克，最后练"以我为中心"。',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF6B4E2E),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '五行模块',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            '五行是断卦的基础。本模块从颜色与意象开始，再学习相生、相克和以我为中心的关系。',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6B4E2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required String index,
    required String title,
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
          backgroundColor: color,
          child: Text(
            index,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          title,
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
