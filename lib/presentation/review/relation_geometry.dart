import 'dart:ui';

enum RelationAnchorName { nw, n, ne, w, e, sw, s, se }

class RelationAnchor {
  const RelationAnchor({required this.name, required this.point});

  final RelationAnchorName name;
  final Offset point;
}

class RelationAnchors {
  RelationAnchors({required this.bounds, required Map<RelationAnchorName, Offset> points})
      : _points = Map.unmodifiable(points);

  factory RelationAnchors.fromRect(Rect bounds) {
    final cx = bounds.center.dx;
    final cy = bounds.center.dy;
    return RelationAnchors(
      bounds: bounds,
      points: {
        RelationAnchorName.nw: Offset(bounds.left, bounds.top),
        RelationAnchorName.n: Offset(cx, bounds.top),
        RelationAnchorName.ne: Offset(bounds.right, bounds.top),
        RelationAnchorName.w: Offset(bounds.left, cy),
        RelationAnchorName.e: Offset(bounds.right, cy),
        RelationAnchorName.sw: Offset(bounds.left, bounds.bottom),
        RelationAnchorName.s: Offset(cx, bounds.bottom),
        RelationAnchorName.se: Offset(bounds.right, bounds.bottom),
      },
    );
  }

  final Rect bounds;
  final Map<RelationAnchorName, Offset> _points;

  Offset at(RelationAnchorName name) => _points[name]!;

  Iterable<RelationAnchor> get all => [
    for (final entry in _points.entries)
      RelationAnchor(name: entry.key, point: entry.value),
  ];
}

class AnchorPair {
  const AnchorPair({required this.source, required this.target});

  final RelationAnchor source;
  final RelationAnchor target;
}

abstract final class AnchorPairCandidates {
  static List<AnchorPair> forNodes(
    RelationAnchors source,
    RelationAnchors target,
  ) {
    final delta = target.bounds.center - source.bounds.center;
    final sourceOrder = _orderedNames(delta, source: true);
    final targetOrder = _orderedNames(delta, source: false);
    final pairs = <AnchorPair>[];
    for (final sourceName in sourceOrder) {
      for (final targetName in targetOrder) {
        pairs.add(AnchorPair(
          source: RelationAnchor(name: sourceName, point: source.at(sourceName)),
          target: RelationAnchor(name: targetName, point: target.at(targetName)),
        ));
      }
    }
    return pairs;
  }

  static List<RelationAnchorName> _orderedNames(
    Offset delta, {
    required bool source,
  }) {
    final vertical = delta.dy.abs() >= delta.dx.abs();
    final towardTarget = source ? 1 : -1;
    if (vertical && delta.dy.sign * towardTarget > 0) {
      return [
        RelationAnchorName.s,
        RelationAnchorName.sw,
        RelationAnchorName.se,
        RelationAnchorName.w,
        RelationAnchorName.e,
        RelationAnchorName.n,
        RelationAnchorName.nw,
        RelationAnchorName.ne,
      ];
    }
    if (vertical) {
      return [
        RelationAnchorName.n,
        RelationAnchorName.nw,
        RelationAnchorName.ne,
        RelationAnchorName.w,
        RelationAnchorName.e,
        RelationAnchorName.s,
        RelationAnchorName.sw,
        RelationAnchorName.se,
      ];
    }
    final right = delta.dx.sign * towardTarget > 0;
    return right
        ? [RelationAnchorName.e, RelationAnchorName.ne, RelationAnchorName.se,
            RelationAnchorName.n, RelationAnchorName.s, RelationAnchorName.w,
            RelationAnchorName.nw, RelationAnchorName.sw]
        : [RelationAnchorName.w, RelationAnchorName.nw, RelationAnchorName.sw,
            RelationAnchorName.n, RelationAnchorName.s, RelationAnchorName.e,
            RelationAnchorName.ne, RelationAnchorName.se];
  }
}
