import 'package:flutter/material.dart';

import '../../data/relation_data.dart';
import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../practice/training_page.dart';

class RelationStudyPage extends StatelessWidget {
  const RelationStudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('六冲六合')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('六冲：找对手',
              '冲 = 对手。方位相对，气场冲突。'),
          const SizedBox(height: 12),
          ...RelationData.sixChong.entries.map((e) => _pairRow(e.key, e.value, '冲')),
          const SizedBox(height: 24),
          _section('六合：找朋友',
              '合 = 朋友。气场相合，互补互助。'),
          const SizedBox(height: 12),
          ...RelationData.sixHe.entries.map((e) => _pairRow(e.key, e.value, '合')),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TrainingPage(
                          title: '六冲训练',
                          mode: TrainingMode.sixChong,
                        ),
                      ),
                    );
                  },
                  child: const Text('练六冲'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TrainingPage(
                          title: '六合训练',
                          mode: TrainingMode.sixHe,
                        ),
                      ),
                    );
                  },
                  child: const Text('练六合'),
                ),
              ),
            ],
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

  Widget _pairRow(String a, String b, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BranchChip(a),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: label == '冲' ? const Color(0xFFC0392B).withValues(alpha: 0.1) : const Color(0xFF2F6F5E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(label, style: TextStyle(
                fontWeight: FontWeight.w800,
                color: label == '冲' ? const Color(0xFFC0392B) : const Color(0xFF2F6F5E),
              )),
            ),
          ),
          BranchChip(b),
        ],
      ),
    );
  }
}

class BranchChip extends StatelessWidget {
  final String branch;
  const BranchChip(this.branch, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: WuxingColors.getColorByBranch(branch),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(branch, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
    );
  }
}
