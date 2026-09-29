import 'package:flutter/painting.dart';

export 'routing/relation_label_model.dart';

import 'relation_label_visual.dart';
import 'relation_obstacle_map.dart';
import 'relation_orthogonal_router.dart';
import 'relation_visual_tokens.dart';
import 'routing/relation_label_candidates.dart';
import 'routing/relation_label_model.dart';

abstract final class RelationLabelPlacer {
  static PlacedRelationLabel? place({
    required RelationRoute route,
    required String text,
    required RelationObstacleMap obstacles,
    Iterable<Rect> placedLabels = const [],
  }) {
    final size = RelationLabelVisual.sizeFor(text);
    final occupied = [...placedLabels];
    final guards = [
      Rect.fromCircle(
        center: route.points.first,
        radius: RelationVisualTokens.relationLabelArrowClearance,
      ),
      Rect.fromCircle(
        center: route.points.last,
        radius: RelationVisualTokens.relationLabelArrowClearance,
      ),
    ];
    final candidates = RelationLabelCandidates.centers(route).toList();
    final strict = _find(
      candidates, size, guards, obstacles, occupied,
      padding: RelationVisualTokens.safePadding,
      deflateObstacles: false,
    );
    if (strict != null) return _placed(text, route, strict.$1, strict.$2);

    final relaxed = _find(
      candidates, size, guards, obstacles, occupied,
      padding: 1,
      deflateObstacles: true,
    );
    if (relaxed != null) return _placed(text, route, relaxed.$1, relaxed.$2);

    return null;
  }

  static (Offset, Rect)? _find(
    Iterable<Offset> candidates,
    Size size,
    List<Rect> guards,
    RelationObstacleMap obstacles,
    List<Rect> occupied, {
    required double padding,
    required bool deflateObstacles,
  }) {
    for (final center in candidates) {
      final raw = Rect.fromCenter(
        center: center,
        width: size.width,
        height: size.height,
      );
      final bounds = raw.inflate(padding);
      if (guards.any((guard) => guard.overlaps(bounds))) continue;
      final blocked = obstacles.obstacles.any((obstacle) {
        final rect = deflateObstacles
            ? obstacle.bounds.deflate(RelationVisualTokens.safePadding)
            : obstacle.bounds;
        return rect.overlaps(bounds);
      });
      if (blocked || occupied.any((label) => label.overlaps(bounds))) continue;
      return (center, bounds);
    }
    return null;
  }

  static PlacedRelationLabel _placed(
    String text,
    RelationRoute route,
    Offset center,
    Rect bounds,
  ) => PlacedRelationLabel(
        text: text,
        bounds: bounds,
        center: center,
        route: route,
      );
}
