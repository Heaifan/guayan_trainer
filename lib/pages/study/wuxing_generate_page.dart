import 'package:flutter/material.dart';

import '../../data/wuxing_data.dart';
import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../../widgets/wuxing_wheel.dart';
import '../practice/training_page.dart';

class WuxingGeneratePage extends StatelessWidget {
  const WuxingGeneratePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('五行相生')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('五行相生',
              '相生，就是生扶、滋养、接续的关系。\n记住五行相生顺序，是后面判断生扶、原神、六亲关系的基础。'),
          const SizedBox(height: 16),
          _sequenceCard(),
          const SizedBox(height: 16),
          _wheelCard(),
          const SizedBox(height: 16),
          _explanationsCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TrainingPage(
                      title: '五行相生练习',
                      mode: TrainingMode.wuxingGenerate,
                    ),
                  ),
                );
              },
              child: const Text('开始相生练习'),
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

  Widget _sequenceCard() {
    final elements = WuxingData.elements;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < elements.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('→', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2F6F5E))),
                  ),
                _seqNode(elements[i]),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2F6F5E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text('相生顺行，生生不息',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2F6F5E))),
          ),
        ],
      ),
    );
  }

  Widget _seqNode(String element) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: WuxingColors.getColor(element),
        shape: BoxShape.circle,
        border: Border.all(
          color: element == '金' ? WuxingColors.getBorderColor('金') : Colors.white,
          width: element == '金' ? 2 : 2,
        ),
      ),
      child: Center(
        child: Text(element,
            style: TextStyle(
              color: WuxingColors.textOnColor(element),
              fontSize: 16, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _wheelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const SizedBox(
        height: 260,
        child: WuxingWheel(
          selected: null,
          correctAnswer: '火',
          hasAnswered: false,
          sourceElement: '木',
          showEffect: true,
          onTap: null,
        ),
      ),
    );
  }

  Widget _explanationsCard() {
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
          const Text('五条相生关系',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _explanationRow('木', '火', '木燃则生火', WuxingColors.getColor('木'), WuxingColors.getColor('火')),
          _explanationRow('火', '土', '火尽成灰，灰归于土', WuxingColors.getColor('火'), WuxingColors.getColor('土')),
          _explanationRow('土', '金', '金藏于土，土中生金', WuxingColors.getColor('土'), WuxingColors.getColor('金')),
          _explanationRow('金', '水', '金寒生水，金气凝水', WuxingColors.getColor('金'), WuxingColors.getColor('水')),
          _explanationRow('水', '木', '水润生木，万木得水而生', WuxingColors.getColor('水'), WuxingColors.getColor('木')),
        ],
      ),
    );
  }

  Widget _explanationRow(String from, String to, String text, Color fromColor, Color toColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: fromColor, shape: BoxShape.circle,
                border: Border.all(color: from == '金' ? WuxingColors.getBorderColor('金') : Colors.white, width: 1.5)),
            child: Center(child: Text(from, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900))),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('→', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2F6F5E))),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: toColor, shape: BoxShape.circle,
                border: Border.all(color: to == '金' ? WuxingColors.getBorderColor('金') : Colors.white, width: 1.5)),
            child: Center(child: Text(to, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF6B4E2E)))),
        ],
      ),
    );
  }
}
