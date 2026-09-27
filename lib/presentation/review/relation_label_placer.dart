import 'package:flutter/painting.dart';

import 'relation_label_visual.dart';
import 'relation_obstacle_map.dart';
import 'relation_orthogonal_router.dart';
import 'relation_visual_tokens.dart';

class PlacedRelationLabel {
  const PlacedRelationLabel({
    required this.text,
    required this.bounds,
    required this.center,
    required this.route,
  });

  final String text;
  final Rect bounds;
  final Offset center;
  final RelationRoute route;
}

abstract final class RelationLabelPlacer {
  static PlacedRelationLabel? place({
    required RelationRoute route,
    required String text,
    required RelationObstacleMap obstacles,
    Iterable<Rect> placedLabels = const [],
  }) {
    final size = RelationLabelVisual.sizeFor(text);
    final occupied = [...placedLabels];
    final endpointGuards = [
      Rect.fromCircle(
        center: route.points.first,
        radius: RelationVisualTokens.relationLabelArrowClearance,
      ),
      Rect.fromCircle(
        center: route.points.last,
        radius: RelationVisualTokens.relationLabelArrowClearance,
      ),
    ];
    for (final center in _candidateCenters(route.points)) {
      final raw = Rect.fromCenter(
        center: center,
        width: size.width,
        height: size.height,
      );
      final safe = raw.inflate(RelationVisualTokens.safePadding);
      if (endpointGuards.any((guard) => guard.overlaps(safe))) continue;
      if (obstacles.obstacles.any((obstacle) => obstacle.bounds.overlaps(safe))) {
        continue;
      }
      if (occupied.any((label) => label.overlaps(safe))) continue;
      return PlacedRelationLabel(
        text: text,
        bounds: safe,
        center: center,
        route: route,
      );
    }
    return null;
  }

  static Iterable<Offset> _candidateCenters(List<Offset> points) sync* {
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final midpoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      final delta = end - start;
      final length = delta.distance;
      if (length == 0) continue;
      final normal = Offset(-delta.dy / length, delta.dx / length);
      yield midpoint + normal * 14;
      yield midpoint - normal * 14;
      yield midpoint + normal * 20;
      yield midpoint - normal * 20;
      yield midpoint;
    }
  }
}
