import 'dart:ui';

/// Geometry for one open, left-facing back-relation turnback glyph.
class BackRelationGeometry {
  const BackRelationGeometry({
    required this.path,
    required this.arrow,
    required this.arrowTip,
    required this.arrowBaseCenter,
    required this.labelCenter,
    required this.bounds,
  });

  final Path path;
  final Path arrow;
  final Offset arrowTip;
  final Offset arrowBaseCenter;
  final Offset labelCenter;
  final Rect bounds;
}

abstract final class BackRelationGlyph {
  static const height = 20.0;
  static const sideInset = 3.0;
  static const turnInset = 4.0;
  static const turnRadius = 9.0;
  static const arrowLength = 6.0;
  static const arrowHalfHeight = 4.0;
  static const labelGap = 2.0;

  static BackRelationGeometry layout({
    required Rect rowRect,
    required Rect mainLineRect,
    required Rect changedLineRect,
  }) {
    final left = mainLineRect.right + sideInset;
    final right = changedLineRect.left - turnInset;
    final width = (right - left).clamp(28.0, double.infinity).toDouble();
    final turnX = left + width;
    final centerY = rowRect.center.dy;
    final bottomY = centerY + height / 2;
    final topY = centerY - height / 2;
    final returnX = left + turnRadius + arrowLength;
    final arrowTip = Offset(returnX, topY);
    final arrowBaseCenter = Offset(returnX + arrowLength, topY);

    final path = Path()
      ..moveTo(left, bottomY)
      ..cubicTo(left + width * .32, bottomY, turnX - turnRadius, bottomY, turnX, bottomY)
      ..cubicTo(turnX + turnRadius, bottomY, turnX + turnRadius, topY, turnX, topY)
      ..cubicTo(turnX - turnRadius, topY, returnX + arrowLength, topY, returnX, topY);
    final arrow = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowBaseCenter.dx, arrowBaseCenter.dy - arrowHalfHeight)
      ..lineTo(arrowBaseCenter.dx, arrowBaseCenter.dy + arrowHalfHeight)
      ..close();
    final bounds = Rect.fromLTRB(
      left,
      topY - 2,
      turnX + turnRadius,
      bottomY + 2,
    );
    return BackRelationGeometry(
      path: path,
      arrow: arrow,
      arrowTip: arrowTip,
      arrowBaseCenter: arrowBaseCenter,
      labelCenter: Offset(left + width * .42, topY - labelGap),
      bounds: bounds,
    );
  }
}
