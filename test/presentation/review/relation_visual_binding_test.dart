import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/presentation/review/relation_render_plan.dart';
import 'package:guayan_trainer/presentation/review/routing/relation_bezier_path.dart';

void main() {
  test('普通生克标签中心始终贴在所属曲线上', () {
    final plan = _twoSiblingRoutes();
    expect(plan.labels.whereType<Object>(), hasLength(2));
    for (var i = 0; i < plan.routes.length; i++) {
      final label = plan.labels[i]!;
      final samples = RelationBezierPath.sample(plan.routes[i].path, step: .4);
      final distance = samples
          .map((point) => (point - label.center).distance)
          .reduce(math.min);
      expect(distance, lessThan(.7));
    }
  });

  test('有空白绕行空间时，路由为标签选择可放置路径', () {
    final record = RelationRecord.relation(
      id: 'ke-label-clearance', sourceKind: RelationSourceKind.fact,
      relationType: RelationType.ke,
      fromRef: YaoEndpoint(LineScope.original, 2),
      toRef: YaoEndpoint(LineScope.original, 4), title: '克',
    );
    const anchors = {
      'yao:original:2': Rect.fromLTWH(140, 170, 64, 16),
      'yao:original:4': Rect.fromLTWH(140, 70, 64, 16),
    };
    final plan = RelationRenderPlanner.build(
      records: [record],
      bounds: const {
        'main_nayin_obstacle_3': Rect.fromLTWH(118, 100, 80, 28),
      },
      anchorBounds: anchors, viewportSize: const Size(402, 270),
    );
    expect(plan.routes, hasLength(1));
    expect(plan.labels.single, isNotNull);
  });

  test('同一来源的多条关系优先向相反两侧分叉', () {
    final plan = _twoSiblingRoutes();
    expect(plan.routes, hasLength(2));
    expect(plan.routes.map((route) => route.horizontalSide).toSet(), {-1.0, 1.0});
  });
}

RelationRenderPlan _twoSiblingRoutes() {
  final records = [
    RelationRecord.relation(
      id: 'a-ke-2-3', sourceKind: RelationSourceKind.fact,
      relationType: RelationType.ke,
      fromRef: YaoEndpoint(LineScope.original, 2),
      toRef: YaoEndpoint(LineScope.original, 3), title: '克',
    ),
    RelationRecord.relation(
      id: 'b-ke-2-4', sourceKind: RelationSourceKind.fact,
      relationType: RelationType.ke,
      fromRef: YaoEndpoint(LineScope.original, 2),
      toRef: YaoEndpoint(LineScope.original, 4), title: '克',
    ),
  ];
  const anchors = {
    'yao:original:2': Rect.fromLTWH(140, 170, 64, 16),
    'yao:original:3': Rect.fromLTWH(140, 120, 64, 16),
    'yao:original:4': Rect.fromLTWH(140, 70, 64, 16),
  };
  return RelationRenderPlanner.build(
    records: records, bounds: const {}, anchorBounds: anchors,
    viewportSize: const Size(402, 270),
  );
}
