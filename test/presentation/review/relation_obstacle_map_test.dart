import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/relation_obstacle_map.dart';
import 'package:guayan_trainer/presentation/review/relation_visual_tokens.dart';

void main() {
  test('visible board bounds become inflated hard obstacles', () {
    final map = RelationObstacleMap.fromBounds({
      'main-nayin': Rect.fromLTWH(40, 40, 40, 20),
      'shi-ying': Rect.fromLTWH(100, 40, 20, 20),
      'yao-body': Rect.fromLTWH(140, 40, 24, 20),
      'relation-label': Rect.fromLTWH(180, 40, 30, 18),
    });

    expect(map.obstacles, hasLength(4));
    expect(map.obstacleFor('main-nayin')!.bounds.left,
        40 - RelationVisualTokens.safePadding);
    expect(map.isClearSegment(const Offset(20, 50), const Offset(80, 50)), isFalse);
    expect(map.isClearSegment(const Offset(20, 20), const Offset(80, 20)), isTrue);
  });

  test('a path touching an inflated obstacle is invalid', () {
    final map = RelationObstacleMap.fromBounds({
      'text': const Rect.fromLTWH(40, 40, 40, 20),
    });

    expect(map.isClearSegment(const Offset(20, 35), const Offset(100, 35)), isFalse);
    expect(map.isClearPath(const [
      Offset(20, 20),
      Offset(40, 20),
      Offset(40, 80),
    ]), isFalse);
  });
}
