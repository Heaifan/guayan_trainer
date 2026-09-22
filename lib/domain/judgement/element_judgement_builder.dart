library;

import '../calendar/day/ganzhi_day.dart';
import '../calendar/day/xun_kong.dart';
import '../casting/casting_engine.dart';
import '../casting/fushen_engine.dart';
import '../di_zhi.dart';
import '../hexagram_case.dart';
import '../line_state.dart';
import '../rules/facts/semantic_ref.dart';
import 'element_judgement.dart';

/// 把 HexagramCase 投影成“对象 -> 判定区”快照。
///
/// R4 在身份/空亡底座上追加受冲事实；空亡只记录状态，不削弱普通生克。
class ElementJudgementBuilder {
  ElementJudgementBuilder._();

  static ElementJudgementSnapshot build(HexagramCase hexagramCase) {
    final elements = <ElementJudgement>[];
    final kongWang = _kongWangOf(hexagramCase);
    final calendar = hexagramCase.calendar;
    final movingLines = [
      for (final line in hexagramCase.lines)
        if (line.movementType.isMoving && line.branch != null) line,
    ];

    for (final line in hexagramCase.lines) {
      elements.add(
        ElementJudgement(
          ref: SemanticRef.line(line.position),
          kind: JudgementElementKind.originalLine,
          position: line.position,
          branch: line.branch,
          identityTags: {
            JudgementTagIds.originalLine,
            line.movementType.isMoving
                ? JudgementTagIds.moving
                : JudgementTagIds.still,
          },
          stateTags: {
            ..._kongWangStateTags(line.branch, kongWang),
            ..._chongStateTags(
              branch: line.branch,
              monthBranch: calendar?.monthBranch,
              dayBranch: calendar?.dayBranch,
              movingLines: movingLines,
              targetPosition: line.position,
              includeMovingChong: true,
            ),
          },
          attributes: {
            'movementType': line.movementType.name,
            if (line.branch != null) 'branch': line.branch!,
          },
        ),
      );

      if (line.movementType.isMoving && line.changedBranch != null) {
        elements.add(
          ElementJudgement(
            ref: SemanticRef.changedLine(line.position),
            kind: JudgementElementKind.changedLine,
            position: line.position,
            branch: line.changedBranch,
            identityTags: const {JudgementTagIds.changedLine},
            stateTags: {
              ..._kongWangStateTags(line.changedBranch, kongWang),
              ..._chongStateTags(
                branch: line.changedBranch,
                monthBranch: calendar?.monthBranch,
                dayBranch: calendar?.dayBranch,
                movingLines: const [],
                includeMovingChong: false,
              ),
            },
            attributes: {
              'originPosition': line.position.toString(),
              'branch': line.changedBranch!,
            },
          ),
        );
      }
    }

    if (calendar != null) {
      elements
        ..add(
          ElementJudgement(
            ref: SemanticRef.month,
            kind: JudgementElementKind.month,
            branch: calendar.monthBranch,
            identityTags: const {JudgementTagIds.month},
            attributes: {'branch': calendar.monthBranch},
          ),
        )
        ..add(
          ElementJudgement(
            ref: SemanticRef.day,
            kind: JudgementElementKind.day,
            branch: calendar.dayBranch,
            identityTags: const {JudgementTagIds.day},
            attributes: {
              'branch': calendar.dayBranch,
              'ganZhi': calendar.dayGanZhi,
            },
          ),
        );
    }

    final chart = CastingEngine.cast([
      for (final line in hexagramCase.lines) line.movementType,
    ]);
    for (final fushen in FushenEngine.calculate(chart)) {
      elements.add(
        ElementJudgement(
          ref: SemanticRef.hiddenSpirit(fushen.lineIndex),
          kind: JudgementElementKind.hiddenSpirit,
          position: fushen.lineIndex,
          branch: fushen.branch.label,
          identityTags: const {JudgementTagIds.hiddenSpirit},
          stateTags: {
            JudgementTagIds.hidden,
            ..._kongWangStateTags(fushen.branch.label, kongWang),
            ..._chongStateTags(
              branch: fushen.branch.label,
              monthBranch: calendar?.monthBranch,
              dayBranch: calendar?.dayBranch,
              movingLines: const [],
              includeMovingChong: false,
            ),
          },
          attributes: {
            'branch': fushen.branch.label,
            'relative': fushen.relative.name,
            'element': fushen.element.label,
            'flyingLineId': fushen.flyingLineId,
          },
        ),
      );
    }

    return ElementJudgementSnapshot(elements);
  }

  static Set<String> _kongWangStateTags(String? branch, XunKong? kongWang) {
    if (branch == null || kongWang == null) return const {};
    final zhi = DiZhi.tryFromLabel(branch);
    if (zhi == null || !kongWang.contains(zhi)) return const {};
    return const {JudgementTagIds.kongWang};
  }

  static Set<String> _chongStateTags({
    required String? branch,
    required String? monthBranch,
    required String? dayBranch,
    required List<LineState> movingLines,
    int? targetPosition,
    required bool includeMovingChong,
  }) {
    final target = branch == null ? null : DiZhi.tryFromLabel(branch);
    if (target == null) return const {};

    final tags = <String>{};
    final month = monthBranch == null ? null : DiZhi.tryFromLabel(monthBranch);
    final day = dayBranch == null ? null : DiZhi.tryFromLabel(dayBranch);

    if (month != null && month.chong == target) {
      tags.add(JudgementTagIds.monthChong);
    }
    if (day != null && day.chong == target) {
      tags.add(JudgementTagIds.dayChong);
    }
    if (includeMovingChong) {
      for (final source in movingLines) {
        if (source.position == targetPosition) continue;
        final sourceBranch = DiZhi.tryFromLabel(source.branch!);
        if (sourceBranch != null && sourceBranch.chong == target) {
          tags.add(JudgementTagIds.movingChong);
          break;
        }
      }
    }
    if (tags.isNotEmpty) tags.add(JudgementTagIds.chong);
    return tags;
  }

  static XunKong? _kongWangOf(HexagramCase hexagramCase) {
    final label = hexagramCase.calendar?.dayGanZhi;
    if (label == null) return null;
    final day = _ganZhiDayFromLabel(label);
    return day == null ? null : xunKongOf(day);
  }

  static GanZhiDay? _ganZhiDayFromLabel(String label) {
    for (var i = 0; i < 60; i++) {
      final day = GanZhiDay.fromCycleIndex(i);
      if (day.label == label) return day;
    }
    return null;
  }
}
