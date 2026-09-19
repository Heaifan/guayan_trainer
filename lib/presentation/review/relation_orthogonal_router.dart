import 'dart:math' as math;
import 'dart:ui';

import 'relation_geometry.dart';
import 'relation_obstacle_map.dart';

class RelationRouteResult {
  const RelationRouteResult.route(this.route);
  const RelationRouteResult.noRoute() : route = null;

  final RelationRoute? route;
  bool get isNoRoute => route == null;
}

class RelationRoute {
  RelationRoute({
    required this.sourceAnchor,
    required this.targetAnchor,
    required List<Offset> points,
    required this.path,
    required this.length,
    required this.bendCount,
    required this.cost,
  }) : points = List.unmodifiable(points);

  final RelationAnchor sourceAnchor;
  final RelationAnchor targetAnchor;
  final List<Offset> points;
  final Path path;
  final double length;
  final int bendCount;
  final double cost;
}

abstract final class RelationOrthogonalRouter {
  static const _bendPenalty = 28.0;

  static RelationRouteResult route({
    required RelationAnchors source,
    required RelationAnchors target,
    required RelationObstacleMap obstacles,
    required Rect viewport,
  }) {
    final candidates = <RelationRoute>[];
    for (final pair in AnchorPairCandidates.forNodes(source, target)) {
      for (final points in _candidatePoints(pair, viewport)) {
        final normalized = _normalize(points);
        if (normalized.length < 2 || !obstacles.isClearPath(normalized)) {
          continue;
        }
        final length = _length(normalized);
        final bends = math.max(0, normalized.length - 2);
        candidates.add(RelationRoute(
          sourceAnchor: pair.source,
          targetAnchor: pair.target,
          points: normalized,
          path: _roundedPath(normalized),
          length: length,
          bendCount: bends,
          cost: length +
              bends * _bendPenalty +
              _anchorDirectionPenalty(pair.source.name) +
              _anchorDirectionPenalty(pair.target.name),
        ));
      }
    }
    if (candidates.isEmpty) return const RelationRouteResult.noRoute();
    candidates.sort(_compareRoutes);
    return RelationRouteResult.route(candidates.first);
  }

  static Iterable<List<Offset>> _candidatePoints(
    AnchorPair pair,
    Rect viewport,
  ) sync* {
    final source = pair.source.point;
    final target = pair.target.point;
    yield [source, Offset(target.dx, source.dy), target];
    yield [source, Offset(source.dx, target.dy), target];
    final left = math.max(viewport.left + 12, math.min(source.dx, target.dx) - 20);
    final right = math.min(viewport.right - 12, math.max(source.dx, target.dx) + 20);
    yield [source, Offset(left, source.dy), Offset(left, target.dy), target];
    yield [source, Offset(right, source.dy), Offset(right, target.dy), target];
    final top = math.max(viewport.top + 12, math.min(source.dy, target.dy) - 20);
    final bottom = math.min(viewport.bottom - 12, math.max(source.dy, target.dy) + 20);
    yield [source, Offset(source.dx, top), Offset(target.dx, top), target];
    yield [source, Offset(source.dx, bottom), Offset(target.dx, bottom), target];
  }

  static List<Offset> _normalize(List<Offset> points) {
    final result = <Offset>[];
    for (final point in points) {
      if (result.isEmpty || result.last != point) result.add(point);
      if (result.length >= 3 &&
          _sameDirection(result[result.length - 3], result[result.length - 2], point)) {
        result.removeAt(result.length - 2);
      }
    }
    return result;
  }

  static bool _sameDirection(Offset a, Offset b, Offset c) =>
      (b.dx - a.dx) * (c.dy - b.dy) ==
          (b.dy - a.dy) * (c.dx - b.dx);

  static double _length(List<Offset> points) {
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += (points[i + 1] - points[i]).distance;
    }
    return total;
  }

  static Path _roundedPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final before = points[i - 1];
      final corner = points[i];
      final after = points[i + 1];
      final radius = math.min(6.0, math.min((corner - before).distance / 2,
          (after - corner).distance / 2));
      final inPoint = corner + (before - corner) / (corner - before).distance * radius;
      final outPoint = corner + (after - corner) / (after - corner).distance * radius;
      path.lineTo(inPoint.dx, inPoint.dy);
      path.quadraticBezierTo(corner.dx, corner.dy, outPoint.dx, outPoint.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  static int _compareRoutes(RelationRoute a, RelationRoute b) {
    final cost = a.cost.compareTo(b.cost);
    if (cost != 0) return cost;
    final anchors = a.sourceAnchor.name.index.compareTo(b.sourceAnchor.name.index);
    if (anchors != 0) return anchors;
    return a.targetAnchor.name.index.compareTo(b.targetAnchor.name.index);
  }

  static double _anchorDirectionPenalty(RelationAnchorName name) => switch (name) {
    RelationAnchorName.n || RelationAnchorName.s => 0,
    RelationAnchorName.nw ||
    RelationAnchorName.ne ||
    RelationAnchorName.sw ||
    RelationAnchorName.se => 6,
    RelationAnchorName.w || RelationAnchorName.e => 12,
  };
}
