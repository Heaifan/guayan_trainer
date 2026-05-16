import 'package:flutter/material.dart';

import '../wuxing_arrow_painter.dart';
import 'html_relation_effect.dart';

/// Five fixed slots for each 相生 relation animation.
///
/// Slot positions (relative to wheel size):
/// - 木火: between 木 and 火 (upper-right)
/// - 火土: between 火 and 土 (lower-right)
/// - 土金: between 土 and 金 (lower-center)
/// - 金水: between 金 and 水 (lower-left)
/// - 水木: between 水 and 木 (upper-left)
class GenerateRelationEffectsLayer extends StatelessWidget {
  final List<WuxingEdge> visibleEdges;
  final double wheelSize;

  const GenerateRelationEffectsLayer({
    super.key,
    required this.visibleEdges,
    required this.wheelSize,
  });

  static const Map<String, Offset> _slotPositions = {
    '木火': Offset(0.66, 0.25),
    '火土': Offset(0.82, 0.56),
    '土金': Offset(0.50, 0.88),
    '金水': Offset(0.18, 0.56),
    '水木': Offset(0.34, 0.25),
  };

  String _slotKey(WuxingEdge e) => '${e.from}${e.to}';

  @override
  Widget build(BuildContext context) {
    final slotSize = wheelSize * 0.18;

    return Stack(
      children: visibleEdges.map((edge) {
        final key = _slotKey(edge);
        final pos = _slotPositions[key];
        if (pos == null) return const SizedBox.shrink();

        return Positioned(
          left: pos.dx * wheelSize - slotSize / 2,
          top: pos.dy * wheelSize - slotSize / 2,
          width: slotSize,
          height: slotSize,
          child: _buildEffectForEdge(edge, slotSize),
        );
      }).toList(),
    );
  }

  Widget _buildEffectForEdge(WuxingEdge edge, double slotSize) {
    return HtmlRelationEffect(
      sourceElement: edge.from,
      targetElement: edge.to,
      visible: true,
      size: slotSize,
    );
  }
}
