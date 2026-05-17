import 'package:flutter/material.dart';

import '../../services/mistake_store.dart';
import 'review_training_page.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  void initState() {
    super.initState();
    // 首次构建时确保存储已加载
    MistakeStore.instance.all;
  }

  void _refresh() => setState(() {});

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空所有错题？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('清空')),
        ],
      ),
    );
    if (ok == true) {
      await MistakeStore.instance.clearAll();
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mistakes = MistakeStore.instance.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('回炉'),
        centerTitle: true,
        actions: [
          if (mistakes.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: mistakes.isEmpty
          ? const Center(
              child: Text(
                '暂无回炉项。\n答错的知识点会出现在这里。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _overviewCard(mistakes.length),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewTrainingPage(
                            mistakes: List.from(mistakes),
                            isBulk: true,
                          ),
                        ),
                      ).then((_) => _refresh());
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('重做全部错题',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 20),
                ...mistakes.map((m) => _mistakeCard(m)),
              ],
            ),
    );
  }

  String _stageLabel(String style) {
    switch (style) {
      case 'wheel':
        return '轮盘题';
      case 'colorChoice':
        return '彩色单选';
      case 'textChoice':
        return '无色单选';
      default:
        return '相生练习';
    }
  }

  Widget _overviewCard(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        children: [
          Text('$count',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFC0392B))),
          const SizedBox(height: 4),
          const Text('错题', style: TextStyle(color: Color(0xFF6B4E2E))),
          const SizedBox(height: 6),
          const Text(
            '本次先把错题做对，再继续新内容。',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A6A3A)),
          ),
        ],
      ),
    );
  }

  Widget _mistakeCard(dynamic item) {
    final m = item;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('你选了：', style: TextStyle(color: Color(0xFF8A6A3A))),
                Text(m.wrongAnswer,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: Color(0xFFC0392B))),
                const SizedBox(width: 16),
                const Text('正确是：', style: TextStyle(color: Color(0xFF8A6A3A))),
                Text(m.correctAnswer,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: Color(0xFF2F6F5E))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${m.relationText} · 错了 ${m.wrongCount} 次 · ${_stageLabel(m.practiceStyle)}',
              style: const TextStyle(color: Color(0xFF6B4E2E), fontSize: 14),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReviewTrainingPage(
                        mistakes: [m],
                        isBulk: false,
                      ),
                    ),
                  ).then((_) => _refresh());
                },
                child: const Text('重做'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
