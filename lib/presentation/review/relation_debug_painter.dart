import 'dart:ui';

class RelationDebugData {
  const RelationDebugData({
    required this.isVisible,
    required this.nodeBounds,
    required this.anchorBounds,
    required this.obstacleBounds,
    required this.selectedAnchors,
    required this.routeSegments,
    required this.labelBounds,
  });

  final bool isVisible;
  final Map<String, Rect> nodeBounds;
  final Map<String, List<Offset>> anchorBounds;
  final Map<String, Rect> obstacleBounds;
  final List<Offset> selectedAnchors;
  final List<List<Offset>> routeSegments;
  final List<Rect> labelBounds;
}

abstract final class RelationDebugPainter {
  static RelationDebugData data({
    required bool enabled,
    required Map<String, Rect> nodeBounds,
    required Map<String, List<Offset>> anchorBounds,
    required Map<String, Rect> obstacleBounds,
    required List<Offset> selectedAnchors,
    required List<List<Offset>> routeSegments,
    required List<Rect> labelBounds,
  }) => RelationDebugData(
    isVisible: enabled,
    nodeBounds: enabled ? Map.unmodifiable(nodeBounds) : const {},
    anchorBounds: enabled ? Map.unmodifiable(anchorBounds) : const {},
    obstacleBounds: enabled ? Map.unmodifiable(obstacleBounds) : const {},
    selectedAnchors: enabled ? List.unmodifiable(selectedAnchors) : const [],
    routeSegments: enabled ? List.unmodifiable(routeSegments) : const [],
    labelBounds: enabled ? List.unmodifiable(labelBounds) : const [],
  );
}
