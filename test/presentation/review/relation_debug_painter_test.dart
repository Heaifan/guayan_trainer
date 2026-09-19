import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/relation_debug_painter.dart';

void main() {
  test('debug data exposes all geometry categories only when enabled', () {
    final hidden = RelationDebugPainter.data(
      enabled: false,
      nodeBounds: {'main': const Rect.fromLTWH(0, 0, 10, 10)},
      anchorBounds: {'main': const [Offset.zero]},
      obstacleBounds: {'text': const Rect.fromLTWH(20, 20, 10, 10)},
      selectedAnchors: const [],
      routeSegments: const [],
      labelBounds: const [],
    );
    expect(hidden.isVisible, isFalse);
    expect(hidden.nodeBounds, isEmpty);

    final shown = RelationDebugPainter.data(
      enabled: true,
      nodeBounds: {'main': const Rect.fromLTWH(0, 0, 10, 10)},
      anchorBounds: {'main': const [Offset.zero]},
      obstacleBounds: {'text': const Rect.fromLTWH(20, 20, 10, 10)},
      selectedAnchors: const [Offset(4, 4)],
      routeSegments: const [[Offset.zero, Offset(10, 10)]],
      labelBounds: const [Rect.fromLTWH(5, 5, 10, 10)],
    );
    expect(shown.isVisible, isTrue);
    expect(shown.nodeBounds, isNotEmpty);
    expect(shown.anchorBounds, isNotEmpty);
    expect(shown.obstacleBounds, isNotEmpty);
    expect(shown.selectedAnchors, isNotEmpty);
    expect(shown.routeSegments, isNotEmpty);
    expect(shown.labelBounds, isNotEmpty);
  });
}
