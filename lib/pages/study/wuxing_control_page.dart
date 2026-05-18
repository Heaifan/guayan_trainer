import 'dart:async';
import 'package:flutter/material.dart';

import '../../theme/wuxing_colors.dart';
import '../../widgets/effects/control/control_relation_effects_layer.dart';
import '../../widgets/wuxing_arrow_painter.dart';
import '../../widgets/wuxing_control_wheel.dart';

class WuxingControlPage extends StatefulWidget {
  const WuxingControlPage({super.key});

  @override
  State<WuxingControlPage> createState() => _WuxingControlPageState();
}

class _WuxingControlPageState extends State<WuxingControlPage> {
  int _activeIndex = 0;
  Timer? _cycleTimer;

  static const _relations = [
    ('木', '土', '木根破土，根能制土。'),
    ('土', '水', '土能筑堤，阻水归槽。'),
    ('水', '火', '水幕压火，火势熄弱。'),
    ('火', '金', '烈火熔金，金属失形。'),
    ('金', '木', '金刃伐木，木被削断。'),
  ];

  String get _currentTitle {
    final (from, to, _) = _relations[_activeIndex];
    return '$from克$to';
  }

  String get _currentDescription {
    final (_, _, desc) = _relations[_activeIndex];
    return desc;
  }

  @override
  void initState() {
    super.initState();
    _startCycle();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    super.dispose();
  }

  void _startCycle() {
    _cycleTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _activeIndex = (_activeIndex + 1) % _relations.length;
      });
    });
  }

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
          const SizedBox(height: 12),
          _titleSection(),
          const SizedBox(height: 12),
          _effectSection(),
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
      height: 280,
      child: WuxingControlWheel(
        autoPlay: true,
        activeIndex: _activeIndex,
      ),
    );
  }

  Widget _titleSection() {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _currentTitle,
            key: ValueKey(_currentTitle),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF9C3B2E),
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _currentDescription,
            key: ValueKey(_currentDescription),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B4E2E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _effectSection() {
    final edge = _relations[_activeIndex];
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C28A).withValues(alpha: 0.3)),
      ),
      child: Center(
        child: ControlRelationEffectsLayer(
          activeEdge: WuxingEdge(edge.$1, edge.$2),
          effectSize: 150,
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
          const Text('相克关系',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ..._relations.map((c) {
            final (from, to, desc) = c;
            final isCurrent = c == _relations[_activeIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Opacity(
                opacity: isCurrent ? 1.0 : 0.65,
                child: Row(
                  children: [
                    _chip(from, WuxingColors.getColor(from)),
                    const SizedBox(width: 4),
                    Text('克',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isCurrent
                                ? const Color(0xFF9C3B2E)
                                : const Color(0xFF6B4E2E))),
                    const SizedBox(width: 4),
                    _chip(to, WuxingColors.getColor(to)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(desc,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF6B4E2E))),
                    ),
                  ],
                ),
              ),
            );
          }),
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
