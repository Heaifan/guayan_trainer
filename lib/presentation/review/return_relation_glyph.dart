import 'dart:ui';

import '../../domain/relation_type.dart';

class ReturnRelationGlyphGeometry {
  const ReturnRelationGlyphGeometry({
    required this.path,
    required this.arrow,
    required this.arrowTip,
    required this.arrowBase,
    required this.label,
    required this.pathBounds,
    required this.bounds,
  });

  final Path path;
  final Path arrow;
  final Offset arrowTip;
  final Offset arrowBase;
  final String label;
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
    final leftToRight = changedRect.center.dx < originalRect.center.dx;
    final left = leftToRight ? changedRect.center.dx : originalRect.center.dx;
    final right = leftToRight ? originalRect.center.dx : changedRect.center.dx;
    final y = rowRect.center.dy;
    final hookY = rowRect.top + 8;
    final start = Offset(left, y);
    final end = Offset(right, y);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, hookY)
      ..lineTo(end.dx, hookY)
      ..lineTo(end.dx, end.dy);
    final arrowTip = leftToRight ? end : start;
    final arrowBase = leftToRight
        ? arrowTip - const Offset(8, 0)
        : arrowTip + const Offset(8, 0);
    final arrow = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowBase.dx, arrowBase.dy - 4)
      ..lineTo(arrowBase.dx, arrowBase.dy + 4)
      ..close();
    final pathBounds = path.getBounds();
    return ReturnRelationGlyphGeometry(
      path: path,
      arrow: arrow,
      arrowTip: arrowTip,
      arrowBase: arrowBase,
      label: type == RelationType.huiTouSheng ? '回生' : '回克',
      pathBounds: pathBounds,
      bounds: {pathBounds, arrow.getBounds()},
    );
  }
}
