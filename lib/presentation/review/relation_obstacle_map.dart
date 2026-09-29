import 'dart:math' as math;
import 'dart:ui';

import 'relation_visual_tokens.dart';

class RelationObstacle {
  const RelationObstacle({required this.id, required this.bounds});
  final String id;
  final Rect bounds;
}

class RelationObstacleMap {
  RelationObstacleMap(Iterable<RelationObstacle> obstacles)
      : obstacles = List.unmodifiable(obstacles),
        _byId = {for (final obstacle in obstacles) obstacle.id: obstacle};

  factory RelationObstacleMap.fromBounds(Map<String, Rect> bounds) =>
      RelationObstacleMap([
        for (final entry in bounds.entries)
          RelationObstacle(
            id: entry.key,
            bounds: entry.value.inflate(RelationVisualTokens.safePadding),
          ),
      ]);

  final List<RelationObstacle> obstacles;
  final Map<String, RelationObstacle> _byId;

  RelationObstacle? obstacleFor(String id) => _byId[id];

  bool isClearSegment(Offset start, Offset end) => obstacles.every(
    (obstacle) => !_intersectsRect(start, end, obstacle.bounds),
  );

  bool isClearPath(List<Offset> points) {
    for (var i = 0; i < points.length - 1; i++) {
      if (!isClearSegment(points[i], points[i + 1])) return false;
    }
    return true;
  }

  int intersectionCount(List<Offset> points) =>
      _hits(points).length;

  double routingPenalty(List<Offset> points) {
    var total = 0.0;
    for (final obstacle in _hits(points)) {
      total += _routingWeight(obstacle.id);
    }
    return total;
  }

  List<RelationObstacle> _hits(List<Offset> points) => [
    for (final obstacle in obstacles)
      if (_pathHits(points, obstacle.bounds)) obstacle,
  ];

  bool _pathHits(List<Offset> points, Rect bounds) {
    for (var i = 0; i < points.length - 1; i++) {
      if (_intersectsRect(points[i], points[i + 1], bounds)) return true;
    }
    return false;
  }

  double _routingWeight(String id) {
    if (id.contains('hidden')) return 180;
    if (id.contains('six_spirit')) return 120;
    if (id.contains('nayin')) return 100;
    if (id.contains('shi_ying')) return 90;
    if (id.contains('moving_marker')) return 80;
    if (id.startsWith('yao_glyph:')) return 70;
    return 90;
  }
}

bool _intersectsRect(Offset start, Offset end, Rect rect) {
  if (rect.contains(start) || rect.contains(end)) return true;
  final edges = <(Offset, Offset)>[
    (Offset(rect.left, rect.top), Offset(rect.right, rect.top)),
    (Offset(rect.right, rect.top), Offset(rect.right, rect.bottom)),
    (Offset(rect.right, rect.bottom), Offset(rect.left, rect.bottom)),
    (Offset(rect.left, rect.bottom), Offset(rect.left, rect.top)),
  ];
  return edges.any((edge) => _segmentsIntersect(start, end, edge.$1, edge.$2));
}

bool _segmentsIntersect(Offset a, Offset b, Offset c, Offset d) {
  final abC = _cross(b - a, c - a), abD = _cross(b - a, d - a);
  final cdA = _cross(d - c, a - c), cdB = _cross(d - c, b - c);
  const e = 0.0001;
  return abC.abs() <= e && _onSegment(a, b, c) ||
      abD.abs() <= e && _onSegment(a, b, d) ||
      cdA.abs() <= e && _onSegment(c, d, a) ||
      cdB.abs() <= e && _onSegment(c, d, b) ||
      (abC > 0) != (abD > 0) && (cdA > 0) != (cdB > 0);
}

double _cross(Offset a, Offset b) => a.dx * b.dy - a.dy * b.dx;
bool _onSegment(Offset a, Offset b, Offset p) =>
    p.dx >= math.min(a.dx, b.dx) - .0001 &&
    p.dx <= math.max(a.dx, b.dx) + .0001 &&
    p.dy >= math.min(a.dy, b.dy) - .0001 &&
    p.dy <= math.max(a.dy, b.dy) + .0001;
