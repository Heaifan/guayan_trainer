import 'dart:ui';

import '../relation_orthogonal_router.dart';

abstract final class RelationLabelCandidates {
  static Iterable<Offset> centers(RelationRoute route) sync* {
    final metrics = route.path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    for (final fraction in const [.50, .35, .65, .20, .80]) {
      final tangent = metric.getTangentForOffset(metric.length * fraction);
      if (tangent == null || tangent.vector.distance == 0) continue;
      final vector = tangent.vector;
      final normal = Offset(
        -vector.dy / vector.distance,
        vector.dx / vector.distance,
      );
      yield tangent.position + normal * 14;
      yield tangent.position - normal * 14;
      yield tangent.position + normal * 20;
      yield tangent.position - normal * 20;
      yield tangent.position;
    }
  }

  static Offset fallbackCenter(RelationRoute route) {
    final metrics = route.path.computeMetrics().toList();
    if (metrics.isEmpty) return route.points.first;
    final metric = metrics.first;
    return metric.getTangentForOffset(metric.length / 2)?.position ??
        route.points.first;
  }
}
