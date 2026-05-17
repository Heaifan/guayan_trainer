import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/wuxing_data.dart';
import '../../theme/wuxing_colors.dart';
import '../../widgets/wuxing_control_painter.dart';

class WuxingControlPage extends StatelessWidget {
  const WuxingControlPage({super.key});

  static const _elements = ['木', '火', '土', '金', '水'];

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

  /// 相克五角星图
  Widget _wheelSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final s = math.min(constraints.maxWidth, 360).toDouble();
        final nodeSize = s * 0.17;

        return Center(
          child: SizedBox(
            width: s,
            height: s,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(s, s),
                  painter: WuxingControlPainter(
                    containerSize: s,
                    nodeSize: nodeSize,
                  ),
                ),
                ..._elements.map((e) {
                  final pos = WuxingControlPainter.positions[e]!;
                  final left = pos.dx * s - nodeSize / 2;
                  final top = pos.dy * s - nodeSize / 2;
                  return Positioned(
                    left: left,
                    top: top,
                    width: nodeSize,
                    height: nodeSize,
                    child: _node(e, nodeSize),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _node(String element, double size) {
    final bg = WuxingColors.getColor(element);
    final tc = WuxingColors.textOnColor(element);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: element == '金' ? WuxingColors.getBorderColor(element) : Colors.white,
          width: element == '金' ? 2.5 : 3.0,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Text(element,
            style: TextStyle(
                color: tc,
                fontSize: size * 0.48,
                fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _explanationsCard() {
    const controls = [
      ('木', '克', '土', '木能破土而出'),
      ('土', '克', '水', '土能阻水、蓄水'),
      ('水', '克', '火', '水能灭火'),
      ('火', '克', '金', '火能熔金'),
      ('金', '克', '木', '金能伐木'),
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
                    _controlChip(c.$1, WuxingColors.getColor(c.$1)),
                    const SizedBox(width: 4),
                    Text(c.$2,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    _controlChip(c.$3, WuxingColors.getColor(c.$3)),
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

  Widget _controlChip(String text, Color bg) {
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
                  fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF8A5A3A))),
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
