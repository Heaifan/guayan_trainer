import 'package:flutter/material.dart';

import '../services/mistake_store.dart';
import '../services/question_generator.dart';
import 'mistake_page.dart';
import 'training_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int get mistakeCount => MistakeStore.instance.records.length;

  void _startTraining(TrainingMode mode, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainingPage(
          title: title,
          mode: mode,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卦眼训练器'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          _sectionTitle('训练场'),
          _trainingTile(
            title: '五行转轮',
            subtitle: '练习五行相生、相克、生我、克我',
            icon: Icons.change_circle_outlined,
            onTap: () => _startTraining(TrainingMode.wuxing, '五行转轮'),
          ),
          _trainingTile(
            title: '地支基础',
            subtitle: '练习十二地支五行',
            icon: Icons.radio_button_checked,
            onTap: () => _startTraining(TrainingMode.dizhi, '地支基础'),
          ),
          _trainingTile(
            title: '六冲训练',
            subtitle: '找对手：子午冲、卯酉冲等',
            icon: Icons.flash_on_outlined,
            onTap: () => _startTraining(TrainingMode.sixChong, '六冲训练'),
          ),
          _trainingTile(
            title: '六合训练',
            subtitle: '找朋友：子丑合、寅亥合等',
            icon: Icons.link,
            onTap: () => _startTraining(TrainingMode.sixHe, '六合训练'),
          ),
          _trainingTile(
            title: '混合训练',
            subtitle: '五行、地支、冲合混合出现',
            icon: Icons.shuffle,
            onTap: () => _startTraining(TrainingMode.mixed, '混合训练'),
          ),
          const SizedBox(height: 16),
          _sectionTitle('回炉'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department_outlined),
              title: Text('错题回炉：$mistakeCount 个'),
              subtitle: const Text('答错或迟疑的关系会进入这里'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const MistakePage()))
                    .then((_) => setState(() {}));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '断卦基本功训练',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3B2A1A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '先练五行、生克、地支、冲合。错了就回炉，慢了也提醒，目标是看一眼就知道关系。',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF6B4E2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _trainingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2F6F5E)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
