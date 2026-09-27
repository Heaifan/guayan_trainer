import 'dart:ui';

/// 正文几何锚点。V2 只开放四个物理锚点：
/// TL / TR 是条件锚点，L / R 是普通生克主锚点。
///
/// 枚举保留旧方向名，避免调试/历史测试反序列化受影响；但 [RelationAnchors]
/// 不再创建上中与三个底部锚点。
enum RelationAnchorName { nw, n, ne, w, e, sw, s, se }

class RelationAnchor {
  const RelationAnchor({required this.name, required this.point});

  final RelationAnchorName name;
  final Offset point;
}

class RelationAnchors {
  RelationAnchors({
    required this.bounds,
    required Map<RelationAnchorName, Offset> points,
  }) : _points = Map.unmodifiable(points);

  factory RelationAnchors.fromRect(Rect bounds) {
    final cy = bounds.center.dy;
    return RelationAnchors(
      bounds: bounds,
      points: {
        RelationAnchorName.nw: Offset(bounds.left, bounds.top),
        RelationAnchorName.ne: Offset(bounds.right, bounds.top),
        RelationAnchorName.w: Offset(bounds.left, cy),
        RelationAnchorName.e: Offset(bounds.right, cy),
      },
    );
  }

  final Rect bounds;
  final Map<RelationAnchorName, Offset> _points;

  Offset at(RelationAnchorName name) => _points[name]!;

  bool contains(RelationAnchorName name) => _points.containsKey(name);

  /// 调试时只展示真正开放的四个物理锚点。
  Iterable<RelationAnchor> get all => [
    for (final entry in _points.entries)
      RelationAnchor(name: entry.key, point: entry.value),
  ];

  /// 普通爻间生克：只允许左右中点。
  Iterable<RelationAnchor> get ordinary => [
    RelationAnchor(name: RelationAnchorName.w, point: at(RelationAnchorName.w)),
    RelationAnchor(name: RelationAnchorName.e, point: at(RelationAnchorName.e)),
  ];

  /// 月 / 日 / 时从上方进入时：顶部角点优先，左右中点仅 fallback。
  Iterable<RelationAnchor> get externalTarget => [
    RelationAnchor(name: RelationAnchorName.nw, point: at(RelationAnchorName.nw)),
    RelationAnchor(name: RelationAnchorName.ne, point: at(RelationAnchorName.ne)),
    ...ordinary,
  ];
}

class AnchorPair {
  const AnchorPair({required this.source, required this.target});

  final RelationAnchor source;
  final RelationAnchor target;
}

abstract final class AnchorPairCandidates {
  /// 普通生克只产生 L/R × L/R 四组候选。
  static List<AnchorPair> ordinary(
    RelationAnchors source,
    RelationAnchors target,
  ) => [
    for (final sourceAnchor in source.ordinary)
      for (final targetAnchor in target.ordinary)
        AnchorPair(source: sourceAnchor, target: targetAnchor),
  ];

  /// 为月/日/时等上方外部来源预留；当前普通生克 Router 不调用。
  static List<AnchorPair> externalToNode(
    RelationAnchors source,
    RelationAnchors target,
  ) => [
    for (final sourceAnchor in source.all)
      for (final targetAnchor in target.externalTarget)
        AnchorPair(source: sourceAnchor, target: targetAnchor),
  ];
}
