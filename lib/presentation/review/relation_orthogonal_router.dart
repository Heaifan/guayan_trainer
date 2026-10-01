import 'dart:ui';

import 'relation_geometry.dart';
import 'relation_obstacle_map.dart';
import 'routing/relation_bezier_path.dart';
import 'routing/relation_route_candidates.dart';
import 'routing/relation_route_scoring.dart';

class RelationRouteResult {
  const RelationRouteResult.route(this.route);
  const RelationRouteResult.noRoute() : route = null;
  final RelationRoute? route;
  bool get isNoRoute => route == null;
}

class RelationRoute {
  RelationRoute({
    required this.sourceAnchor, required this.targetAnchor,
    required List<Offset> points, required this.path,
    required this.length, required this.bendCount, required this.cost,
    this.horizontalSide = 0,
  }) : points = List.unmodifiable(points);
  final RelationAnchor sourceAnchor;
  final RelationAnchor targetAnchor;
  final List<Offset> points;
  final Path path;
  final double length, cost, horizontalSide;
  final int bendCount;
}

abstract final class RelationOrthogonalRouter {
  static const _bendPenalty = 10.0;
  static const _sidePreferencePenalty = 14.0;

  static RelationRouteResult route({
    required RelationAnchors source,
    required RelationAnchors target,
    required RelationObstacleMap obstacles,
    required Rect viewport,
    double preferredHorizontalSide = 0,
  }) {
    final candidates = <RelationRoute>[];
    for (final pair in AnchorPairCandidates.ordinary(source, target)) {
      for (final points in RelationRouteCandidates.forPair(pair, viewport)) {
        final sides = points.length == 2
            ? const [-1.0, 1.0]
            : [_routeSide(points)];
        for (final side in sides) {
          final path = RelationBezierPath.build(
            points, viewport, directHorizontalSide: side == 0 ? -1 : side,
          );
          final length = RelationRouteCandidates.length(points);
          final bends = points.length > 2 ? points.length - 2 : 0;
          final routePoints = RelationBezierPath.sample(path);
          final avoidance = obstacles.routingPenalty(routePoints);
          final direction =
              RelationRouteScoring.endpointDirectionPenalty(pair, points);
          final sideCost = preferredHorizontalSide != 0 &&
                  side != 0 && side != preferredHorizontalSide
              ? _sidePreferencePenalty : 0.0;
          candidates.add(RelationRoute(
            sourceAnchor: pair.source, targetAnchor: pair.target,
            points: points, path: path, length: length, bendCount: bends,
            horizontalSide: side,
            cost: length + bends * _bendPenalty +
                avoidance + direction + sideCost,
          ));
        }
      }
    }
    if (candidates.isEmpty) return const RelationRouteResult.noRoute();
    candidates.sort(_compareRoutes);
    return RelationRouteResult.route(candidates.first);
  }

  static double _routeSide(List<Offset> points) {
    if (points.length < 3) return 0;
    final directX = (points.first.dx + points.last.dx) / 2;
    final interior = points.sublist(1, points.length - 1);
    final interiorX =
        interior.map((p) => p.dx).reduce((a, b) => a + b) / interior.length;
    final delta = interiorX - directX;
    return delta.abs() < .5 ? 0 : delta.sign;
  }

  static int _compareRoutes(RelationRoute a, RelationRoute b) {
    final cost = a.cost.compareTo(b.cost);
    if (cost != 0) return cost;
    final bends = a.bendCount.compareTo(b.bendCount);
    if (bends != 0) return bends;
    final anchors =
        a.sourceAnchor.name.index.compareTo(b.sourceAnchor.name.index);
    if (anchors != 0) return anchors;
    return a.targetAnchor.name.index.compareTo(b.targetAnchor.name.index);
  }
}
