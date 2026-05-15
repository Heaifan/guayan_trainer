import 'package:flutter/material.dart';

import '../../data/wuxing_data.dart';
import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../practice/training_page.dart';

class WuxingStudyPage extends StatelessWidget {
  const WuxingStudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('五行生克')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('五行颜色',
              '木：绿色，生发\n火：朱红，炎上\n土：黄褐，承载\n金：淡金，肃杀\n水：蓝黑，润下'),
          const SizedBox(height: 16),
          _colorTable(),
          const SizedBox(height: 16),
          _section('相生',
              '木 → 火 → 土 → 金 → 水 → 木\n\n相生顺行，生生不息。'),
          const SizedBox(height: 12),
          _cycleRow(),
          const SizedBox(height: 16),
          _section('相克',
              '木克土、土克水、水克火、火克金、金克木\n\n相克隔位，互相制约。'),
          const SizedBox(height: 12),
          _controlRow(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TrainingPage(
                      title: '五行转轮',
                      mode: TrainingMode.wuxing,
                    ),
                  ),
                );
              },
              child: const Text('开始五行练习'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }

  Widget _colorTable() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2), 2: FlexColumnWidth(3)},
        children: [
          _row('五行', '颜色', '意象', isHeader: true),
          _row('木', '🟢 青绿', '生发、树木'),
          _row('火', '🔴 朱红', '炎上、光热'),
          _row('土', '🟤 黄褐', '承载、中土'),
          _row('金', '🟡 淡金', '金石、肃杀'),
          _row('水', '🔵 墨蓝', '润下、寒水'),
        ],
      ),
    );
  }

  TableRow _row(String a, String b, String c, {bool isHeader = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(a, style: TextStyle(fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(b, style: TextStyle(fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(c, style: const TextStyle(color: Color(0xFF6B4E2E))),
        ),
      ],
    );
  }

  Widget _cycleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: WuxingData.elements.map((e) {
        final next = WuxingData.generates[e]!;
        return Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: WuxingColors.getColor(e),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(e, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(height: 4),
            Text('→', style: TextStyle(color: WuxingColors.getColor(next))),
          ],
        );
      }).toList(),
    );
  }

  Widget _controlRow() {
    return Column(
      children: WuxingData.controls.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WuxingChip(e.key),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('克', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              WuxingChip(e.value),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class WuxingChip extends StatelessWidget {
  final String element;
  const WuxingChip(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: WuxingColors.getColor(element),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(element, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }
}
