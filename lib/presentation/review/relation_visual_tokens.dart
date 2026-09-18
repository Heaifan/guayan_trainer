import 'package:flutter/material.dart';

import '../../domain/relation_type.dart';

abstract final class RelationVisualTokens {
  static const strokeNormal = 1.15;
  static const strokeFocused = 1.40;
  static const arrowSize = 4.20;
  static const anchorRadius = 2.20;
  static const relationLabelFontSize = 9.0;
  static const relationLabelHeight = 16.0;
  static const relationLabelRadius = 8.0;
  static const stateLabelFontSize = 8.0;
  static const stateLabelHeight = 14.0;
  static const stateLabelRadius = 7.0;
  static const stateLabelBorderWidth = 0.70;
  static const stateLabelFillOpacity = 0.12;
  static const opacityAll = 1.00;
  static const opacityFocused = 1.00;
  static const opacitySelected = 1.00;
  static const opacityDeemphasized = 0.20;

  static Color colorFor(RelationType type) => switch (type) {
    RelationType.sheng ||
    RelationType.monthGenerate ||
    RelationType.dayGenerate => const Color(0xFF119E57),
    RelationType.ke ||
    RelationType.monthControl ||
    RelationType.dayControl => const Color(0xFFD9342B),
    RelationType.liuChong => const Color(0xFFF57C00),
    RelationType.liuHe => const Color(0xFF1565C0),
    RelationType.huiTouSheng => const Color(0xFF00796B),
    RelationType.huiTouKe => const Color(0xFF8E244D),
    RelationType.dongBian => const Color(0xFF2E7D32),
  };

  static bool isBidirectional(RelationType type) =>
      type.directionKind == RelationDirectionKind.symmetric;
}
