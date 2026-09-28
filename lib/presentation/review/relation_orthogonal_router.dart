import 'dart:ui';

import 'relation_geometry.dart';
import 'relation_obstacle_map.dart';
import 'routing/relation_bezier_path.dart';
import 'routing/relation_route_candidates.dart';

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
      for (final points in RelationRouteCandidates.forPair(pair, viewport)) {
        if (!obstacles.isClearPath(points)) continue;
        final path = RelationBezierPath.build(points, viewport);
        if (!obstacles.isClearPath(RelationBezierPath.sample(path))) continue;
        final length = RelationRouteCandidates.length(points);
        final bends = points.length > 2 ? points.length - 2 : 0;
        candidates.add(RelationRoute(
          sourceAnchor: pair.source,
          targetAnchor: pair.target,
          points: points,
          path: path,
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
