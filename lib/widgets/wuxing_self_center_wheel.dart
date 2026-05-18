import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/wuxing_self_center_data.dart';
import '../theme/wuxing_colors.dart';
import 'wuxing_self_center_painter.dart';

/// 以我为中心圆盘。
///
/// 中心：自我五行
/// 上：生我者｜相
/// 右：我生者｜休
/// 下：我克者｜死
/// 左：克我者｜囚
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
        final size = math.min(constraints.maxWidth, 340.0);
        final nodeSize = size * 0.20;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Arrow layer
                CustomPaint(
                  size: Size(size, size),
                  painter: WuxingSelfCenterPainter(self: selfElement),
                ),

                // Outer nodes
                _outerNode('生我', relations['生我']!, size, nodeSize),
                _outerNode('我生', relations['我生']!, size, nodeSize),
                _outerNode('我克', relations['我克']!, size, nodeSize),
                _outerNode('克我', relations['克我']!, size, nodeSize),

                // Center node
                Center(child: _centerNode(nodeSize)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _outerNode(String relation, String element, double size, double nodeSize) {
    final (dx, dy) = selfCenterPositions[relation]!;
    final state = relationStateMap[relation]!;
    final left = dx * size - nodeSize / 2;
    final top = dy * size - nodeSize / 2;

    return Positioned(
      left: left, top: top,
      width: nodeSize, height: nodeSize,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: nodeSize * 0.72,
            height: nodeSize * 0.72,
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
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Text(element,
                  style: TextStyle(
                      color: WuxingColors.textOnColor(element),
                      fontSize: nodeSize * 0.35,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 3),
          Text(relation,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B4E2E))),
          Text(state,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF9C3B2E))),
        ],
      ),
    );
  }

  Widget _centerNode(double nodeSize) {
    final bg = WuxingColors.getColor(selfElement);
    final tc = WuxingColors.textOnColor(selfElement);

    return Container(
      width: nodeSize * 1.15,
      height: nodeSize * 1.15,
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
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(selfElement,
              style: TextStyle(
                  color: tc, fontSize: nodeSize * 0.38, fontWeight: FontWeight.w900)),
          Text('同我｜旺',
              style: TextStyle(
                  color: tc.withValues(alpha: 0.85),
                  fontSize: nodeSize * 0.20,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
