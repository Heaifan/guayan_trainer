import 'dart:ui';

import '../relation_obstacle_map.dart';
import '../relation_visual_tokens.dart';
import 'relation_label_candidates.dart';

abstract final class RelationLabelRouteScore {
  static const unavailablePenalty = 1200.0;

  static double penalty({
    required Path path,
    required Size? labelSize,
    required RelationObstacleMap obstacles,
    Iterable<Rect> occupiedLabels = const [],
  }) {
    if (labelSize == null) return 0;
    final occupied = occupiedLabels.toList(growable: false);
    for (final center in RelationLabelCandidates.centers(path)) {
      final bounds = Rect.fromCenter(
        center: center,
        width: labelSize.width,
        height: labelSize.height,
      ).inflate(1);
      final blocked = obstacles.obstacles.any(
        (obstacle) => obstacle.bounds
            .deflate(RelationVisualTokens.safePadding)
            .overlaps(bounds),
      );
      if (!blocked && !occupied.any((item) => item.overlaps(bounds))) return 0;
    }
    return unavailablePenalty;
  }
}
