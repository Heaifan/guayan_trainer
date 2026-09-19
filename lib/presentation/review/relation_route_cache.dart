import 'relation_render_plan.dart';

class RelationRouteCacheKey {
  const RelationRouteCacheKey(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is RelationRouteCacheKey && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class RelationRouteCache {
  RelationRenderPlan? _plan;
  RelationRouteCacheKey? _key;

  int calculationCount = 0;
  int cacheHitCount = 0;

  RelationRenderPlan resolve(
    RelationRouteCacheKey key,
    RelationRenderPlan Function() calculate,
  ) {
    if (_key == key && _plan != null) {
      cacheHitCount++;
      return _plan!;
    }
    calculationCount++;
    _key = key;
    _plan = calculate();
    return _plan!;
  }

  void invalidate() {
    _key = null;
    _plan = null;
  }
}
