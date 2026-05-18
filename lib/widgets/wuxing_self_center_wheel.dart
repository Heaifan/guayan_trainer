import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/wuxing_self_center_data.dart';
import '../theme/wuxing_colors.dart';
import 'wuxing_self_center_painter.dart';

/// 以我为中心圆盘。
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
        final size = math.min(constraints.maxWidth, 360.0);
        final centerSize = size * 0.30;
        final outerBox = size * 0.25;

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
                    outerRadius: outerBox * 0.30,
                  ),
                ),
                _outerNode('生我', relations['生我']!, size, outerBox),
                _outerNode('我生', relations['我生']!, size, outerBox),
                _outerNode('我克', relations['我克']!, size, outerBox),
                _outerNode('克我', relations['克我']!, size, outerBox),
                Center(child: _centerNode(centerSize)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _outerNode(String relation, String element, double size, double box) {
    final (dx, dy) = selfCenterPositions[relation]!;
    final state = relationStateMap[relation]!;
    final left = dx * size - box / 2;
    final top = dy * size - box / 2;
    final circleSize = box * 0.52;

    return Positioned(
      left: left,
      top: top,
      width: box,
      height: box,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Element circle
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: WuxingColors.getColor(element),
              shape: BoxShape.circle,
              border: Border.all(
                color: element == '金'
                    ? WuxingColors.getBorderColor(element)
                    : Colors.white,
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
                      fontSize: circleSize * 0.45,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 5),
          // Relation + state pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0C28A).withValues(alpha: 0.6)),
            ),
            child: Text(
              '$relation · $state',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B4E2E),
              ),
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: selfElement == '金'
              ? WuxingColors.getBorderColor(selfElement)
              : Colors.white,
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
                  color: tc,
                  fontSize: size * 0.40,
                  fontWeight: FontWeight.w900)),
          Text('同我｜旺',
              style: TextStyle(
                  color: tc.withValues(alpha: 0.85),
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
