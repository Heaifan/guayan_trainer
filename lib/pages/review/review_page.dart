import 'package:flutter/material.dart';

import '../../services/mistake_store.dart';



class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    final records = MistakeStore.instance.records;
    final wrongRecords = records.where((e) => e.wrongCount > 0).toList();
    final slowRecords = records.where((e) => e.slowCount > 0 && e.wrongCount == 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('回炉'),
        centerTitle: true,
        actions: [
          if (records.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  MistakeStore.instance.clear();
                });
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: records.isEmpty
          ? const Center(
              child: Text(
                '暂无回炉项。\n答错或迟疑的知识点会出现在这里。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _overviewCard(records.length, wrongRecords.length, slowRecords.length),
                const SizedBox(height: 16),
                if (wrongRecords.isNotEmpty) ...[
                  const Text('错题回炉',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...wrongRecords.map((r) => _recordCard(r)),
                ],
                if (slowRecords.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('迟疑回炉',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...slowRecords.map((r) => _recordCard(r)),
                ],
              ],
            ),
    );
  }

  Widget _overviewCard(int total, int wrong, int slow) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _overviewItem('回炉', total, const Color(0xFFC0392B)),
          _overviewItem('答错', wrong, const Color(0xFFC0392B)),
          _overviewItem('迟疑', slow, const Color(0xFFB9770E)),
        ],
      ),
    );
  }

  Widget _overviewItem(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(color: Color(0xFF6B4E2E))),
      ],
    );
  }

  Widget _recordCard(dynamic item) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFC0392B).withValues(alpha: 0.12),
          child: const Icon(Icons.local_fire_department, size: 18),
        ),
        title: Text(
          item.knowledgeKey,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${item.explanation}\n错 ${item.wrongCount} 次，迟疑 ${item.slowCount} 次',
        ),
        isThreeLine: true,
        trailing: TextButton(
          onPressed: () {
            setState(() {
              MistakeStore.instance.markReviewCorrect(item.knowledgeKey);
            });
          },
          child: const Text('已会'),
        ),
      ),
    );
  }
}
