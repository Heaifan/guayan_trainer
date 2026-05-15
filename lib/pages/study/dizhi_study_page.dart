import 'package:flutter/material.dart';

import '../../data/dizhi_data.dart';
import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../practice/training_page.dart';

class DizhiStudyPage extends StatelessWidget {
  const DizhiStudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('十二地支')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('十二地支',
              '子、丑、寅、卯、辰、巳、午、未、申、酉、戌、亥'),
          const SizedBox(height: 16),
          _branchGrid(),
          const SizedBox(height: 16),
          _section('五行归类',
              '水：子、亥\n木：寅、卯\n火：巳、午\n金：申、酉\n土：辰、戌、丑、未'),
          const SizedBox(height: 12),
          _wuxingGroup('水', ['子', '亥']),
          _wuxingGroup('木', ['寅', '卯']),
          _wuxingGroup('火', ['巳', '午']),
          _wuxingGroup('金', ['申', '酉']),
          _wuxingGroup('土', ['辰', '戌', '丑', '未']),
          const SizedBox(height: 16),
          _section('地支分类',
              '四正：子、午、卯、酉\n四生：寅、申、巳、亥\n四墓库：辰、戌、丑、未'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TrainingPage(
                      title: '地支基础',
                      mode: TrainingMode.dizhi,
                    ),
                  ),
                );
              },
              child: const Text('开始地支练习'),
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

  Widget _branchGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DizhiData.names.map((name) {
        return Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: WuxingColors.getColorByBranch(name),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        );
      }).toList(),
    );
  }

  Widget _wuxingGroup(String wuxing, List<String> branches) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: WuxingColors.getColor(wuxing),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(wuxing, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 12),
          ...branches.map((b) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: WuxingColors.getSoftColorByBranch(b),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: WuxingColors.getColorByBranch(b)),
              ),
              child: Text(b, style: TextStyle(fontWeight: FontWeight.w700, color: WuxingColors.getColorByBranch(b))),
            ),
          )),
        ],
      ),
    );
  }
}
