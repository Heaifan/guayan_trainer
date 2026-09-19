import 'dart:ui';

import '../../domain/relation_type.dart';
import '../../domain/relations/relation_record.dart';
import 'relation_label_placer.dart';
import 'relation_obstacle_map.dart';
import 'relation_orthogonal_router.dart';
import 'relation_geometry.dart';

class RelationRenderPlan {
  const RelationRenderPlan({
    required this.routes,
    required this.records,
    required this.labels,
    required this.obstacleCount,
  });

  final List<RelationRoute> routes;
  final List<RelationRecord> records;
  final List<PlacedRelationLabel> labels;
  final int obstacleCount;
}

abstract final class RelationRenderPlanner {
  static RelationRenderPlan build({
    required Iterable<RelationRecord> records,
    required Map<String, Rect> bounds,
    required Map<String, Rect> anchorBounds,
    required Size viewportSize,
  }) {
    final obstacleMap = RelationObstacleMap.fromBounds(bounds);
    final routes = <RelationRoute>[];
    final routedRecords = <RelationRecord>[];
    final labels = <PlacedRelationLabel>[];
    final ordered = records.toList()..sort((a, b) => a.id.compareTo(b.id));
    for (final record in ordered) {
      if (record.relationType == RelationType.huiTouSheng ||
          record.relationType == RelationType.huiTouKe) {
        continue;
      }
      final sourceBounds = anchorBounds[record.fromRef?.semanticId];
      final targetBounds = anchorBounds[record.toRef?.semanticId];
      if (sourceBounds == null || targetBounds == null) continue;
      final route = RelationOrthogonalRouter.route(
        source: RelationAnchors.fromRect(sourceBounds),
        target: RelationAnchors.fromRect(targetBounds),
        obstacles: _withoutEndpoints(obstacleMap, record),
        viewport: Offset.zero & viewportSize,
      ).route;
      if (route == null) continue;
      final label = RelationLabelPlacer.place(
        route: route,
        text: record.relationType!.displayName,
        obstacles: _withoutEndpoints(obstacleMap, record),
        placedLabels: [for (final item in labels) item.bounds],
      );
      if (label == null) continue;
      routes.add(route);
      routedRecords.add(record);
      labels.add(label);
    }
    return RelationRenderPlan(
      routes: List.unmodifiable(routes),
      records: List.unmodifiable(routedRecords),
      labels: List.unmodifiable(labels),
      obstacleCount: obstacleMap.obstacles.length,
    );
  }

  static RelationObstacleMap _withoutEndpoints(
    RelationObstacleMap map,
    RelationRecord record,
  ) {
    final excluded = {
      record.fromRef?.semanticId,
      record.toRef?.semanticId,
    };
    return RelationObstacleMap([
      for (final obstacle in map.obstacles)
        if (!excluded.contains(obstacle.id)) obstacle,
    ]);
  }
}
