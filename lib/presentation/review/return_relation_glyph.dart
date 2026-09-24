import 'dart:ui';

import '../../domain/relation_type.dart';

class ReturnRelationGlyphGeometry {
  const ReturnRelationGlyphGeometry({
    required this.path,
    required this.arrow,
    required this.arrowTip,
    required this.arrowBase,
    required this.label,
    required this.labelCenter,
    required this.pathBounds,
    required this.bounds,
  });

  final Path path;
  final Path arrow;
  final Offset arrowTip;
  final Offset arrowBase;
  final String label;
  final Offset labelCenter;
  final Rect pathBounds;
  final Set<Rect> bounds;
}

abstract final class ReturnRelationGlyph {
  static ReturnRelationGlyphGeometry layout({
    required Rect rowRect,
    required Rect originalRect,
    required Rect changedRect,
    required RelationType type,
  }) {
    // 回头生/克语义方向固定：变爻 -> 原爻。
    // 只在本行下方走一个紧凑 U 形，不进入普通关系 Router。
    final start = Offset(changedRect.center.dx, changedRect.bottom);
    final end = Offset(originalRect.center.dx, originalRect.bottom);
    final available = rowRect.bottom - (start.dy > end.dy ? start.dy : end.dy);
    final hookDepth = available.clamp(8.0, 14.0).toDouble();
    final hookY = (start.dy > end.dy ? start.dy : end.dy) + hookDepth;
    const radius = 6.0;
    final direction = end.dx < start.dx ? -1.0 : 1.0;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, hookY - radius)
      ..quadraticBezierTo(start.dx, hookY, start.dx + direction * radius, hookY)
      ..lineTo(end.dx - direction * radius, hookY)
      ..quadraticBezierTo(end.dx, hookY, end.dx, hookY - radius)
      ..lineTo(end.dx, end.dy);

    final arrowTip = end;
    final arrowBase = end + const Offset(0, 8);
    final arrow = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowBase.dx - 4, arrowBase.dy)
      ..lineTo(arrowBase.dx + 4, arrowBase.dy)
      ..close();
    final pathBounds = path.getBounds();

    return ReturnRelationGlyphGeometry(
      path: path,
      arrow: arrow,
      arrowTip: arrowTip,
      arrowBase: arrowBase,
      label: type == RelationType.huiTouSheng ? '回头生' : '回头克',
      labelCenter: Offset((start.dx + end.dx) / 2, hookY),
      pathBounds: pathBounds,
      bounds: {pathBounds, arrow.getBounds()},
    );
  }
}
