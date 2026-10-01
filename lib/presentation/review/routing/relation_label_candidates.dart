import 'dart:ui';

abstract final class RelationLabelCandidates {
  static Iterable<Offset> centers(Path path) sync* {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final middle = metric.length / 2;
    const endpointClearance = 12.0;
    final maxDelta = middle - endpointClearance;
    if (maxDelta < 0) return;
    for (var delta = 0.0; delta <= maxDelta; delta += 4.0) {
      for (final offset
          in delta == 0 ? [middle] : [middle - delta, middle + delta]) {
        final tangent = metric.getTangentForOffset(offset);
        if (tangent != null) yield tangent.position;
      }
    }
  }
}
