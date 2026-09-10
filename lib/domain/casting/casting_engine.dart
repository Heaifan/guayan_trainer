/// R3 排盘引擎：由六爻动静推出完整排盘。
///
/// 纯 Dart 业务层，零 Flutter 依赖 —— Widget 一律不得自行排卦。
///
/// 覆盖：八卦映射 / 六十四卦映射 / 动爻变化 / 本卦 / 变卦 /
/// 纳甲（干支）/ 世应 / 六亲 / 六神。
/// 四柱·月建·日辰·旬空需要干支历法，由 `gan_zhi_calendar.dart` 提供后接入。
library;

import '../line_state.dart';
import '../tian_gan.dart';
import 'cast_chart.dart';
import 'hexagram64.dart';
import 'najia.dart';
import 'six_relative.dart';
import 'six_spirit.dart';

/// 排盘引擎（无状态，全部静态纯函数）。
class CastingEngine {
  CastingEngine._();

  /// 由六爻动静（自初爻至上爻）排盘。
  ///
  /// [dayGan] 仅用于六神起例；为 null 时六神一律为 null（不猜默认日干）。
  /// 返回值恒为非空；非法输入抛 [ArgumentError]，绝不返回半成品。
  static CastChart cast(
    List<MovementType> movementTypes, {
    TianGan? dayGan,
  }) {
    if (movementTypes.length != 6) {
      throw ArgumentError.value(
        movementTypes,
        'movementTypes',
        '必须恰好 6 爻',
      );
    }

    final originalLines = [
      for (final m in movementTypes) isYangMovement(m),
    ];
    final changedLines = [
      for (final m in movementTypes) changedIsYang(m),
    ];

    final original = resolveHexagram(originalLines);
    final hasMoving = movementTypes.any((m) => m.isMoving);
    // 静卦无变卦：不生成"与本卦相同"的伪变卦。
    final changed = hasMoving ? resolveHexagram(changedLines) : null;

    final originalGans = najiaGans(original.lower, original.upper);
    final originalBranches = najiaLines(original.lower, original.upper);

    final changedGans =
        changed == null ? null : najiaGans(changed.lower, changed.upper);
    final changedBranches =
        changed == null ? null : najiaLines(changed.lower, changed.upper);

    final spirits = dayGan == null ? null : sixSpiritsFor(dayGan);

    final lines = <CastLine>[
      for (var i = 0; i < 6; i++)
        CastLine(
          position: i + 1,
          isYang: originalLines[i],
          isMoving: movementTypes[i].isMoving,
          gan: originalGans[i],
          branch: originalBranches[i],
          // 六亲取「本卦之宫」为我的五行。
          relative: sixRelativeOf(original.palace, originalBranches[i]),
          spirit: spirits?[i],
          isShi: i + 1 == original.shiPosition,
          isYing: i + 1 == original.yingPosition,
          changedIsYang: changed == null ? null : changedLines[i],
          changedGan: changedGans?[i],
          changedBranch: changedBranches?[i],
          // 变卦六亲同样以本卦之宫为「我」。
          changedRelative: changedBranches == null
              ? null
              : sixRelativeOf(original.palace, changedBranches[i]),
        ),
    ];

    return CastChart(
      original: original,
      changed: changed,
      lines: lines,
      movingPositions: [
        for (var i = 0; i < 6; i++)
          if (movementTypes[i].isMoving) i + 1,
      ],
      dayGan: dayGan,
    );
  }
}

/// 本卦阴阳：少阳/老阳为阳。
bool isYangMovement(MovementType m) =>
    m == MovementType.shaoYang || m == MovementType.laoYang;

/// 变卦阴阳：老阳变阴、老阴变阳，少阴少阳不变。
bool changedIsYang(MovementType m) => switch (m) {
      MovementType.shaoYang => true,
      MovementType.laoYang => false,
      MovementType.shaoYin => false,
      MovementType.laoYin => true,
    };
