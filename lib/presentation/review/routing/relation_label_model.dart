import 'dart:ui';

import '../relation_orthogonal_router.dart';

class PlacedRelationLabel {
  const PlacedRelationLabel({
    required this.text,
    required this.bounds,
    required this.center,
    required this.route,
  });

  final String text;
  final Rect bounds;
  final Offset center;
  final RelationRoute route;
}
