/// 审卦页视图适配器（纯 Dart，无 Flutter 依赖）。
///
/// 唯一职责：把现有 Domain（[HexagramCase] / [LineState] /
/// [RelationInstance]）适配成审卦页可渲染的 [ReviewPageState]。
/// 传统排盘字段（六神/伏神/六亲/神煞/四柱/卦名）来自
/// [ReviewTraditionalProfile] 演示档案；真实计算属后续排盘引擎（R3），
/// 无档案时显式置空，绝不伪造计算逻辑。
library;

import '../../domain/hexagram_case.dart';
import '../../domain/line_endpoint.dart';
import '../../domain/line_state.dart';
import '../../domain/relation_calculator.dart';
import '../../domain/relation_instance.dart';
import '../../domain/relation_type.dart';
import 'review_page_state.dart';

/// 单爻传统排盘附加档案（六神/伏神/六亲/世应/空亡等）。
class ReviewLineTraditional {
  const ReviewLineTraditional({
    this.sixSpirit,
    this.hiddenSpirit1,
    this.hiddenSpirit2,
    this.sixRelative,
    this.displayExtra,
    this.shiYing,
    this.changedShiYing,
    this.changed,
    this.isVoid = false,
  });

  final String? sixSpirit;
  final String? hiddenSpirit1;
  final String? hiddenSpirit2;
  final String? sixRelative;
  final String? displayExtra;
  final String? shiYing;
  final String? changedShiYing;
  final ReviewChangedLine? changed;

  /// 主卦侧空亡（UI 表现专用，Widget 不计算旬空）。
  final bool isVoid;
}

/// 传统排盘附加档案：Domain 排盘引擎落地前，
/// 由演示 / 测试数据提供传统字段，真实卦例不携带。
class ReviewTraditionalProfile {
  const ReviewTraditionalProfile({
    this.castingMethod,
    this.lunarDateTime,
    this.shenShaItems = const [],
    this.yearPillar,
    this.monthPillar,
    this.dayPillar,
    this.hourPillar,
    this.xunKong,
    this.originalHexagramName,
    this.changedHexagramName,
    this.originalPalaceInfo,
    this.changedPalaceInfo,
    this.changedHexagramExtra,
    this.lineTraditional = const {},
    this.focusedLine,
    this.focusSummaryOverride,
  });

  final String? castingMethod;
  final String? lunarDateTime;
  final List<ReviewShenShaItem> shenShaItems;
  final String? yearPillar;
  final String? monthPillar;
  final String? dayPillar;
  final String? hourPillar;
  final String? xunKong;
  final String? originalHexagramName;
  final String? changedHexagramName;
  final String? originalPalaceInfo;
  final String? changedPalaceInfo;
  final String? changedHexagramExtra;

  /// position(1..6) → 该爻传统档案。
  final Map<int, ReviewLineTraditional> lineTraditional;
  final int? focusedLine;
  final String? focusSummaryOverride;
}

/// 审卦页适配器。
class ReviewCaseAdapter {
  ReviewCaseAdapter._();

  /// 由 [hexagramCase] 生成审卦状态；传统字段来自 [profile]（无则置空）。
  static ReviewPageState adapt(
    HexagramCase hexagramCase, {
    ReviewTraditionalProfile? profile,
  }) {
    final lines = <ReviewLineView>[
      for (final line in hexagramCase.lines)
        _toLineView(line, profile?.lineTraditional[line.position]),
    ];

    // 关系一律来自 Domain 计算（Stable Relation Identity），禁止 UI 重算。
    final relations = calculateRelations(hexagramCase);
    final focusLine = profile?.focusedLine ?? _firstMoving(hexagramCase);
    final focused = focusLine == null
        ? <RelationInstance>[]
        : [
            for (final r in relations)
              if (r.source.position == focusLine || r.target.position == focusLine)
                r,
          ];

    final ref = hexagramCase.ruleContext.refs.isEmpty
        ? null
        : hexagramCase.ruleContext.refs.first;

    return ReviewPageState(
      question: hexagramCase.question,
      castingMethod: profile?.castingMethod,
      solarDateTime: hexagramCase.createdAt,
      lunarDateTime: profile?.lunarDateTime,
      shenShaItems: profile?.shenShaItems ?? const [],
      yearPillar: profile?.yearPillar,
      monthPillar: profile?.monthPillar,
      dayPillar: profile?.dayPillar,
      hourPillar: profile?.hourPillar,
      xunKong: profile?.xunKong,
      originalHexagramName: profile?.originalHexagramName,
      changedHexagramName: profile?.changedHexagramName,
      originalPalaceInfo: profile?.originalPalaceInfo,
      changedPalaceInfo: profile?.changedPalaceInfo,
      changedHexagramExtra: profile?.changedHexagramExtra,
      lines: lines,
      focusedLine: focusLine,
      focusedRelations: focused,
      focusSummary:
          profile?.focusSummaryOverride ?? buildFocusSummary(focused),
      rulePackId: ref?.ruleId,
      ruleVersion: ref?.version,
    );
  }

  /// 焦点摘要：无档案覆盖时由 [RelationInstance] 生成（展示层，非重算）。
  static String buildFocusSummary(List<RelationInstance> relations) {
    if (relations.isEmpty) return '暂无焦点关系；可在关系页继续深入。';
    final parts = <String>[];
    for (final r in relations) {
      final arrow = r.key.type.directionKind == RelationDirectionKind.directed
          ? '→'
          : '—';
      parts.add(
        '${r.key.type.displayName}${_endpointLabel(r.source)}'
        '$arrow${_endpointLabel(r.target)}',
      );
    }
    return '焦点关系：${parts.join('；')}；可点下方入口继续查看。';
  }

  static ReviewLineView _toLineView(
    LineState line,
    ReviewLineTraditional? t,
  ) {
    return ReviewLineView(
      position: line.position,
      movementType: line.movementType,
      branch: line.branch,
      sixSpirit: t?.sixSpirit,
      hiddenSpirit1: t?.hiddenSpirit1,
      hiddenSpirit2: t?.hiddenSpirit2,
      sixRelative: t?.sixRelative,
      displayExtra: t?.displayExtra,
      shiYing: t?.shiYing,
      changedShiYing: t?.changedShiYing,
      changed: t?.changed,
      isVoid: t?.isVoid ?? false,
    );
  }

  static int? _firstMoving(HexagramCase hexagramCase) {
    for (final line in hexagramCase.lines) {
      if (line.movementType.isMoving) return line.position;
    }
    return null;
  }

  static String _endpointLabel(LineEndpoint endpoint) {
    final pos = reviewLinePositionName(endpoint.position);
    return endpoint.scope == LineScope.changed ? '变$pos' : pos;
  }
}
