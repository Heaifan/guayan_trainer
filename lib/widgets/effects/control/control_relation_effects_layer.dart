import 'package:flutter/material.dart';

import '../../wuxing_arrow_painter.dart';
import 'control_relation_effect.dart';

/// 相克特效展示 — 显示当前一条关系特效，不累计。
class ControlRelationEffectsLayer extends StatelessWidget {
  final WuxingEdge? activeEdge;
  final double effectSize;

  const ControlRelationEffectsLayer({
    super.key,
    this.activeEdge,
    this.effectSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (activeEdge == null) return const SizedBox.shrink();

    return SizedBox(
      width: effectSize,
      height: effectSize,
      child: ControlRelationEffect(
        sourceElement: activeEdge!.from,
        targetElement: activeEdge!.to,
        visible: true,
        size: effectSize,
      ),
    );
  }
}
