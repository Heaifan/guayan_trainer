import 'dart:math' as math;
import 'dart:ui';

import '../relation_geometry.dart';
import 'relation_route_scoring.dart';

abstract final class RelationRouteCandidates {
  static Iterable<List<Offset>> forPair(
    AnchorPair pair, Rect viewport,
  ) sync* {
    for (final raw in _raw(pair, viewport)) {
      final points = _normalize(raw);
      if (points.length >= 2) yield points;
    }
  }

  static double length(List<Offset> points) {
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += (points[i + 1] - points[i]).distance;
    }
    return total;
  }

  static Iterable<List<Offset>> _raw(
    AnchorPair pair, Rect viewport,
  ) sync* {
    final s = pair.source.point, t = pair.target.point;
    yield [s, t];
    yield [s, Offset(t.dx, s.dy), t];
    yield [s, Offset(s.dx, t.dy), t];

    final sourceNormal = RelationRouteScoring.outward(pair.source.name);
    final targetNormal = RelationRouteScoring.outward(pair.target.name);
    const stub = 10.0;
    final sourceStub = _clamp(s + sourceNormal * stub, viewport);
    final targetStub = _clamp(t + targetNormal * stub, viewport);
    yield [s, sourceStub, targetStub, t];

    for (final offset in const [14.0, 28.0, 44.0, 64.0]) {
      final leftX =
          math.max(viewport.left + 4, math.min(s.dx, t.dx) - offset);
      final rightX =
          math.min(viewport.right - 4, math.max(s.dx, t.dx) + offset);
      yield [s, Offset(leftX, s.dy), Offset(leftX, t.dy), t];
      yield [s, Offset(rightX, s.dy), Offset(rightX, t.dy), t];
    }
  }

  static Offset _clamp(Offset p, Rect viewport) => Offset(
    p.dx.clamp(viewport.left + 1, viewport.right - 1).toDouble(),
    p.dy.clamp(viewport.top + 1, viewport.bottom - 1).toDouble(),
  );

  static List<Offset> _normalize(List<Offset> points) {
    final result = <Offset>[];
    for (final point in points) {
      if (result.isEmpty || (result.last - point).distance > .01) {
        result.add(point);
      }
      if (result.length >= 3 &&
          _sameDirection(
            result[result.length - 3], result[result.length - 2], result.last,
          )) {
        result.removeAt(result.length - 2);
      }
    }
    return result;
  }

  static bool _sameDirection(Offset a, Offset b, Offset c) {
    final ab = b - a, bc = c - b;
    return (ab.dx * bc.dy - ab.dy * bc.dx).abs() < .001;
  }
}
