import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/relation_geometry.dart';
import 'package:guayan_trainer/presentation/review/relation_label_placer.dart';
import 'package:guayan_trainer/presentation/review/relation_obstacle_map.dart';
import 'package:guayan_trainer/presentation/review/relation_orthogonal_router.dart';
import 'package:guayan_trainer/presentation/review/relation_visual_tokens.dart';

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
    expect(placed.bounds.height, greaterThanOrEqualTo(12));
    expect(placed.bounds.overlaps(const Rect.fromLTWH(40, 75, 30, 18)), isFalse);
    expect(placed.bounds.overlaps(const Rect.fromLTWH(120, 100, 35, 24)), isFalse);

    final sourceGuard = Rect.fromCircle(
      center: route.points.first,
      radius: RelationVisualTokens.relationLabelArrowClearance,
    );
    final targetGuard = Rect.fromCircle(
      center: route.points.last,
      radius: RelationVisualTokens.relationLabelArrowClearance,
    );
    expect(placed.bounds.overlaps(sourceGuard), isFalse);
    expect(placed.bounds.overlaps(targetGuard), isFalse);
  });

  test('fully blocked board suppresses label instead of forcing overlap', () {
    final path = Path()
      ..moveTo(200, 120)
      ..lineTo(220, 120)
      ..lineTo(220, 40)
      ..lineTo(200, 40);
    final route = RelationRoute(
      sourceAnchor: const RelationAnchor(
        name: RelationAnchorName.e,
        point: Offset(200, 120),
      ),
      targetAnchor: const RelationAnchor(
        name: RelationAnchorName.e,
        point: Offset(200, 40),
      ),
      points: const [
        Offset(200, 120),
        Offset(220, 120),
        Offset(220, 40),
        Offset(200, 40),
      ],
      path: path,
      length: 120,
      bendCount: 2,
      cost: 176,
    );
    final placed = RelationLabelPlacer.place(
      route: route,
      text: '生',
      obstacles: RelationObstacleMap.fromBounds({
        'board': const Rect.fromLTWH(0, 0, 400, 200),
      }),
    );
    expect(placed, isNull);
  });
}
