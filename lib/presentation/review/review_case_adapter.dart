/// 审卦页视图适配器（纯 Dart，无 Flutter 依赖）。
///
/// 唯一职责：把现有 Domain（[HexagramCase] / [LineState] /
/// [RelationInstance]）适配成审卦页可渲染的 [ReviewPageState]。
/// 传统排盘字段（六神/伏神/六亲/神煞/四柱/卦名）来自
/// [ReviewTraditionalProfile] 演示档案；真实计算属后续排盘引擎（R3），
/// 无档案时显式置空，绝不伪造计算逻辑。
library;

import '../../domain/hexagram_case.dart';
import '../../domain/line_state.dart';
import '../../domain/relation_calculator.dart';
import '../../domain/relation_endpoint.dart';
import '../../domain/relation_instance.dart';
import '../../domain/relation_type.dart';
import '../../domain/casting/cast_chart.dart';
import '../../domain/casting/casting_engine.dart';
import '../../domain/calendar/day/ganzhi_day.dart';
import '../../domain/calendar/day/xun_kong.dart';
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
    this.yearNaYin,
    this.monthPillar,
    this.monthNaYin,
    this.dayPillar,
    this.dayNaYin,
    this.hourPillar,
    this.hourNaYin,
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
  final String? yearNaYin;
  final String? monthPillar;
  final String? monthNaYin;
  final String? dayPillar;
  final String? dayNaYin;
  final String? hourPillar;
  final String? hourNaYin;
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
    final day = ganzhiDayOfDate(
      hexagramCase.createdAt.year,
      hexagramCase.createdAt.month,
      hexagramCase.createdAt.day,
    );
    final chart = CastingEngine.cast([
      for (final line in hexagramCase.lines) line.movementType,
    ], dayGan: day.gan);
    final lines = <ReviewLineView>[
      for (final line in hexagramCase.lines)
        _toLineView(
          line,
          chart.lineAt(line.position),
          profile?.lineTraditional[line.position],
        ),
    ];

    // 关系一律来自 Domain 计算（Stable Relation Identity），禁止 UI 重算。
    final relations = calculateRelations(hexagramCase);
    final focusLine = profile?.focusedLine ?? _firstMoving(hexagramCase);
    final focused = focusLine == null
        ? <RelationInstance>[]
        : [
            for (final r in relations)
              if (_touchesLine(r.source, focusLine) ||
                  _touchesLine(r.target, focusLine))
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
      yearNaYin: profile?.yearNaYin,
      monthPillar: profile?.monthPillar,
      monthNaYin: profile?.monthNaYin,
      dayPillar: profile?.dayPillar,
      dayNaYin: profile?.dayNaYin,
      hourPillar: profile?.hourPillar,
      hourNaYin: profile?.hourNaYin,
      xunKong: profile?.xunKong ?? _xunKong(hexagramCase),
      originalHexagramName:
          profile?.originalHexagramName ?? chart.original.name,
      changedHexagramName: profile?.changedHexagramName ?? chart.changed?.name,
      originalPalaceInfo:
          profile?.originalPalaceInfo ?? chart.original.palace.label,
      changedPalaceInfo:
          profile?.changedPalaceInfo ?? chart.changed?.palace.label,
      changedHexagramExtra: profile?.changedHexagramExtra,
      lines: lines,
      focusedLine: focusLine,
      focusedRelations: focused,
      allRelations: relations,
      focusSummary: profile?.focusSummaryOverride ?? buildFocusSummary(focused),
      rulePackId: ref?.ruleId,
      ruleVersion: ref?.version,
    );
  }

  /// 单条关系的展示标签（如 动变：三爻 → 变三爻；展示层，非重算）。
  static String relationLabel(RelationInstance r) {
    final arrow = r.key.type.directionKind == RelationDirectionKind.directed
        ? '→'
        : '—';
    return '${r.key.type.displayName}：${_endpointLabel(r.source)}'
        '$arrow${_endpointLabel(r.target)}';
  }

  /// 焦点摘要：无档案覆盖时由 [RelationInstance] 生成（展示层，非重算）。
  static String buildFocusSummary(List<RelationInstance> relations) {
    if (relations.isEmpty) return '暂无焦点关系；可在关系页继续深入。';
    final parts = [for (final r in relations) relationLabel(r)];
    return '焦点关系：${parts.join('；')}；可点下方入口继续查看。';
  }

  static ReviewLineView _toLineView(
    LineState line,
    CastLine castLine,
    ReviewLineTraditional? t,
  ) {
    return ReviewLineView(
      position: line.position,
      movementType: line.movementType,
      branch: t == null ? castLine.branch.label : line.branch,
      sixSpirit: t == null ? castLine.spirit?.label : t.sixSpirit,
      hiddenSpirit1: t?.hiddenSpirit1,
      hiddenSpirit2: t?.hiddenSpirit2,
      sixRelative: t == null ? castLine.relative.label : t.sixRelative,
      displayExtra: t == null ? castLine.branch.wuXing.label : t.displayExtra,
      shiYing: t == null
          ? (castLine.shiYingLabel.isEmpty ? null : castLine.shiYingLabel)
          : t.shiYing,
      changedShiYing: t?.changedShiYing,
      changed: t == null ? _changedLine(castLine) : t.changed,
      isVoid: t?.isVoid ?? false,
    );
  }

  static ReviewChangedLine? _changedLine(CastLine line) {
    if (line.changedIsYang == null || line.changedBranch == null) return null;
    return ReviewChangedLine(
      sixRelative: line.changedRelative?.label,
      earthlyBranch: line.changedBranch!.label,
      displayExtra: line.changedBranch!.wuXing.label,
      movementType: line.isMoving
          ? (line.changedIsYang! ? MovementType.laoYang : MovementType.laoYin)
          : (line.changedIsYang!
                ? MovementType.shaoYang
                : MovementType.shaoYin),
    );
  }

  static String? _xunKong(HexagramCase hexagramCase) {
    if (hexagramCase.calendar == null) return null;
    final date = hexagramCase.createdAt;
    return xunKongOf(ganzhiDayOfDate(date.year, date.month, date.day)).label;
  }

  static int? _firstMoving(HexagramCase hexagramCase) {
    for (final line in hexagramCase.lines) {
      if (line.movementType.isMoving) return line.position;
    }
    return null;
  }

  /// 端点是否就是某爻（月建 / 日辰端点不是爻，恒不命中）。
  static bool _touchesLine(RelationEndpoint endpoint, int position) =>
      endpoint is YaoEndpoint && endpoint.position == position;

  static String _endpointLabel(RelationEndpoint endpoint) => switch (endpoint) {
    YaoEndpoint(:final position, :final scope) =>
      scope == LineScope.changed
          ? '变${reviewLinePositionName(position)}'
          : reviewLinePositionName(position),
    MonthEndpoint() => '月建',
    DayEndpoint() => '日辰',
  };
}
