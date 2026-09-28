import 'dart:ui';

import '../relation_geometry.dart';

abstract final class RelationRouteScoring {
  static const _softDirectionPenalty = 3.0;
  static const _reverseDirectionPenalty = 34.0;

  static double endpointDirectionPenalty(
    AnchorPair pair,
    List<Offset> points,
  ) {
    final first = points[1] - points.first;
    final last = points.last - points[points.length - 2];
    final sourceExpected = outward(pair.source.name);
    final targetExpected = -outward(pair.target.name);
    return _vectorPenalty(first, sourceExpected) +
        _vectorPenalty(last, targetExpected);
  }

  static double _vectorPenalty(Offset actual, Offset expected) {
    if (actual.distance < 0.001) return _reverseDirectionPenalty;
    final unit = actual / actual.distance;
    final dot = unit.dx * expected.dx + unit.dy * expected.dy;
    if (dot < -0.15) return _reverseDirectionPenalty;
    if (dot < 0.15) return _softDirectionPenalty;
    return 0;
  }

  static Offset outward(RelationAnchorName name) => switch (name) {
        RelationAnchorName.w => const Offset(-1, 0),
        RelationAnchorName.e => const Offset(1, 0),
        RelationAnchorName.nw => const Offset(-.707, -.707),
        RelationAnchorName.ne => const Offset(.707, -.707),
        RelationAnchorName.n => const Offset(0, -1),
        RelationAnchorName.sw => const Offset(-.707, .707),
        RelationAnchorName.s => const Offset(0, 1),
        RelationAnchorName.se => const Offset(.707, .707),
      };
}
