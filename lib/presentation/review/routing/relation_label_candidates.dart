import 'dart:ui';

import '../relation_orthogonal_router.dart';

abstract final class RelationLabelCandidates {
  static Iterable<Offset> centers(RelationRoute route) sync* {
    final metrics = route.path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    // 标签属于 Route：只沿自己的曲线前后找位置，禁止横向漂到邻线。
    for (final fraction in const [.50, .42, .58, .34, .66, .26, .74]) {
      final tangent = metric.getTangentForOffset(metric.length * fraction);
      if (tangent != null) yield tangent.position;
    }
  }
}
