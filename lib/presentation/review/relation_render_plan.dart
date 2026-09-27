import 'dart:ui';

import '../../domain/relation_endpoint.dart';
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
    this.inputCount = 0,
    this.anchoredCount = 0,
    this.missingAnchorRecordIds = const [],
  });

  final List<RelationRoute> routes;
  final List<RelationRecord> records;
  final List<PlacedRelationLabel> labels;
  final int obstacleCount;

  /// 普通生克进入 Router 的数量（回头关系由专用 glyph 绘制）。
  final int inputCount;

  /// Source / Target 锚点都已取得真实 RenderBox 的数量。
  final int anchoredCount;

  /// 唯一允许导致普通关系暂时不能绘制的原因：布局尚未提供锚点。
  final List<String> missingAnchorRecordIds;
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
    final missingAnchors = <String>[];

    final ordered = records.toList()..sort((a, b) => a.id.compareTo(b.id));
    final ordinary = [
      for (final record in ordered)
        if (record.relationType != RelationType.huiTouSheng &&
            record.relationType != RelationType.huiTouKe)
          record,
    ];

    var anchoredCount = 0;
    for (final record in ordinary) {
      final sourceBounds = anchorBounds[record.fromRef?.semanticId];
      final targetBounds = anchorBounds[record.toRef?.semanticId];
      if (sourceBounds == null || targetBounds == null) {
        missingAnchors.add(record.id);
        continue;
      }
      anchoredCount++;

      final softObstacles = _withoutEndpoints(obstacleMap, record);
      final route = RelationOrthogonalRouter.route(
        source: RelationAnchors.fromRect(sourceBounds),
        target: RelationAnchors.fromRect(targetBounds),
        obstacles: softObstacles,
        viewport: Offset.zero & viewportSize,
      ).route;

      // V2 Router 允许穿越保护区；只要锚点存在就应该能得到路线。
      // 保留 null 防御，避免异常几何把 Painter 整体打崩。
      if (route == null) continue;

      final label = RelationLabelPlacer.place(
        route: route,
        text: record.relationType!.displayName,
        obstacles: softObstacles,
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
      inputCount: ordinary.length,
      anchoredCount: anchoredCount,
      missingAnchorRecordIds: List.unmodifiable(missingAnchors),
    );
  }

  static RelationObstacleMap _withoutEndpoints(
    RelationObstacleMap map,
    RelationRecord record,
  ) {
    final excluded = <String?>{
      record.fromRef?.semanticId,
      record.toRef?.semanticId,
      ..._endpointCellObstacleIds(record.fromRef),
      ..._endpointCellObstacleIds(record.toRef),
    };
    return RelationObstacleMap([
      for (final obstacle in map.obstacles)
        if (!excluded.contains(obstacle.id)) obstacle,
    ]);
  }

  static Iterable<String> _endpointCellObstacleIds(
    RelationEndpoint? endpoint,
  ) sync* {
    if (endpoint is! YaoEndpoint) return;
    yield switch (endpoint.scope) {
      LineScope.original => 'main_line_cell_${endpoint.position}',
      LineScope.changed => 'changed_line_cell_${endpoint.position}',
    };
  }
}
