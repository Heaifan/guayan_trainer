import 'package:flutter/material.dart';

import '../../theme/wuxing_colors.dart';
import '../../widgets/wuxing_control_wheel.dart';

class WuxingControlPage extends StatelessWidget {
  const WuxingControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('五行相克')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _introCard(),
          const SizedBox(height: 16),
          _wheelSection(),
          const SizedBox(height: 8),
          const Center(
            child: Text('克线五交，制约有序',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9C3B2E))),
          ),
          const SizedBox(height: 20),
          _explanationsCard(),
          const SizedBox(height: 16),
          _divinationTip(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9C3B2E),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('相克练习'),
                    content: const Text('五行相克练习即将开放，敬请期待。'),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('知道了'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('开始相克练习'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('五行相克',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text(
            '相克，是制约、约束、克制的关系。\n断卦时判断用神受克、忌神克用，都要先熟悉五行相克。',
            style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF6B4E2E)),
          ),
        ],
      ),
    );
  }

  Widget _wheelSection() {
    return SizedBox(
      height: 360,
      child: WuxingControlWheel(autoPlayAccumulate: true),
    );
  }

  Widget _explanationsCard() {
    const controls = [
      ('木', '克', '土', '木根破土，根能制土。'),
      ('土', '克', '水', '土能筑堤，阻水归槽。'),
      ('水', '克', '火', '水幕压火，火势熄弱。'),
      ('火', '克', '金', '烈火熔金，金属失形。'),
      ('金', '克', '木', '金刃伐木，木被削断。'),
    ];

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
          const Text('相克关系',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...controls.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    _chip(c.$1, WuxingColors.getColor(c.$1)),
                    const SizedBox(width: 4),
                    Text(c.$2,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    _chip(c.$3, WuxingColors.getColor(c.$3)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(c.$4,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF6B4E2E))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: WuxingColors.textOnColor(text),
              fontWeight: FontWeight.w800,
              fontSize: 14)),
    );
  }

  Widget _divinationTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F0E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A574)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('断卦提示',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8A5A3A))),
          SizedBox(height: 8),
          Text(
            '相克关系用于判断谁受制、谁克谁。\n'
            '例如：金克木，若用神属木而被金克，就要特别留意。',
            style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF6B4E2E)),
          ),
        ],
      ),
    );
  }
}
