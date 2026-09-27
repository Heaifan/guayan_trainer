import 'dart:math' as math;
import 'dart:ui';

import 'relation_geometry.dart';
import 'relation_obstacle_map.dart';

class RelationRouteResult {
  const RelationRouteResult.route(this.route);
  const RelationRouteResult.noRoute() : route = null;

  final RelationRoute? route;
  bool get isNoRoute => route == null;
}

class RelationRoute {
  RelationRoute({
    required this.sourceAnchor,
    required this.targetAnchor,
    required List<Offset> points,
    required this.path,
    required this.length,
    required this.bendCount,
    required this.cost,
  }) : points = List.unmodifiable(points);

  final RelationAnchor sourceAnchor;
  final RelationAnchor targetAnchor;
  final List<Offset> points;
  final Path path;
  final double length;
  final int bendCount;
  final double cost;
}

/// V2：语义约束下的加权最短路径。
///
/// 普通生克只从正文 L/R 两个主锚点进出。卦盘元素不再是“硬墙”；
/// 穿越只增加少量成本，最终绘制层再对穿越片段做局部透明。因此只要
/// Source/Target 锚点存在，就不应该因为画面拥挤而返回 NoRoute。
abstract final class RelationOrthogonalRouter {
  static const _bendPenalty = 10.0;
  static const _crossingPenalty = 8.0;
  static const _softDirectionPenalty = 3.0;
  static const _reverseDirectionPenalty = 34.0;

  static RelationRouteResult route({
    required RelationAnchors source,
    required RelationAnchors target,
    required RelationObstacleMap obstacles,
    required Rect viewport,
  }) {
    final candidates = <RelationRoute>[];
    for (final pair in AnchorPairCandidates.ordinary(source, target)) {
      for (final raw in _candidatePoints(pair, viewport)) {
        final points = _normalize(raw);
        if (points.length < 2) continue;
        final length = _length(points);
        final bends = math.max(0, points.length - 2);
        final crossings = obstacles.intersectionCount(points);
        final directionCost = _endpointDirectionPenalty(pair, points);
        candidates.add(
          RelationRoute(
            sourceAnchor: pair.source,
            targetAnchor: pair.target,
            points: points,
            path: _roundedPath(points),
            length: length,
            bendCount: bends,
            cost: length +
                bends * _bendPenalty +
                crossings * _crossingPenalty +
                directionCost,
          ),
        );
      }
    }
    if (candidates.isEmpty) return const RelationRouteResult.noRoute();
    candidates.sort(_compareRoutes);
    return RelationRouteResult.route(candidates.first);
  }

  static Iterable<List<Offset>> _candidatePoints(
    AnchorPair pair,
    Rect viewport,
  ) sync* {
    final s = pair.source.point;
    final t = pair.target.point;

    // 最短候选永远存在：允许直线、飞线、交叉。
    yield [s, t];

    // 一折线候选：当直线压过太多元素时，允许小幅改道。
    yield [s, Offset(t.dx, s.dy), t];
    yield [s, Offset(s.dx, t.dy), t];

    // 尊重侧锚点出射方向的短 stub。中间允许斜线，避免被“必须正交”
    // 绑成巨大绕路。
    final sourceNormal = _outward(pair.source.name);
    final targetNormal = _outward(pair.target.name);
    const stub = 10.0;
    final sourceStub = _clampPoint(s + sourceNormal * stub, viewport);
    final targetStub = _clampPoint(t + targetNormal * stub, viewport);
    yield [s, sourceStub, targetStub, t];

    // 两条很浅的外侧走廊仅作为次选，不再枚举几十条“强避障”通道。
    for (final offset in const [14.0, 28.0]) {
      final leftX = math.max(
        viewport.left + 4,
        math.min(source.bounds.left, target.bounds.left) - offset,
      );
      final rightX = math.min(
        viewport.right - 4,
        math.max(source.bounds.right, target.bounds.right) + offset,
      );
      yield [s, Offset(leftX, s.dy), Offset(leftX, t.dy), t];
      yield [s, Offset(rightX, s.dy), Offset(rightX, t.dy), t];
    }
  }

  static Offset _clampPoint(Offset point, Rect viewport) => Offset(
        point.dx.clamp(viewport.left + 1, viewport.right - 1).toDouble(),
        point.dy.clamp(viewport.top + 1, viewport.bottom - 1).toDouble(),
      );

  static List<Offset> _normalize(List<Offset> points) {
    final result = <Offset>[];
    for (final point in points) {
      if (result.isEmpty || (result.last - point).distance > 0.01) {
        result.add(point);
      }
      if (result.length >= 3 &&
          _sameDirection(
            result[result.length - 3],
            result[result.length - 2],
            result.last,
          )) {
        result.removeAt(result.length - 2);
      }
    }
    return result;
  }

  static bool _sameDirection(Offset a, Offset b, Offset c) {
    final ab = b - a;
    final bc = c - b;
    final cross = ab.dx * bc.dy - ab.dy * bc.dx;
    return cross.abs() < 0.001;
  }

  static double _length(List<Offset> points) {
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += (points[i + 1] - points[i]).distance;
    }
    return total;
  }

  static double _endpointDirectionPenalty(
    AnchorPair pair,
    List<Offset> points,
  ) {
    final first = points[1] - points.first;
    final last = points.last - points[points.length - 2];
    final sourceExpected = _outward(pair.source.name);
    // 终点应从元素外部“进入”目标，所以期望方向与目标外法线相反。
    final targetExpected = -_outward(pair.target.name);
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

  static Offset _outward(RelationAnchorName name) => switch (name) {
        RelationAnchorName.w => const Offset(-1, 0),
        RelationAnchorName.e => const Offset(1, 0),
        RelationAnchorName.nw => const Offset(-.707, -.707),
        RelationAnchorName.ne => const Offset(.707, -.707),
        RelationAnchorName.n => const Offset(0, -1),
        RelationAnchorName.sw => const Offset(-.707, .707),
        RelationAnchorName.s => const Offset(0, 1),
        RelationAnchorName.se => const Offset(.707, .707),
      };

  static Path _roundedPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }
    for (var i = 1; i < points.length - 1; i++) {
      final before = points[i - 1];
      final corner = points[i];
      final after = points[i + 1];
      final beforeDistance = (corner - before).distance;
      final afterDistance = (after - corner).distance;
      if (beforeDistance < 0.01 || afterDistance < 0.01) continue;
      final radius =
          math.min(5.0, math.min(beforeDistance / 2, afterDistance / 2));
      final inPoint =
          corner + (before - corner) / beforeDistance * radius;
      final outPoint =
          corner + (after - corner) / afterDistance * radius;
      path.lineTo(inPoint.dx, inPoint.dy);
      path.quadraticBezierTo(
        corner.dx,
        corner.dy,
        outPoint.dx,
        outPoint.dy,
      );
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  static int _compareRoutes(RelationRoute a, RelationRoute b) {
    final cost = a.cost.compareTo(b.cost);
    if (cost != 0) return cost;
    final bends = a.bendCount.compareTo(b.bendCount);
    if (bends != 0) return bends;
    final anchors =
        a.sourceAnchor.name.index.compareTo(b.sourceAnchor.name.index);
    if (anchors != 0) return anchors;
    return a.targetAnchor.name.index.compareTo(b.targetAnchor.name.index);
  }
}
