import 'cast_chart.dart';
import 'fushen.dart';
import 'hexagram64.dart';
import 'najia.dart';
import 'six_relative.dart';

/// 本宫伏神引擎：只计算结构事实，不判断飞伏生克或吉凶。
class FushenEngine {
  FushenEngine._();

  static const ruleSetId = 'fushen.bengong.v1';
  static const ruleVersion = '1';

  /// 找出主卦缺失的六亲，并将其伏在本宫首卦的同一爻位。
  static List<FushenResult> calculate(CastChart chart) {
    final present = {for (final line in chart.lines) line.relative};
    final missing = SixRelative.values.where(
      (relative) => !present.contains(relative),
    );
    if (missing.isEmpty) return const [];

    final root = resolveHexagram([
      ...chart.original.palace.lines,
      ...chart.original.palace.lines,
    ]);
    final rootGans = najiaGans(root.lower, root.upper);
    final rootBranches = najiaLines(root.lower, root.upper);
    final results = <FushenResult>[];

    for (final relative in missing) {
      for (var index = 0; index < rootBranches.length; index++) {
        if (sixRelativeOf(root.palace, rootBranches[index]) != relative) {
          continue;
        }
        final position = index + 1;
        final flying = chart.lineAt(position);
        results.add(
          FushenResult(
            lineIndex: position,
            relative: relative,
            stem: rootGans[index],
            branch: rootBranches[index],
            element: rootBranches[index].wuXing,
            sourcePalace: root.palace,
            sourceHexagramId: root.name,
            flyingLineId: 'line-$position',
            ruleSetId: ruleSetId,
            ruleVersion: ruleVersion,
            reasonSnapshot:
                '主卦${chart.original.name}属${root.palace.label}宫；'
                '主卦六爻无${relative.label}；${root.name}$position爻为'
                '${relative.label}${rootGans[index].label}${rootBranches[index].label}'
                '${rootBranches[index].wuXing.label}；故伏于本卦$position爻'
                '${flying.relative.label}${flying.ganZhi}${flying.branch.wuXing.label}之下。',
          ),
        );
      }
    }
    return results;
  }
}
