import 'dart:math' as math;
import 'dart:ui';

enum RelationRouteKind { mainToMain, mainToChanged, changedToChanged, calendarToYao }

Path buildRelationRoutePath({
  required Offset from,
  required Offset to,
  required RelationRouteKind route,
  required int trunkLane,
  required double branchOffset,
  required double viewportWidth,
}) {
  final rowSpan = (from.dy - to.dy).abs();
  if (route == RelationRouteKind.mainToChanged || rowSpan <= 220) {
    final lateral = route == RelationRouteKind.changedToChanged ? -1.0 : 1.0;
    final bow = lateral * (18 + trunkLane * 6) + branchOffset;
    return Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx + bow,
        from.dy + (to.dy - from.dy) * .28,
        to.dx + bow,
        to.dy - (to.dy - from.dy) * .28,
        to.dx,
        to.dy,
      );
  }

  final right = route == RelationRouteKind.changedToChanged;
  final gutter = math.min(110.0, 18.0 + trunkLane * 12.0);
  final outer = route == RelationRouteKind.calendarToYao
      ? (from.dx < to.dx ? 8.0 : viewportWidth - 8.0)
      : right
      ? viewportWidth - gutter
      : gutter;
  final sign = outer < from.dx ? -1.0 : 1.0;
  final bend = math.max(28.0, rowSpan * .28);
  return Path()
    ..moveTo(from.dx, from.dy)
    ..cubicTo(
      from.dx + sign * bend,
      from.dy,
      outer + sign * bend,
      to.dy,
      to.dx,
      to.dy,
    );
}
