import 'package:flutter/material.dart';

import '../../wuxing_arrow_painter.dart';
import 'control_relation_effect.dart';

/// Five fixed slots for each 相克 (control) relation animation.
///
/// Slot positions avoid the center title and wuxing nodes.
class ControlRelationEffectsLayer extends StatelessWidget {
  final List<WuxingEdge> visibleEdges;
  final double wheelSize;

  const ControlRelationEffectsLayer({
    super.key,
    required this.visibleEdges,
    required this.wheelSize,
  });

  static const Map<String, Offset> _slotPositions = {
    '木土': Offset(0.66, 0.50),
    '土水': Offset(0.42, 0.66),
    '水火': Offset(0.40, 0.38),
    '火金': Offset(0.58, 0.66),
    '金木': Offset(0.34, 0.50),
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
          child: ControlRelationEffect(
            sourceElement: edge.from,
            targetElement: edge.to,
            visible: true,
            size: slotSize,
          ),
        );
      }).toList(),
    );
  }
}
