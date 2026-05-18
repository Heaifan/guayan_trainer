import 'package:flutter/material.dart';

import '../../models/training_result.dart';
import '../../theme/wuxing_colors.dart';
import '../review/review_page.dart';

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
          if (result.stageStats.isNotEmpty) _stageStatsCard(),
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
          if (result.wrongResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('错题列表',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ...result.wrongResults.map((r) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: WuxingColors.getColor(r.question.correctAnswer == '木' ? '木' : '土')
                          .withValues(alpha: 0.2),
                      child: Text('✗',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    title: Text(r.question.prompt),
                    subtitle: Text('正确: ${r.question.correctAnswer}  你选: ${r.selectedAnswer}'),
                  ),
                )),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReviewPage()),
              );
            },
            child: const Text('立即回炉'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('再练一轮'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  String _stageLabel(String style) {
    switch (style) {
      case 'wheel': return '轮盘题';
      case 'colorChoice': return '彩色单选';
      case 'textChoice': return '无色单选';
      default: return style;
    }
  }

  Widget _stageStatsCard() {
    final stats = result.stageStats;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('分阶段表现',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...stats.entries.map((e) {
            final (c, t) = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(_stageLabel(e.key),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Text('$c / $t',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            );
          }),
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
