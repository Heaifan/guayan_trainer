import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/wuxing_self_center_data.dart';
import '../theme/wuxing_colors.dart';
import 'wuxing_self_center_painter.dart';

/// 以我为中心圆盘。
///
/// 学习页：完整显示关系标签和箭头。
/// 练习页：答题前只显示节点，答题后显示正确关系。
class WuxingSelfCenterWheel extends StatelessWidget {
  final String selfElement;
  final bool showLabels;
  final bool showArrows;
  final String? activeRelation;
  final ValueChanged<String>? onElementTap;

  const WuxingSelfCenterWheel({
    super.key,
    required this.selfElement,
    this.showLabels = true,
    this.showArrows = true,
    this.activeRelation,
    this.onElementTap,
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
                    showArrows: showArrows,
                    activeRelation: showArrows ? activeRelation : null,
                  ),
                ),
                // Always show all 4 outer nodes for tapping
                ...['生我', '我生', '克我', '我克'].map((r) =>
                    _outerNode(r, relations[r]!, size, outerBox, circleSize, r == activeRelation)),
                Center(child: _centerNode(centerSize)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _outerNode(String relation, String element, double size, double box, double circle, bool isActive) {
    final (dx, dy) = selfCenterPositions[relation]!;
    final state = relationStateMap[relation]!;
    final left = dx * size - box / 2;
    final top = dy * size - box / 2;

    return Positioned(
      left: left, top: top, width: box, height: box,
      child: GestureDetector(
        onTap: onElementTap != null ? () => onElementTap!(element) : null,
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
                boxShadow: isActive
                    ? [BoxShadow(color: const Color(0xFF2F6F5E).withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 2)]
                    : [const BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
              ),
              child: Center(
                child: Text(element,
                    style: TextStyle(
                        color: WuxingColors.textOnColor(element),
                        fontSize: circle * 0.48,
                        fontWeight: FontWeight.w900)),
              ),
            ),
            if (showLabels) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: isActive ? const Color(0xFF2F6F5E) : const Color(0xFFD7C090), width: isActive ? 1.5 : 0.8),
                ),
                child: Text(
                  isActive ? '$relation · $state' : '$relation · $state',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                      color: isActive ? const Color(0xFF2F6F5E) : const Color(0xFF4A3826)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _centerNode(double size) {
    final bg = WuxingColors.getColor(selfElement);
    final tc = WuxingColors.textOnColor(selfElement);

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: bg, shape: BoxShape.circle,
        border: Border.all(
          color: selfElement == '金' ? WuxingColors.getBorderColor(selfElement) : Colors.white,
          width: 3,
        ),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(selfElement,
              style: TextStyle(color: tc, fontSize: size * 0.34, fontWeight: FontWeight.w900, height: 1)),
          if (showLabels) ...[
            const SizedBox(height: 2),
            Text('同我｜旺',
                style: TextStyle(color: tc.withValues(alpha: 0.85), fontSize: size * 0.13, fontWeight: FontWeight.w700, height: 1)),
          ],
        ],
      ),
    );
  }
}
