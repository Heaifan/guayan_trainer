import 'package:flutter/material.dart';

import '../services/mistake_store.dart';

class MistakePage extends StatefulWidget {
  const MistakePage({super.key});

  @override
  State<MistakePage> createState() => _MistakePageState();
}

class _MistakePageState extends State<MistakePage> {
  @override
  Widget build(BuildContext context) {
    final records = MistakeStore.instance.records;

    return Scaffold(
      appBar: AppBar(
        title: const Text('错题回炉'),
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
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = records[index];
                return Card(
                  child: ListTile(
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
              },
            ),
    );
  }
}
