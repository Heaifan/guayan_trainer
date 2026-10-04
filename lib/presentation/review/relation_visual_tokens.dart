import 'package:flutter/material.dart';

import '../../domain/relation_type.dart';

abstract final class RelationVisualTokens {
  static const strokeNormal = 2.0;
  static const strokeFocused = 2.5;
  static const arrowSize = 4.5;
  static const arrowSizeFocused = 5.5;
  static const anchorRadius = 2.20;

  // 关系标签保留文字，但取消胶囊；字号进一步压缩以降低全卦总览噪声。
  static const relationLabelFontSize = 5.0;
  static const relationLabelHeight = 7.0;
  static const relationLabelHorizontalPadding = 0.0;
  static const relationLabelSafePadding = 1.5;
  // 兼容旧调用；胶囊视觉已冻结为关闭。
  static const relationLabelRadius = 0.0;
  static const relationLabelBorderWidth = 0.0;
  static const relationLabelFillOpacity = 0.0;
  static const relationLabelBorderOpacity = 0.0;
  static const relationLabelArrowClearance = 8.0;

  static const stateLabelFontSize = 8.0;
  static const stateLabelHeight = 14.0;
  static const stateLabelRadius = 7.0;
  static const stateLabelBorderWidth = 0.70;
  static const stateLabelFillOpacity = 0.12;
  static const opacityAll = 1.00;
  static const opacityFocused = 1.00;
  static const opacitySelected = 1.00;
  static const opacityDeemphasized = 0.20;

  // 穿越正文/纳音/世应时只改变 Alpha，不叠白色遮罩、不改变色相。
  static const opacityOccluded = 0.08;
  static const opacityOcclusionFeather = 0.42;
  static const occlusionPadding = 1.0;
  static const occlusionFeather = 2.25;

  static const backHookStroke = 1.80;
  static const backHookArrowSize = 5.00;
  static const safePadding = 5.0;

  static Color colorFor(RelationType type) => switch (type) {
    RelationType.sheng ||
    RelationType.monthGenerate ||
    RelationType.dayGenerate => const Color(0xFF119E57),
    RelationType.ke ||
    RelationType.monthControl ||
    RelationType.dayControl => const Color(0xFFD9342B),
    RelationType.liuChong => const Color(0xFFF57C00),
    RelationType.liuHe => const Color(0xFF1565C0),
    RelationType.huiTouSheng => const Color(0xFF119E57),
    RelationType.huiTouKe => const Color(0xFFD9342B),
    RelationType.flyingGeneratesHidden ||
    RelationType.hiddenGeneratesFlying ||
    RelationType.flyingOvercomesHidden ||
    RelationType.hiddenOvercomesFlying => const Color(0xFF7B3FA1),
    RelationType.dongBian => const Color(0xFF2E7D32),
  };

  static bool isBidirectional(RelationType type) =>
      type.directionKind == RelationDirectionKind.symmetric;

  static bool isBackRelation(RelationType type) =>
      type == RelationType.huiTouSheng || type == RelationType.huiTouKe;

  static bool isDashed(RelationType type) =>
      type == RelationType.huiTouSheng || type == RelationType.huiTouKe;

  static bool isDotted(RelationType type) => switch (type) {
    RelationType.flyingGeneratesHidden ||
    RelationType.flyingOvercomesHidden ||
    RelationType.hiddenGeneratesFlying ||
    RelationType.hiddenOvercomesFlying => true,
    _ => false,
  };

  static String backHookLabel(RelationType type) => switch (type) {
    RelationType.huiTouSheng => '回生',
    RelationType.huiTouKe => '回克',
    RelationType.flyingGeneratesHidden => '飞生伏',
    RelationType.flyingOvercomesHidden => '飞克伏',
    RelationType.hiddenGeneratesFlying => '伏生飞',
    RelationType.hiddenOvercomesFlying => '伏克飞',
    _ => type.displayName,
  };
}
