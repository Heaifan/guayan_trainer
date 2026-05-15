import 'package:flutter/material.dart';

import '../../services/mistake_store.dart';


class HomePage extends StatefulWidget {
  final void Function(int index)? onNavigateTab;

  const HomePage({super.key, this.onNavigateTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final mistakes = MistakeStore.instance.records;
    final mistakeCount = mistakes.length;
    final slowCount = mistakes.where((e) => e.slowCount > 0).length;

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
          _statusCard(mistakeCount, slowCount),
          const SizedBox(height: 16),
          if (mistakeCount > 0) _reviewReminder(mistakes.take(3).toList()),
          if (mistakeCount > 0) const SizedBox(height: 16),
          _quickActions(),
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
            '先练五行、生克、地支、冲合。\n错了就回炉，慢了也提醒，目标是看一眼就知道关系。',
            style: TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF6B4E2E)),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(int mistakeCount, int slowCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('学习状态', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _statusRow('五行', 0.3),
          _statusRow('地支', 0.3),
          _statusRow('六冲', 0.1),
          _statusRow('六合', 0.1),
          const SizedBox(height: 8),
          Text('回炉项: $mistakeCount  迟疑项: $slowCount',
              style: const TextStyle(color: Color(0xFF6B4E2E))),
        ],
      ),
    );
  }

  Widget _statusRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 8),
          Text(value < 0.2 ? '生疏' : '入门',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B4E2E))),
        ],
      ),
    );
  }

  Widget _reviewReminder(List records) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC0392B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Color(0xFFC0392B), size: 20),
              SizedBox(width: 6),
              Text('回炉提醒', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          ...records.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('• ${r.knowledgeKey}  (错${r.wrongCount}次)',
                style: const TextStyle(fontSize: 14)),
          )),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(child: _actionBtn('继续练习', Icons.play_arrow, () => widget.onNavigateTab?.call(2))),
        const SizedBox(width: 12),
        Expanded(child: _actionBtn('立即回炉', Icons.local_fire_department_outlined, () => widget.onNavigateTab?.call(3))),
        const SizedBox(width: 12),
        Expanded(child: _actionBtn('进入学习', Icons.menu_book_outlined, () => widget.onNavigateTab?.call(1))),
      ],
    );
  }

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
