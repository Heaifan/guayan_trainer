import 'dart:math' as math;
import 'dart:ui';

abstract final class RelationBezierPath {
  static Path build(List<Offset> points, Rect viewport) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 2) {
      _appendDirectBow(path, points.first, points.last, viewport);
      return path;
    }

    const tension = 1.15;
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[i] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      final c1 = _clamp(p1 + (p2 - p0) * (tension / 6), viewport);
      final c2 = _clamp(p2 - (p3 - p1) * (tension / 6), viewport);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  static void _appendDirectBow(
    Path path,
    Offset start,
    Offset end,
    Rect viewport,
  ) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) return;
    final normal = Offset(-delta.dy / distance, delta.dx / distance);
    final midpoint = (start + end) / 2;
    final inward = viewport.center - midpoint;
    final sign =
        normal.dx * inward.dx + normal.dy * inward.dy >= 0 ? 1.0 : -1.0;
    final bow = math.min(52.0, math.max(16.0, distance * .22));
    final c1 = _clamp(start + delta * .32 + normal * bow * sign, viewport);
    final c2 = _clamp(start + delta * .68 + normal * bow * sign, viewport);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
  }

  static Offset _clamp(Offset point, Rect viewport) => Offset(
        point.dx.clamp(viewport.left + 4, viewport.right - 4).toDouble(),
        point.dy.clamp(viewport.top + 4, viewport.bottom - 4).toDouble(),
      );
}
