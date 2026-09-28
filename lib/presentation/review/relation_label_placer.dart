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
    for (final center in _candidateCenters(route)) {
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

  static Iterable<Offset> _candidateCenters(RelationRoute route) sync* {
    final metrics = route.path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    for (final fraction in const [.50, .35, .65, .20, .80]) {
      final tangent = metric.getTangentForOffset(metric.length * fraction);
      if (tangent == null || tangent.vector.distance == 0) continue;
      final vector = tangent.vector;
      final normal = Offset(
        -vector.dy / vector.distance,
        vector.dx / vector.distance,
      );
      yield tangent.position + normal * 12;
      yield tangent.position - normal * 12;
      yield tangent.position;
    }
  }
}
