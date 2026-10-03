import 'dart:ui';

import 'relation_bezier_path.dart';

/// 对已占用走廊施加软成本，优先让后续关系线使用不同车道。
abstract final class RelationRouteSeparationScore {
  static const _nearDistance = 7.0;
  static const _basePenalty = 20.0;
  static const _nearPointPenalty = 4.0;

  static double penalty({
    required Path path,
    Iterable<Path> occupiedPaths = const [],
  }) {
    final samples = RelationBezierPath.sample(path, step: 8);
    if (samples.length < 3) return 0;
    var total = 0.0;
    for (final occupied in occupiedPaths) {
      final other = RelationBezierPath.sample(occupied, step: 8);
      var nearPoints = 0;
      for (final point in samples.skip(1).take(samples.length - 2)) {
        if (other.any((item) => (item - point).distance < _nearDistance)) {
          nearPoints++;
        }
      }
      if (nearPoints > 0) {
        total += _basePenalty + nearPoints * _nearPointPenalty;
      }
    }
    return total;
  }
}
