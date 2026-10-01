import 'dart:ui';
import '../../domain/relation_endpoint.dart';
import '../../domain/relation_type.dart';
import '../../domain/relations/relation_record.dart';
import 'relation_geometry.dart';
import 'relation_label_placer.dart';
import 'relation_label_visual.dart';
import 'relation_obstacle_map.dart';
import 'relation_orthogonal_router.dart';

class RelationRenderPlan {
  const RelationRenderPlan({
    required this.routes, required this.records, required this.labels,
    required this.obstacleCount, this.inputCount = 0, this.anchoredCount = 0,
    this.missingAnchorRecordIds = const [],
  });
  final List<RelationRoute> routes;
  final List<RelationRecord> records;
  final List<PlacedRelationLabel?> labels;
  final int obstacleCount, inputCount, anchoredCount;
  final List<String> missingAnchorRecordIds;
}

abstract final class RelationRenderPlanner {
  static RelationRenderPlan build({
    required Iterable<RelationRecord> records, required Map<String, Rect> bounds,
    required Map<String, Rect> anchorBounds, required Size viewportSize,
  }) {
    final obstacleMap = RelationObstacleMap.fromBounds(bounds);
    final routes = <RelationRoute>[], routedRecords = <RelationRecord>[];
    final labels = <PlacedRelationLabel?>[], missing = <String>[];
    final sourceSides = <String, double>{};
    final ordered = records.toList()..sort((a, b) => a.id.compareTo(b.id));
    final ordinary = ordered.where((r) =>
      r.relationType != RelationType.huiTouSheng &&
      r.relationType != RelationType.huiTouKe,
    ).toList();
    var anchored = 0, left = 0, right = 0;
    for (final record in ordinary) {
      final sourceId = record.fromRef?.semanticId ?? record.id;
      final source = anchorBounds[record.fromRef?.semanticId];
      final target = anchorBounds[record.toRef?.semanticId];
      if (source == null || target == null) {
        missing.add(record.id);
        continue;
      }
      anchored++;
      final prior = sourceSides[sourceId];
      final preferred = prior == null ? (left <= right ? -1.0 : 1.0) : -prior;
      final obstacles = _withoutEndpoints(obstacleMap, record);
      final occupied = [for (final item in labels) if (item != null) item.bounds];
      final route = RelationOrthogonalRouter.route(
        source: RelationAnchors.fromRect(source),
        target: RelationAnchors.fromRect(target), obstacles: obstacles,
        viewport: Offset.zero & viewportSize, preferredHorizontalSide: preferred,
        labelSize: RelationLabelVisual.sizeFor(record.relationType!.displayName),
        occupiedLabels: occupied,
      ).route;
      if (route == null) continue;
      final label = RelationLabelPlacer.place(
        route: route, text: record.relationType!.displayName,
        obstacles: obstacles, placedLabels: occupied,
      );
      routes.add(route);
      routedRecords.add(record);
      labels.add(label);
      sourceSides[sourceId] =
          route.horizontalSide == 0 ? preferred : route.horizontalSide;
      if (route.horizontalSide < 0) left++;
      if (route.horizontalSide > 0) right++;
    }
    return RelationRenderPlan(
      routes: List.unmodifiable(routes), records: List.unmodifiable(routedRecords),
      labels: List.unmodifiable(labels), obstacleCount: obstacleMap.obstacles.length,
      inputCount: ordinary.length, anchoredCount: anchored,
      missingAnchorRecordIds: List.unmodifiable(missing),
    );
  }

  static RelationObstacleMap _withoutEndpoints(
    RelationObstacleMap map, RelationRecord record,
  ) {
    final excluded = <String?>{
      record.fromRef?.semanticId, record.toRef?.semanticId,
      ..._endpointCellIds(record.fromRef), ..._endpointCellIds(record.toRef),
    };
    return RelationObstacleMap([
      for (final obstacle in map.obstacles)
        if (!excluded.contains(obstacle.id)) obstacle,
    ]);
  }

  static Iterable<String> _endpointCellIds(RelationEndpoint? endpoint) sync* {
    if (endpoint is! YaoEndpoint) return;
    yield endpoint.scope == LineScope.original
      ? 'main_line_cell_${endpoint.position}'
      : 'changed_line_cell_${endpoint.position}';
  }
}
