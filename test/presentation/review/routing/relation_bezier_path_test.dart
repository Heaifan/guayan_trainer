import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/routing/relation_bezier_path.dart';

void main() {
  test('direct relation keeps a visible cubic bow instead of a straight chord', () {
    final path = RelationBezierPath.build(
      const [Offset(20, 60), Offset(180, 60)],
      const Rect.fromLTWH(0, 0, 220, 140),
    );
    final metric = path.computeMetrics().single;
    final midpoint = metric.getTangentForOffset(metric.length / 2)!.position;

    expect((midpoint.dy - 60).abs(), greaterThan(10));
    expect(metric.length, greaterThan(160));
  });

  test('multi-point relation remains a continuous paintable path', () {
    final path = RelationBezierPath.build(
      const [
        Offset(20, 100),
        Offset(60, 100),
        Offset(140, 40),
        Offset(180, 40),
      ],
      const Rect.fromLTWH(0, 0, 220, 140),
    );

    expect(path.computeMetrics().single.length, greaterThan(0));
  });
}
