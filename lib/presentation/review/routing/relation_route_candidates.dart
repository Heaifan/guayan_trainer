import 'dart:math' as math;
import 'dart:ui';

import '../relation_geometry.dart';

abstract final class RelationRouteCandidates {
  static Iterable<List<Offset>> forPair(
    AnchorPair pair,
    Rect viewport,
  ) sync* {
    for (final points in _raw(pair, viewport)) {
      final normalized = _normalize(points);
      if (normalized.length >= 2) yield normalized;
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
    AnchorPair pair,
    Rect viewport,
  ) sync* {
    final source = pair.source.point;
    final target = pair.target.point;
    yield [source, Offset(target.dx, source.dy), target];
    yield [source, Offset(source.dx, target.dy), target];
    final left = math.max(
      viewport.left + 12,
      math.min(source.dx, target.dx) - 20,
    );
    final right = math.min(
      viewport.right - 12,
      math.max(source.dx, target.dx) + 20,
    );
    yield [source, Offset(left, source.dy), Offset(left, target.dy), target];
    yield [source, Offset(right, source.dy), Offset(right, target.dy), target];
    final top = math.max(
      viewport.top + 12,
      math.min(source.dy, target.dy) - 20,
    );
    final bottom = math.min(
      viewport.bottom - 12,
      math.max(source.dy, target.dy) + 20,
    );
    yield [source, Offset(source.dx, top), Offset(target.dx, top), target];
    yield [source, Offset(source.dx, bottom), Offset(target.dx, bottom), target];
  }

  static List<Offset> _normalize(List<Offset> points) {
    final result = <Offset>[];
    for (final point in points) {
      if (result.isEmpty || result.last != point) result.add(point);
      if (result.length >= 3 &&
          _sameDirection(
            result[result.length - 3],
            result[result.length - 2],
            point,
          )) {
        result.removeAt(result.length - 2);
      }
    }
    return result;
  }

  static bool _sameDirection(Offset a, Offset b, Offset c) =>
      (b.dx - a.dx) * (c.dy - b.dy) ==
      (b.dy - a.dy) * (c.dx - b.dx);
}
