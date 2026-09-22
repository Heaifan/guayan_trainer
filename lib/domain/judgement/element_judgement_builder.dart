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

/// 把 HexagramCase 投影成“对象身份 + 属性 + 状态判断结果”快照。
///
/// 本层只产出单个对象的状态判断结果。
/// 关系与作用行为不写入 ElementJudgement。
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
          identity: ElementIdentity(
            ref: SemanticRef.line(line.position),
            kind: JudgementElementKind.originalLine,
            position: line.position,
            movementType: line.movementType,
          ),
          branch: line.branch,
          states: {
            ..._kongWangStates(line.branch, kongWang),
            ..._chongStates(
              branch: line.branch,
              monthBranch: calendar?.monthBranch,
              dayBranch: calendar?.dayBranch,
              movingLines: movingLines,
              targetPosition: line.position,
              includeMovingChong: true,
            ),
          },
          attributes: {
            if (line.branch != null) 'branch': line.branch!,
          },
        ),
      );

      if (line.movementType.isMoving && line.changedBranch != null) {
        elements.add(
          ElementJudgement(
            identity: ElementIdentity(
              ref: SemanticRef.changedLine(line.position),
              kind: JudgementElementKind.changedLine,
              position: line.position,
            ),
            branch: line.changedBranch,
            states: {
              ..._kongWangStates(line.changedBranch, kongWang),
              ..._chongStates(
                branch: line.changedBranch,
                monthBranch: calendar?.monthBranch,
                dayBranch: calendar?.dayBranch,
                movingLines: const [],
                includeMovingChong: false,
              ),
            },
            attributes: {
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
            identity: const ElementIdentity(
              ref: SemanticRef.month,
              kind: JudgementElementKind.month,
            ),
            branch: calendar.monthBranch,
            attributes: {'branch': calendar.monthBranch},
          ),
        )
        ..add(
          ElementJudgement(
            identity: const ElementIdentity(
              ref: SemanticRef.day,
              kind: JudgementElementKind.day,
            ),
            branch: calendar.dayBranch,
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
          identity: ElementIdentity(
            ref: SemanticRef.hiddenSpirit(fushen.lineIndex),
            kind: JudgementElementKind.hiddenSpirit,
            position: fushen.lineIndex,
          ),
          branch: fushen.branch.label,
          states: {
            JudgementStateIds.hidden,
            ..._kongWangStates(fushen.branch.label, kongWang),
            ..._chongStates(
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

  static Set<String> _kongWangStates(String? branch, XunKong? kongWang) {
    if (branch == null || kongWang == null) return const {};
    final zhi = DiZhi.tryFromLabel(branch);
    if (zhi == null || !kongWang.contains(zhi)) return const {};
    return const {JudgementStateIds.kongWang};
  }

  static Set<String> _chongStates({
    required String? branch,
    required String? monthBranch,
    required String? dayBranch,
    required List<LineState> movingLines,
    int? targetPosition,
    required bool includeMovingChong,
  }) {
    final target = branch == null ? null : DiZhi.tryFromLabel(branch);
    if (target == null) return const {};

    final states = <String>{};
    final month = monthBranch == null ? null : DiZhi.tryFromLabel(monthBranch);
    final day = dayBranch == null ? null : DiZhi.tryFromLabel(dayBranch);

    if (month != null && month.chong == target) {
      states.add(JudgementStateIds.monthChong);
    }
    if (day != null && day.chong == target) {
      states.add(JudgementStateIds.dayChong);
    }
    if (includeMovingChong) {
      for (final source in movingLines) {
        if (source.position == targetPosition) continue;
        final sourceBranch = DiZhi.tryFromLabel(source.branch!);
        if (sourceBranch != null && sourceBranch.chong == target) {
          states.add(JudgementStateIds.movingChong);
          break;
        }
      }
    }
    if (states.isNotEmpty) states.add(JudgementStateIds.chong);
    return states;
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
