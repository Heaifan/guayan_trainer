import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/wuxing_self_center_data.dart';
import '../theme/wuxing_colors.dart';
import 'wuxing_self_center_painter.dart';

/// 以我为中心圆盘 — 紧凑版。
class WuxingSelfCenterWheel extends StatelessWidget {
  final String selfElement;

  const WuxingSelfCenterWheel({
    super.key,
    required this.selfElement,
  });

  @override
  Widget build(BuildContext context) {
    final relations = wuxingSelfCenterRelations[selfElement]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 310.0);
        final centerSize = size * 0.28;
        final outerBox = size * 0.22;
        final circleSize = outerBox * 0.58;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: WuxingSelfCenterPainter(
                    centerRadius: centerSize / 2,
                    outerRadius: circleSize / 2,
                  ),
                ),
                _outerNode('生我', relations['生我']!, size, outerBox, circleSize),
                _outerNode('我生', relations['我生']!, size, outerBox, circleSize),
                _outerNode('我克', relations['我克']!, size, outerBox, circleSize),
                _outerNode('克我', relations['克我']!, size, outerBox, circleSize),
                Center(child: _centerNode(centerSize)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _outerNode(String relation, String element, double size, double box, double circle) {
    final (dx, dy) = selfCenterPositions[relation]!;
    final state = relationStateMap[relation]!;
    final left = dx * size - box / 2;
    final top = dy * size - box / 2;

    return Positioned(
      left: left, top: top, width: box, height: box,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: circle, height: circle,
            decoration: BoxDecoration(
              color: WuxingColors.getColor(element),
              shape: BoxShape.circle,
              border: Border.all(
                color: element == '金' ? WuxingColors.getBorderColor(element) : Colors.white,
                width: element == '金' ? 2 : 2.5,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Text(element,
                  style: TextStyle(
                      color: WuxingColors.textOnColor(element),
                      fontSize: circle * 0.48,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 4),
          // Single-line pill: 生我 · 相
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFD7C090), width: 0.8),
            ),
            child: Text(
              '$relation · $state',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4A3826)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerNode(double size) {
    final bg = WuxingColors.getColor(selfElement);
    final tc = WuxingColors.textOnColor(selfElement);

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: selfElement == '金' ? WuxingColors.getBorderColor(selfElement) : Colors.white,
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(selfElement,
              style: TextStyle(
                  color: tc, fontSize: size * 0.34,
                  fontWeight: FontWeight.w900, height: 1)),
          const SizedBox(height: 2),
          Text('同我｜旺',
              style: TextStyle(
                  color: tc.withValues(alpha: 0.85),
                  fontSize: size * 0.13,
                  fontWeight: FontWeight.w700, height: 1)),
        ],
      ),
    );
  }
}
