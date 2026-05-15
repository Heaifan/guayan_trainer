import 'package:flutter/material.dart';

import '../../services/mistake_store.dart';
import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../review/review_page.dart';
import 'training_page.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mistakeCount = MistakeStore.instance.records.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('练习'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('基础训练'),
          _card(
            context,
            icon: Icons.change_circle_outlined,
            title: '五行训练',
            subtitle: '练生我、我生、克我、我克',
            color: WuxingColors.getColor('木'),
            bgColor: WuxingColors.getSoftColor('木'),
            mode: TrainingMode.wuxing,
            modeTitle: '五行转轮',
          ),
          _card(
            context,
            icon: Icons.radio_button_checked,
            title: '地支训练',
            subtitle: '练十二地支五行',
            color: WuxingColors.getColor('土'),
            bgColor: WuxingColors.getSoftColor('土'),
            mode: TrainingMode.dizhi,
            modeTitle: '地支基础',
          ),
          _sectionTitle('关系训练'),
          _card(
            context,
            icon: Icons.flash_on_outlined,
            title: '找对手：六冲',
            subtitle: '子午冲、卯酉冲、寅申冲',
            color: WuxingColors.getColor('火'),
            bgColor: WuxingColors.getSoftColor('火'),
            mode: TrainingMode.sixChong,
            modeTitle: '六冲训练',
          ),
          _card(
            context,
            icon: Icons.link,
            title: '找朋友：六合',
            subtitle: '子丑合、寅亥合、卯戌合',
            color: WuxingColors.getColor('水'),
            bgColor: WuxingColors.getSoftColor('水'),
            mode: TrainingMode.sixHe,
            modeTitle: '六合训练',
          ),
          _sectionTitle('综合训练'),
          _card(
            context,
            icon: Icons.shuffle,
            title: '混合训练',
            subtitle: '五行、地支、冲合一起出现',
            color: WuxingColors.getColor('金'),
            bgColor: WuxingColors.getSoftColor('金'),
            mode: TrainingMode.mixed,
            modeTitle: '混合训练',
          ),
          if (mistakeCount > 0) ...[
            const SizedBox(height: 12),
            _reviewEntry(context, mistakeCount),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required TrainingMode mode,
    required String modeTitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: bgColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TrainingPage(title: modeTitle, mode: mode),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _reviewEntry(BuildContext context, int count) {
    return Card(
      color: const Color(0xFFFFEFEA),
      child: ListTile(
        leading: const Icon(Icons.local_fire_department, color: Color(0xFFC0392B)),
        title: Text('错题回炉：$count 个',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: const Text('答错或迟疑已自动收录'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReviewPage()),
          );
        },
      ),
    );
  }
}
