import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/relation_render_plan.dart';
import 'package:guayan_trainer/presentation/review/relation_route_cache.dart';

void main() {
  test('repaint and selection reuse the same route plan', () {
    final cache = RelationRouteCache();
    var calls = 0;
    RelationRenderPlan calculate() {
      calls++;
      return const RelationRenderPlan(routes: [], records: [], labels: [], obstacleCount: 0);
    }

    final key = const RelationRouteCacheKey('layout|relations|400x600|font12');
    final first = cache.resolve(key, calculate);
    final second = cache.resolve(key, calculate);

    expect(identical(first, second), isTrue);
    expect(calls, 1);
    expect(cache.calculationCount, 1);
    expect(cache.cacheHitCount, 1);
  });

  test('bounds/effective-set/size changes invalidate the plan key', () {
    final cache = RelationRouteCache();
    var calls = 0;
    RelationRenderPlan calculate() {
      calls++;
      return const RelationRenderPlan(routes: [], records: [], labels: [], obstacleCount: 0);
    }

    cache.resolve(const RelationRouteCacheKey('a'), calculate);
    cache.resolve(const RelationRouteCacheKey('b'), calculate);
    expect(calls, 2);
    expect(cache.calculationCount, 2);
  });
}
