import 'package:flutter/material.dart';

import '../models/training_result.dart';
import 'mistake_page.dart';

class ResultPage extends StatelessWidget {
  final TrainingSessionResult result;

  const ResultPage({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final accuracyText = '${(result.accuracy * 100).round()}%';

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练结果'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE0C28A)),
            ),
            child: Column(
              children: [
                const Text(
                  '本轮训练完成',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                Text(
                  accuracyText,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2F6F5E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '正确 ${result.correctCount} / 共 ${result.total} 题',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _summaryCard(
            title: '进入回炉',
            count: result.wrongResults.length,
            subtitle: '答错的关系会进入回炉，后面优先复训。',
            color: const Color(0xFFC0392B),
          ),
          _summaryCard(
            title: '迟疑项',
            count: result.slowResults.length,
            subtitle: '答对但超过 4 秒，说明还没形成反射。',
            color: const Color(0xFFB9770E),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MistakePage()),
              );
            },
            child: const Text('查看错题回炉'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required int count,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
