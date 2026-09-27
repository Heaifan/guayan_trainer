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
    // 语义方向永久冻结：变爻 -> 原动爻。
    //
    // V2 不再让箭头从下方“向上扎进”原爻，而是最后一段沿水平方向
    // 指向原爻，让视觉方向与“变 -> 原”完全一致。
    final originalIsLeft = originalRect.center.dx < changedRect.center.dx;
    final direction = originalIsLeft ? -1.0 : 1.0;

    final start = Offset(
      originalIsLeft ? changedRect.left : changedRect.right,
      changedRect.center.dy,
    );
    final end = Offset(
      originalIsLeft ? originalRect.right : originalRect.left,
      originalRect.center.dy,
    );

    final preferredHookY =
        (start.dy > end.dy ? start.dy : end.dy) + 11.0;
    final maxHookY = rowRect.bottom - 8.0;
    final hookY = preferredHookY.clamp(
      rowRect.top + 8.0,
      maxHookY,
    ).toDouble();

    // 箭头前保留 8dp 水平进场，确保箭头尖明确朝向原爻。
    final preEnd = Offset(end.dx - direction * 8.0, end.dy);
    const radius = 4.0;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, hookY - radius)
      ..quadraticBezierTo(
        start.dx,
        hookY,
        start.dx + direction * radius,
        hookY,
      )
      ..lineTo(preEnd.dx - direction * radius, hookY)
      ..quadraticBezierTo(
        preEnd.dx,
        hookY,
        preEnd.dx,
        hookY - radius,
      )
      ..lineTo(preEnd.dx, preEnd.dy)
      ..lineTo(end.dx, end.dy);

    final arrowTip = end;
    final arrowBase = Offset(end.dx - direction * 8.0, end.dy);
    final arrow = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowBase.dx, arrowBase.dy - 4.0)
      ..lineTo(arrowBase.dx, arrowBase.dy + 4.0)
      ..close();

    final pathBounds = path.getBounds();
    final horizontalMidX = (start.dx + preEnd.dx) / 2;

    return ReturnRelationGlyphGeometry(
      path: path,
      arrow: arrow,
      arrowTip: arrowTip,
      arrowBase: arrowBase,
      label: type == RelationType.huiTouSheng ? '回头生' : '回头克',
      labelCenter: Offset(horizontalMidX, hookY),
      pathBounds: pathBounds,
      bounds: {pathBounds, arrow.getBounds()},
    );
  }
}
