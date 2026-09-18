/// 审卦页视图适配器（纯 Dart，无 Flutter 依赖）。
///
/// 唯一职责：把现有 Domain（[HexagramCase] / [LineState] /
/// [RelationInstance]）适配成审卦页可渲染的 [ReviewPageState]。
/// 传统展示档案仅供视觉/兼容测试；正式卦例优先使用 Domain 排盘结果。
library;

import '../../domain/hexagram_case.dart';
import '../../domain/line_state.dart';
import '../../domain/relation_calculator.dart';
import '../../domain/relation_endpoint.dart';
import '../../domain/relation_instance.dart';
import '../../domain/relation_type.dart';
import '../../domain/relations/relation_projection.dart';
import '../../domain/relations/relation_record.dart';
import '../../domain/casting/cast_chart.dart';
import '../../domain/casting/casting_engine.dart';
import '../../domain/casting/fushen_engine.dart';
import '../../domain/casting/fushen.dart';
import '../../domain/casting/double_fucang.dart';
import '../../domain/casting/double_fucang_engine.dart';
import '../../domain/casting/hexagram_palace_profile.dart';
import '../../domain/calendar/day/ganzhi_day.dart';
import '../../domain/calendar/day/xun_kong.dart';
import '../../domain/calendar/calendar_pillars.dart';
import '../../domain/calendar/lunar_calendar.dart';
import '../../domain/di_zhi.dart';
import '../../domain/tian_gan.dart';
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
    final day = hexagramCase.calendar == null
        ? ganzhiDayOfDate(
            hexagramCase.createdAt.year,
            hexagramCase.createdAt.month,
            hexagramCase.createdAt.day,
          )
        : null;
    final dayGan = hexagramCase.calendar == null
        ? day!.gan
        : TianGan.fromLabel(hexagramCase.calendar!.dayGan);
    final chart = CastingEngine.cast([
      for (final line in hexagramCase.lines) line.movementType,
    ], dayGan: dayGan);
    final fushens = FushenEngine.calculate(chart);
    final doubleFucang = DoubleFucangEngine.calculate(chart.original.palace);
    final originalProfile = HexagramPalaceProfile.fromHexagram(chart.original);
    final changedProfile = chart.changed == null
        ? null
        : HexagramPalaceProfile.fromHexagram(chart.changed!);
    final lines = <ReviewLineView>[
      for (final line in hexagramCase.lines)
        _toLineView(
          hexagramCase,
          line,
          chart.lineAt(line.position),
          fushens.where((fushen) => fushen.lineIndex == line.position).toList(),
          doubleFucang.primary[line.position - 1],
          doubleFucang.opposite[line.position - 1],
          changedProfile,
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

    final relationRecords = [
      ...RelationProjection.projectRelationInstances(relations),
      for (final line in lines)
        if (line.isVoid)
          RelationRecord.state(
            id: 'fact:state:xun_kong:yao:original:${line.position}',
            sourceKind: RelationSourceKind.fact,
            stateType: RelationStateType.xunKong,
            participants: [YaoEndpoint(LineScope.original, line.position)],
            title: '${reviewLinePositionName(line.position)}旬空',
            subtitle: '旬空 · ${reviewLinePositionName(line.position)}',
            category: '状态',
          ),
      for (final evidence in [
        for (final run in hexagramCase.ruleRuns) ...run.derivedEvidence,
      ])
        if (evidence.targetKind.name == 'relation' &&
            evidence.targetRefs.length >= 2 &&
            evidence.targetRefs[0].kind == 'line' &&
            evidence.targetRefs[1].kind == 'line')
          RelationRecord.relation(
            id: 'rule-evidence:${evidence.id.id}',
            sourceKind: RelationSourceKind.rule,
            relationType: RelationType.liuChong,
            fromRef: YaoEndpoint(
              LineScope.original,
              int.parse(evidence.targetRefs[0].key),
            ),
            toRef: YaoEndpoint(
              LineScope.original,
              int.parse(evidence.targetRefs[1].key),
            ),
            title: '规则取象：${evidence.value}',
            subtitle: '${evidence.ruleId.id} · ${evidence.ruleVersion.version}',
            category: '规则取象',
            ruleId: evidence.ruleId.id,
            evidence: [evidence.id.id],
          ),
    ];

    return ReviewPageState(
      caseId: hexagramCase.id,
      question: hexagramCase.question,
      category: hexagramCase.category,
      castingMethod: profile?.castingMethod ?? '铜钱手动',
      solarDateTime: hexagramCase.createdAt,
      lunarDateTime: profile?.lunarDateTime ?? _lunarDateTime(hexagramCase),
      shenShaItems: profile?.shenShaItems ?? _shenShaItems(hexagramCase),
      yearPillar: profile?.yearPillar ?? _yearPillar(hexagramCase),
      yearNaYin: profile?.yearNaYin ?? _yearNaYin(hexagramCase),
      monthPillar: profile?.monthPillar ?? _monthPillar(hexagramCase),
      monthNaYin: profile?.monthNaYin ?? _monthNaYin(hexagramCase),
      dayPillar: profile?.dayPillar ?? _dayPillar(hexagramCase),
      dayNaYin: profile?.dayNaYin ?? _dayNaYin(hexagramCase),
      hourPillar: profile?.hourPillar ?? _hourPillar(hexagramCase),
      hourNaYin: profile?.hourNaYin ?? _hourNaYin(hexagramCase),
      xunKong: profile?.xunKong ?? _xunKong(hexagramCase),
      originalHexagramName:
          profile?.originalHexagramName ?? chart.original.name,
      changedHexagramName:
          profile?.changedHexagramName ??
          chart.changed?.name ??
          chart.original.name,
      originalPalaceInfo:
          profile?.originalPalaceInfo ?? chart.original.palace.label,
      changedPalaceInfo:
          profile?.changedPalaceInfo ??
          chart.changed?.palace.label ??
          chart.original.palace.label,
      originalPalaceProfile: profile == null ? originalProfile : null,
      changedPalaceProfile: profile == null ? changedProfile : null,
      changedHexagramExtra: profile?.changedHexagramExtra,
      lines: lines,
      focusedLine: focusLine,
      focusedRelations: focused,
      allRelations: relations,
      relationRecords: relationRecords,
      derivedEvidence: [
        for (final run in hexagramCase.ruleRuns) ...run.derivedEvidence,
      ],
      ruleRuns: hexagramCase.ruleRuns,
      focusSummary: profile?.focusSummaryOverride ?? buildFocusSummary(focused),
      rulePackId: ref?.ruleId,
      ruleVersion: ref?.version,
    );
  }

  static List<ReviewShenShaItem> _shenShaItems(HexagramCase hexagramCase) {
    final results = hexagramCase.calendar?.shenShaResults;
    if (results == null) return const [];
    return [
      for (final result in results)
        ReviewShenShaItem(
          name: result.displayName,
          value: result.value,
          id: result.id,
          basisType: result.basisType,
          basisValue: result.basisValue,
          ruleSetId: result.ruleSetId,
          ruleVersion: result.ruleVersion,
          reasonSnapshot: result.reasonSnapshot,
        ),
    ];
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
    HexagramCase hexagramCase,
    LineState line,
    CastLine castLine,
    List<FushenResult> fushens,
    HiddenPalaceLine primaryHidden,
    HiddenPalaceLine oppositeHidden,
    HexagramPalaceProfile? changedProfile,
    ReviewLineTraditional? t,
  ) {
    return ReviewLineView(
      position: line.position,
      movementType: line.movementType,
      branch: t == null ? castLine.branch.label : line.branch,
      sixSpirit: t == null ? castLine.spirit?.label : t.sixSpirit,
      hiddenSpirit1: t?.hiddenSpirit1,
      hiddenSpirit2: t?.hiddenSpirit2,
      hiddenSpiritFacts: t == null ? const [] : fushens,
      primaryHidden: t == null ? primaryHidden : null,
      oppositeHidden: t == null ? oppositeHidden : null,
      identity: t == null
          ? ReviewLineIdentity(
              relative: castLine.relative.label,
              ganZhi: castLine.ganZhi,
              element: castLine.branch.wuXing.label,
            )
          : null,
      sixRelative: t == null
          ? '${castLine.relative.label}${castLine.ganZhi}${castLine.branch.wuXing.label}'
          : t.sixRelative,
      displayExtra: t?.displayExtra,
      shiYing: t == null
          ? (castLine.shiYingLabel.isEmpty ? null : castLine.shiYingLabel)
          : t.shiYing,
      changedShiYing:
          t?.changedShiYing ?? _positionMarker(changedProfile, line.position),
      changed: t == null ? _changedLine(castLine) : t.changed,
      isVoid: t?.isVoid ?? _isXunKong(hexagramCase, castLine.branch),
    );
  }

  static String? _positionMarker(HexagramPalaceProfile? profile, int position) {
    if (profile == null) return null;
    if (position == profile.shiLine) return '世';
    if (position == profile.yingLine) return '应';
    return null;
  }

  static ReviewChangedLine? _changedLine(CastLine line) {
    final branch = line.changedBranch ?? line.branch;
    final relative = line.changedRelative ?? line.relative;
    final ganZhi = line.changedGanZhi ?? line.ganZhi;
    return ReviewChangedLine(
      sixRelative: '${relative.label}$ganZhi${branch.wuXing.label}',
      earthlyBranch: branch.label,
      displayExtra: null,
      identity: ReviewLineIdentity(
        relative: relative.label,
        ganZhi: ganZhi,
        element: branch.wuXing.label,
      ),
      movementType: line.changedIsYang == null
          ? (line.isYang ? MovementType.shaoYang : MovementType.shaoYin)
          : line.isMoving
          ? (line.changedIsYang! ? MovementType.laoYang : MovementType.laoYin)
          : (line.changedIsYang!
                ? MovementType.shaoYang
                : MovementType.shaoYin),
    );
  }

  static String? _xunKong(HexagramCase hexagramCase) {
    if (hexagramCase.calendar == null) return null;
    return xunKongOf(
      GanZhiDay.fromCycleIndex(
        _cycleIndexFor(hexagramCase.calendar!.dayGanZhi),
      ),
    ).label;
  }

  static bool _isXunKong(HexagramCase hexagramCase, DiZhi branch) {
    final calendar = hexagramCase.calendar;
    if (calendar == null) return false;
    return xunKongOf(
      GanZhiDay.fromCycleIndex(_cycleIndexFor(calendar.dayGanZhi)),
    ).contains(branch);
  }

  static String? _monthPillar(HexagramCase hexagramCase) =>
      hexagramCase.calendar == null
      ? null
      : '${CalendarPillars.monthGanZhi(TianGan.fromLabel(_yearLabel(hexagramCase).substring(0, 1)), hexagramCase.calendar!.monthBranch)}月';

  static String? _yearPillar(HexagramCase hexagramCase) {
    final calendar = hexagramCase.calendar;
    if (calendar == null) return null;
    final label =
        calendar.yearGanZhi ??
        CalendarPillars.yearGanZhi(
          LunarCalendar.dateFor(hexagramCase.createdAt),
        );
    if (label.isNotEmpty) return '年柱$label';
    return null;
  }

  static String? _yearNaYin(HexagramCase hexagramCase) {
    final calendar = hexagramCase.calendar;
    if (calendar == null) return null;
    final label =
        calendar.yearGanZhi ??
        CalendarPillars.yearGanZhi(
          LunarCalendar.dateFor(hexagramCase.createdAt),
        );
    return CalendarPillars.naYinFor(label);
  }

  static String? _hourPillar(HexagramCase hexagramCase) {
    final calendar = hexagramCase.calendar;
    if (calendar == null) return null;
    final label = calendar.hourGanZhi ?? _legacyHourGanZhi(hexagramCase);
    if (label != null) return '$label时';
    return null;
  }

  static String? _hourNaYin(HexagramCase hexagramCase) {
    final calendar = hexagramCase.calendar;
    if (calendar == null) return null;
    final label = calendar.hourGanZhi ?? _legacyHourGanZhi(hexagramCase);
    return label == null ? null : CalendarPillars.naYinFor(label);
  }

  static String? _legacyHourGanZhi(HexagramCase hexagramCase) {
    final shichen = hexagramCase.calendar?.shichen;
    final branchIndex = shichen == null
        ? null
        : '子丑寅卯辰巳午未申酉戌亥'.indexOf(shichen);
    if (branchIndex == null || branchIndex < 0) return null;
    return CalendarPillars.hourGanZhiForBranch(
      TianGan.fromLabel(hexagramCase.calendar!.dayGan),
      branchIndex,
    );
  }

  static String? _dayPillar(HexagramCase hexagramCase) =>
      hexagramCase.calendar == null
      ? null
      : '${hexagramCase.calendar!.dayGanZhi}日';

  static String? _monthNaYin(HexagramCase hexagramCase) {
    final calendar = hexagramCase.calendar;
    if (calendar == null) return null;
    final month = CalendarPillars.monthGanZhi(
      TianGan.fromLabel(_yearLabel(hexagramCase).substring(0, 1)),
      calendar.monthBranch,
    );
    return CalendarPillars.naYinFor(month);
  }

  static String? _dayNaYin(HexagramCase hexagramCase) {
    final label = hexagramCase.calendar?.dayGanZhi;
    return label == null ? null : CalendarPillars.naYinFor(label);
  }

  static String _yearLabel(HexagramCase hexagramCase) {
    final calendar = hexagramCase.calendar!;
    return calendar.yearGanZhi ??
        CalendarPillars.yearGanZhi(
          LunarCalendar.dateFor(hexagramCase.createdAt),
        );
  }

  static String? _lunarDateTime(HexagramCase hexagramCase) {
    final calendar = hexagramCase.calendar;
    if (calendar == null || calendar.lunarDate == null) return null;
    final shichen = calendar.shichen;
    return shichen == null
        ? calendar.lunarDate
        : '${calendar.lunarDate} · $shichen时';
  }

  static int _cycleIndexFor(String label) {
    final gan = TianGan.fromLabel(label.substring(0, 1));
    final zhi = DiZhi.fromLabel(label.substring(1));
    for (var i = 0; i < 60; i++) {
      if (TianGan.fromCycleIndex(i) == gan && DiZhi.values[i % 12] == zhi) {
        return i;
      }
    }
    throw ArgumentError.value(label, 'dayGanZhi', '非法干支');
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
