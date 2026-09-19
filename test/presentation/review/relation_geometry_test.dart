import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/presentation/review/relation_geometry.dart';

void main() {
  test('each node exposes eight anchors derived from its real bounds', () {
    final bounds = Rect.fromLTWH(10, 20, 80, 40);
    final anchors = RelationAnchors.fromRect(bounds);

    expect(anchors.bounds, bounds);
    expect(anchors.at(RelationAnchorName.nw), const Offset(10, 20));
    expect(anchors.at(RelationAnchorName.n), const Offset(50, 20));
    expect(anchors.at(RelationAnchorName.ne), const Offset(90, 20));
    expect(anchors.at(RelationAnchorName.w), const Offset(10, 40));
    expect(anchors.at(RelationAnchorName.e), const Offset(90, 40));
    expect(anchors.at(RelationAnchorName.sw), const Offset(10, 60));
    expect(anchors.at(RelationAnchorName.s), const Offset(50, 60));
    expect(anchors.at(RelationAnchorName.se), const Offset(90, 60));
  });

  test('relative direction prioritizes top source and bottom target anchors', () {
    final source = RelationAnchors.fromRect(Rect.fromLTWH(20, 100, 40, 20));
    final target = RelationAnchors.fromRect(Rect.fromLTWH(80, 20, 40, 20));

    final pairs = AnchorPairCandidates.forNodes(source, target);

    expect(pairs.first.source.name, isIn([
      RelationAnchorName.n,
      RelationAnchorName.nw,
      RelationAnchorName.ne,
    ]));
    expect(pairs.first.target.name, isIn([
      RelationAnchorName.s,
      RelationAnchorName.sw,
      RelationAnchorName.se,
    ]));
  });
}
