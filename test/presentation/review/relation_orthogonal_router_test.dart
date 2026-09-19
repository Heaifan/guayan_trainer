import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/relation_geometry.dart';
import 'package:guayan_trainer/presentation/review/relation_obstacle_map.dart';
import 'package:guayan_trainer/presentation/review/relation_orthogonal_router.dart';

void main() {
  test('Golden Case routes three-line earth to six-line water around obstacles', () {
    final source = RelationAnchors.fromRect(Rect.fromLTWH(100, 200, 60, 24));
    final target = RelationAnchors.fromRect(Rect.fromLTWH(100, 20, 60, 24));
    final obstacles = RelationObstacleMap.fromBounds({
      'line-4': Rect.fromLTWH(92, 150, 76, 24),
      'line-5': Rect.fromLTWH(92, 105, 76, 24),
      'nayin': Rect.fromLTWH(92, 60, 76, 24),
    });

    final result = RelationOrthogonalRouter.route(
      source: source,
      target: target,
      obstacles: obstacles,
      viewport: const Rect.fromLTWH(0, 0, 260, 240),
    );

    expect(result.isNoRoute, isFalse);
    final route = result.route!;
    expect(route.sourceAnchor.name, isIn([
      RelationAnchorName.n,
      RelationAnchorName.nw,
      RelationAnchorName.ne,
    ]));
    expect(route.targetAnchor.name, isIn([
      RelationAnchorName.s,
      RelationAnchorName.sw,
      RelationAnchorName.se,
    ]));
    expect(route.bendCount, lessThanOrEqualTo(2));
    expect(route.length, lessThan(500));
    expect(route.points.length, greaterThanOrEqualTo(3));
    expect(obstacles.isClearPath(route.points), isTrue);
    expect(route.path.toString(), isNot(contains('cubic')));
  });

  test('all illegal candidates return NoRoute instead of an unsafe fallback', () {
    final source = RelationAnchors.fromRect(Rect.fromLTWH(40, 80, 40, 20));
    final target = RelationAnchors.fromRect(Rect.fromLTWH(40, 20, 40, 20));
    final obstacles = RelationObstacleMap.fromBounds({
      'block-left': Rect.fromLTWH(0, 0, 60, 120),
      'block-right': Rect.fromLTWH(60, 0, 80, 120),
    });

    final result = RelationOrthogonalRouter.route(
      source: source,
      target: target,
      obstacles: obstacles,
      viewport: const Rect.fromLTWH(0, 0, 140, 120),
    );

    expect(result.isNoRoute, isTrue);
    expect(result.route, isNull);
  });

  test('same input produces the same selected anchors and points', () {
    final source = RelationAnchors.fromRect(Rect.fromLTWH(30, 120, 40, 20));
    final target = RelationAnchors.fromRect(Rect.fromLTWH(120, 20, 40, 20));
    final obstacles = RelationObstacleMap.fromBounds({
      'center': Rect.fromLTWH(60, 50, 70, 20),
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
  });
}
