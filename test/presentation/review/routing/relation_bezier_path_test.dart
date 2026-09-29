import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/routing/relation_bezier_path.dart';

Offset midpoint(Path path) {
  final metric = path.computeMetrics().single;
  return metric.getTangentForOffset(metric.length / 2)!.position;
}

void main() {
  const viewport = Rect.fromLTWH(0, 0, 220, 220);
  const vertical = [Offset(110, 190), Offset(110, 30)];

  test('direct relation keeps a visible cubic bow', () {
    final path = RelationBezierPath.build(vertical, viewport);
    expect((midpoint(path).dx - 110).abs(), greaterThan(10));
    expect(path.computeMetrics().single.length, greaterThan(160));
  });

  test('direct bows support real screen-space left and right', () {
    final left = RelationBezierPath.build(
      vertical, viewport, directHorizontalSide: -1,
    );
    final right = RelationBezierPath.build(
      vertical, viewport, directHorizontalSide: 1,
    );
    expect(midpoint(left).dx, lessThan(110));
    expect(midpoint(right).dx, greaterThan(110));
  });

  test('screen-side meaning survives reversed source direction', () {
    const reversed = [Offset(110, 30), Offset(110, 190)];
    final left = RelationBezierPath.build(
      reversed, viewport, directHorizontalSide: -1,
    );
    final right = RelationBezierPath.build(
      reversed, viewport, directHorizontalSide: 1,
    );
    expect(midpoint(left).dx, lessThan(110));
    expect(midpoint(right).dx, greaterThan(110));
  });
}
