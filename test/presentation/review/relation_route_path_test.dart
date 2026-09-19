import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/presentation/review/relation_route_path.dart';

void main() {
  test('nearby main relations use a local path instead of an outer detour', () {
    final path = buildRelationRoutePath(
      from: const Offset(96, 120),
      to: const Offset(96, 180),
      route: RelationRouteKind.mainToMain,
      trunkLane: 0,
      branchOffset: 0,
      viewportWidth: 360,
    );

    expect(path.computeMetrics().single.length, lessThan(100));
    expect(path.computeMetrics().single.getTangentForOffset(0)!.position,
        const Offset(96, 120));
    expect(path.computeMetrics().single.getTangentForOffset(
        path.computeMetrics().single.length)!.position, const Offset(96, 180));
  });

  test('nearby changed relations use a local path and preserve endpoints', () {
    final path = buildRelationRoutePath(
      from: const Offset(300, 120),
      to: const Offset(300, 180),
      route: RelationRouteKind.changedToChanged,
      trunkLane: 0,
      branchOffset: 0,
      viewportWidth: 360,
    );

    expect(path.computeMetrics().single.length, lessThan(100));
  });
}
