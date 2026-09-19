import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/relation_geometry.dart';
import 'package:guayan_trainer/presentation/review/relation_label_placer.dart';
import 'package:guayan_trainer/presentation/review/relation_obstacle_map.dart';
import 'package:guayan_trainer/presentation/review/relation_orthogonal_router.dart';

void main() {
  test('label uses measured text bounds and avoids obstacles and prior labels', () {
    final route = RelationOrthogonalRouter.route(
      source: RelationAnchors.fromRect(const Rect.fromLTWH(20, 120, 40, 20)),
      target: RelationAnchors.fromRect(const Rect.fromLTWH(120, 20, 40, 20)),
      obstacles: RelationObstacleMap.fromBounds({
        'center': const Rect.fromLTWH(60, 50, 70, 20),
      }),
      viewport: const Rect.fromLTWH(0, 0, 200, 160),
    ).route!;

    final placed = RelationLabelPlacer.place(
      route: route,
      text: '克',
      obstacles: RelationObstacleMap.fromBounds({
        'text': const Rect.fromLTWH(40, 75, 30, 18),
      }),
      placedLabels: [const Rect.fromLTWH(120, 100, 35, 24)],
    );

    expect(placed, isNotNull);
    expect(placed!.text, '克');
    expect(placed.bounds.width, greaterThan(12));
    expect(placed.bounds.height, greaterThan(16));
    expect(placed.bounds.overlaps(const Rect.fromLTWH(40, 75, 30, 18)), isFalse);
    expect(placed.bounds.overlaps(const Rect.fromLTWH(120, 100, 35, 24)), isFalse);
  });
}
