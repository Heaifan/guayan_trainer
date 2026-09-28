import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/routing/relation_bezier_path.dart';

void main() {
  test('two-point relation keeps a visible cubic bow', () {
    final path = RelationBezierPath.build(
      const [Offset(20, 60), Offset(180, 60)],
      const Rect.fromLTWH(0, 0, 220, 140),
    );
    final metric = path.computeMetrics().single;
    final midpoint = metric.getTangentForOffset(metric.length / 2)!.position;

    expect((midpoint.dy - 60).abs(), greaterThan(8));
    expect(metric.length, greaterThan(160));
  });

  test('sample follows the rendered curve for obstacle validation', () {
    final path = RelationBezierPath.build(
      const [Offset(20, 60), Offset(180, 60)],
      const Rect.fromLTWH(0, 0, 220, 140),
    );
    final samples = RelationBezierPath.sample(path);

    expect(samples.length, greaterThan(10));
    expect(samples.first.dx, closeTo(20, .01));
    expect(samples.last.dx, closeTo(180, .01));
  });
}
