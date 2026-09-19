import 'package:flutter/painting.dart';

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
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: RelationVisualTokens.relationLabelFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final size = Size(painter.width + 12, RelationVisualTokens.relationLabelHeight);
    final occupied = [...placedLabels];
    for (final center in _candidateCenters(route.points)) {
      final raw = Rect.fromCenter(center: center, width: size.width, height: size.height);
      final safe = raw.inflate(RelationVisualTokens.safePadding);
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
      yield midpoint + normal * 12;
      yield midpoint - normal * 12;
      yield midpoint;
    }
  }
}
