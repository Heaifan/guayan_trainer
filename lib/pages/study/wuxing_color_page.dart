import 'package:flutter/material.dart';

import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../practice/training_page.dart';

class WuxingColorPage extends StatelessWidget {
  const WuxingColorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('五行颜色与意象')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('五行颜色',
              '先用颜色和意象记住木、火、土、金、水。\n看到颜色，就能立刻想到对应五行。'),
          const SizedBox(height: 16),
          _colorCards(),
          const SizedBox(height: 16),
          _section('颜色对照表',
              '方便快速扫读和记忆。'),
          const SizedBox(height: 8),
          _colorTable(),
          const SizedBox(height: 16),
          _section('记忆提示',
              '木：像树木，故为绿色\n火：像火焰，故为红色\n土：像大地，故为黄色\n金：像金石之气，故为白色\n水：像江河寒水，故为蓝色'),
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

  Widget _colorCards() {
    final items = [
      _ColorItem('木', '绿色', '生发、树木', WuxingColors.getColor('木')),
      _ColorItem('火', '红色', '炎上、光热', WuxingColors.getColor('火')),
      _ColorItem('土', '黄色', '承载、中土', WuxingColors.getColor('土')),
      _ColorItem('金', '白色', '金石、肃杀', const Color(0xFFF0EDE6)),
      _ColorItem('水', '蓝色', '润下、寒水', WuxingColors.getColor('水')),
    ];

    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: item.color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(item.element,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.element,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        Text('|  $item.colorName',
                            style: TextStyle(fontSize: 15, color: item.color)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.image,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B4E2E))),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
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
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(3)},
        children: [
          _row('五行', '颜色', '意象', isHeader: true),
          _row('木', '绿色', '生发、树木'),
          _row('火', '红色', '炎上、光热'),
          _row('土', '黄色', '承载、中土'),
          _row('金', '白色', '金石、肃杀'),
          _row('水', '蓝色', '润下、寒水'),
        ],
      ),
    );
  }

  TableRow _row(String a, String b, String c, {bool isHeader = false}) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
      color: isHeader ? const Color(0xFF3B2A1A) : const Color(0xFF3B2A1A),
    );
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(a, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(b, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(c, style: const TextStyle(color: Color(0xFF6B4E2E))),
        ),
      ],
    );
  }
}

class _ColorItem {
  final String element;
  final String colorName;
  final String image;
  final Color color;

  const _ColorItem(this.element, this.colorName, this.image, this.color);
}
