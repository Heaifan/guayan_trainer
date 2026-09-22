library;

import '../calendar/day/ganzhi_day.dart';
import '../calendar/day/xun_kong.dart';
import '../casting/casting_engine.dart';
import '../casting/fushen_engine.dart';
import '../di_zhi.dart';
import '../hexagram_case.dart';
import '../rules/facts/semantic_ref.dart';
import 'element_judgement.dart';

/// 把 HexagramCase 投影成“对象 -> 判定区”快照。
///
/// R2 在身份底座上追加旬空状态；仍不裁决冲合、生克或作用资格。
class ElementJudgementBuilder {
  ElementJudgementBuilder._();

  static ElementJudgementSnapshot build(HexagramCase hexagramCase) {
    final elements = <ElementJudgement>[];
    final xunKong = _xunKongOf(hexagramCase);

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
          stateTags: _emptyStateTags(line.branch, xunKong),
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
            stateTags: _emptyStateTags(line.changedBranch, xunKong),
            attributes: {
              'originPosition': line.position.toString(),
              'branch': line.changedBranch!,
            },
          ),
        );
      }
    }

    final calendar = hexagramCase.calendar;
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
            ..._emptyStateTags(fushen.branch.label, xunKong),
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

  static Set<String> _emptyStateTags(String? branch, XunKong? xunKong) {
    if (branch == null || xunKong == null) return const {};
    final zhi = DiZhi.tryFromLabel(branch);
    if (zhi == null || !xunKong.contains(zhi)) return const {};
    return const {JudgementTagIds.empty};
  }

  static XunKong? _xunKongOf(HexagramCase hexagramCase) {
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
