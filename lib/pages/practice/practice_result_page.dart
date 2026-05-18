import 'package:flutter/material.dart';

import '../../models/practice/practice_answer_record.dart';
import '../../models/practice/practice_enums.dart';
import '../review/review_page.dart';

class PracticeResultPage extends StatelessWidget {
  final List<PracticeAnswerRecord> records;
  final DateTime startedAt;
  final DateTime finishedAt;

  const PracticeResultPage({
    super.key,
    required this.records,
    required this.startedAt,
    required this.finishedAt,
  });

  PracticeSessionResult get _result => PracticeSessionResult(
        records: records, startedAt: startedAt, finishedAt: finishedAt);

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('练习结果'), centerTitle: true, automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _scoreCard(r),
          const SizedBox(height: 16),
          if (r.topicStats.isNotEmpty) _topicStatsCard(r),
          const SizedBox(height: 16),
          if (r.wrongCount > 0) _summaryCard('错题入回炉', r.wrongCount, '答错的题已加入回炉。', const Color(0xFFC0392B)),
          _summaryCard('平均反应', '${r.averageReactionMs.toStringAsFixed(0)} ms', null, const Color(0xFF3E7DBF)),
          if (r.hesitantCount > 0)
            _summaryCard('迟疑题', r.hesitantCount, '超过 4 秒的题。', const Color(0xFFB9770E)),
          if (records.where((r) => !r.isCorrect).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('错题列表', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ...records.where((r) => !r.isCorrect).map((rec) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Text('✗', style: TextStyle(fontWeight: FontWeight.w900))),
                    title: Text(rec.question.prompt, style: const TextStyle(fontSize: 14)),
                    subtitle: Text('正确: ${rec.question.correctAnswer}  你选: ${rec.selectedAnswer}',
                        style: const TextStyle(fontSize: 13)),
                  ),
                )),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewPage())),
            child: const Text('查看回炉'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard(PracticeSessionResult r) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        children: [
          const Text('练习完成', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text('${(r.accuracy * 100).round()}%',
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF2F6F5E))),
          const SizedBox(height: 6),
          Text('正确 ${r.correctCount} / 共 ${r.total} 题', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _topicStatsCard(PracticeSessionResult r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('分项表现', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...r.topicStats.entries.map((e) {
            final (c, t) = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(width: 90, child: Text(practiceTopicLabel(e.key),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Text('$c / $t', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, dynamic value, String? subtitle, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
      ),
    );
  }
}
