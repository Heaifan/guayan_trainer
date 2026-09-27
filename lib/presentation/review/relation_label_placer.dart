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
    final candidates = _candidateCenters(route.points).toList();

    // 第一轮：严格避障。
    for (final center in candidates) {
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

    // 第二轮：真实卦盘中央走廊较窄，严格 5dp 双向安全区会把所有标签判死。
    // 回退到“实际可见矩形 + 1dp”避障，但仍严格避开箭头端点与已有标签。
    for (final center in candidates) {
      final raw = Rect.fromCenter(
        center: center,
        width: size.width,
        height: size.height,
      );
      final relaxed = raw.inflate(1);
      if (endpointGuards.any((guard) => guard.overlaps(relaxed))) continue;
      if (obstacles.obstacles.any((obstacle) =>
          obstacle.bounds
              .deflate(RelationVisualTokens.safePadding)
              .overlaps(relaxed))) {
        continue;
      }
      if (occupied.any((label) => label.overlaps(relaxed))) continue;
      return PlacedRelationLabel(
        text: text,
        bounds: relaxed,
        center: center,
        route: route,
      );
    }

    // 标签空间不足不能反过来让“关系线消失”。最后使用最长线段中点；
    // 胶囊底色负责与线条分离，箭头端点仍由上面的 guard 保护。
    var bestStart = route.points.first;
    var bestEnd = route.points.last;
    var bestLength = -1.0;
    for (var i = 0; i < route.points.length - 1; i++) {
      final start = route.points[i];
      final end = route.points[i + 1];
      final length = (end - start).distance;
      if (length > bestLength) {
        bestLength = length;
        bestStart = start;
        bestEnd = end;
      }
    }
    final center = Offset(
      (bestStart.dx + bestEnd.dx) / 2,
      (bestStart.dy + bestEnd.dy) / 2,
    );
    final fallback = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    return PlacedRelationLabel(
      text: text,
      bounds: fallback,
      center: center,
      route: route,
    );
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
