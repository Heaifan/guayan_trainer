import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/relation_geometry.dart';
import 'package:guayan_trainer/presentation/review/relation_obstacle_map.dart';
import 'package:guayan_trainer/presentation/review/relation_orthogonal_router.dart';
import 'package:guayan_trainer/presentation/review/routing/relation_bezier_path.dart';

void main() {

  test('hidden-area penalty beats preferred side when clear space exists', () {
    final source = RelationAnchors.fromRect(
      const Rect.fromLTWH(100, 180, 60, 20),
    );
    final target = RelationAnchors.fromRect(
      const Rect.fromLTWH(100, 20, 60, 20),
    );
    final obstacles = RelationObstacleMap.fromBounds({
      'legacy_hidden_slot_3_0': const Rect.fromLTWH(40, 55, 70, 110),
    });
    final route = RelationOrthogonalRouter.route(
      source: source,
      target: target,
      obstacles: obstacles,
      viewport: const Rect.fromLTWH(0, 0, 260, 220),
      preferredHorizontalSide: -1,
    ).route!;

    expect(
      obstacles.isClearPath(RelationBezierPath.sample(route.path)),
      isTrue,
    );
  });


  test('direct route can prefer either screen side without changing anchors', () {
    final source = RelationAnchors.fromRect(
      const Rect.fromLTWH(80, 170, 60, 20),
    );
    final target = RelationAnchors.fromRect(
      const Rect.fromLTWH(80, 20, 60, 20),
    );
    final left = RelationOrthogonalRouter.route(
      source: source,
      target: target,
      obstacles: RelationObstacleMap(const []),
      viewport: const Rect.fromLTWH(0, 0, 220, 220),
      preferredHorizontalSide: -1,
    ).route!;
    final right = RelationOrthogonalRouter.route(
      source: source,
      target: target,
      obstacles: RelationObstacleMap(const []),
      viewport: const Rect.fromLTWH(0, 0, 220, 220),
      preferredHorizontalSide: 1,
    ).route!;
    expect(left.horizontalSide, -1);
    expect(right.horizontalSide, 1);
    expect(left.sourceAnchor.name, right.sourceAnchor.name);
    expect(left.targetAnchor.name, right.targetAnchor.name);
  });

  test('ordinary relations only use left/right text anchors', () {
    final source = RelationAnchors.fromRect(
      const Rect.fromLTWH(100, 200, 60, 24),
    );
    final target = RelationAnchors.fromRect(
      const Rect.fromLTWH(100, 20, 60, 24),
    );
    final obstacles = RelationObstacleMap.fromBounds({
      'line-4': const Rect.fromLTWH(92, 150, 76, 24),
      'line-5': const Rect.fromLTWH(92, 105, 76, 24),
      'nayin': const Rect.fromLTWH(92, 60, 76, 24),
    });

    final result = RelationOrthogonalRouter.route(
      source: source,
      target: target,
      obstacles: obstacles,
      viewport: const Rect.fromLTWH(0, 0, 260, 240),
    );

    expect(result.isNoRoute, isFalse);
    final route = result.route!;
    expect(
      route.sourceAnchor.name,
      isIn([RelationAnchorName.w, RelationAnchorName.e]),
    );
    expect(
      route.targetAnchor.name,
      isIn([RelationAnchorName.w, RelationAnchorName.e]),
    );
    expect(
      route.sourceAnchor.name,
      isNot(isIn([
        RelationAnchorName.n,
        RelationAnchorName.s,
        RelationAnchorName.sw,
        RelationAnchorName.se,
      ])),
    );
    expect(route.length, greaterThan(0));
  });

  test('facing side anchors win for a short cross-column relation', () {
    final source = RelationAnchors.fromRect(
      const Rect.fromLTWH(20, 80, 40, 20),
    );
    final target = RelationAnchors.fromRect(
      const Rect.fromLTWH(120, 80, 40, 20),
    );

    final result = RelationOrthogonalRouter.route(
      source: source,
      target: target,
      obstacles: RelationObstacleMap(const []),
      viewport: const Rect.fromLTWH(0, 0, 220, 180),
    );

    expect(result.isNoRoute, isFalse);
    expect(result.route!.sourceAnchor.name, RelationAnchorName.e);
    expect(result.route!.targetAnchor.name, RelationAnchorName.w);
    expect(result.route!.points, hasLength(2));
  });

  test('protected elements are soft costs and never delete an anchored relation', () {
    final source = RelationAnchors.fromRect(
      const Rect.fromLTWH(40, 90, 40, 20),
    );
    final target = RelationAnchors.fromRect(
      const Rect.fromLTWH(40, 20, 40, 20),
    );
    final obstacles = RelationObstacleMap.fromBounds({
      'full-wall': const Rect.fromLTWH(0, 0, 140, 130),
    });

    final result = RelationOrthogonalRouter.route(
      source: source,
      target: target,
      obstacles: obstacles,
      viewport: const Rect.fromLTWH(0, 0, 140, 130),
    );

    expect(result.isNoRoute, isFalse);
    expect(result.route, isNotNull);
    expect(obstacles.intersectionCount(result.route!.points), greaterThan(0));
  });

  test('same input produces the same selected anchors and points', () {
    final source = RelationAnchors.fromRect(
      const Rect.fromLTWH(30, 120, 40, 20),
    );
    final target = RelationAnchors.fromRect(
      const Rect.fromLTWH(120, 20, 40, 20),
    );
    final obstacles = RelationObstacleMap.fromBounds({
      'center': const Rect.fromLTWH(60, 50, 70, 20),
    });
    final results = [
      for (var i = 0; i < 5; i++)
        RelationOrthogonalRouter.route(
          source: source,
          target: target,
          obstacles: obstacles,
          viewport: const Rect.fromLTWH(0, 0, 200, 160),
        ),
    ];

    expect(
      results.map((result) => result.route?.points.join('|')).toSet(),
      hasLength(1),
    );
    expect(
      results.map((result) => result.route?.sourceAnchor.name).toSet(),
      hasLength(1),
    );
    expect(
      results.map((result) => result.route?.targetAnchor.name).toSet(),
      hasLength(1),
    );
  });
}
