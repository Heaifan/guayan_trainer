/// 四柱中由日柱和当地时刻确定的年柱、时柱展示值。
library;

import '../rules/vocabulary/nayin_catalog.dart';
import '../tian_gan.dart';
import 'lunar_calendar.dart';

class CalendarPillars {
  CalendarPillars._();

  static String yearGanZhi(LunarDate lunarDate) {
    final index = (lunarDate.year - 1984) % 60;
    return '${TianGan.fromCycleIndex(index).label}${_branch(index)}';
  }

  static String hourGanZhi(TianGan dayGan, int hour) {
    final branchIndex = ((hour + 1) % 24) ~/ 2;
    return hourGanZhiForBranch(dayGan, branchIndex);
  }

  static String hourGanZhiForBranch(TianGan dayGan, int branchIndex) {
    final ziStem = switch (dayGan.index % 5) {
      0 => 0,
      1 => 2,
      2 => 4,
      3 => 6,
      _ => 8,
    };
    final stem = TianGan.values[(ziStem + branchIndex) % 10];
    return '${stem.label}${_branch(branchIndex)}';
  }

  static String monthGanZhi(TianGan yearGan, String branch) {
    final branchIndex = '子丑寅卯辰巳午未申酉戌亥'.indexOf(branch);
    if (branchIndex < 2) {
      throw ArgumentError.value(branch, 'branch', '月建必须为寅至亥');
    }
    final firstStem = switch (yearGan.index % 5) {
      0 => 2,
      1 => 4,
      2 => 6,
      3 => 8,
      _ => 0,
    };
    final stem = TianGan.values[(firstStem + branchIndex - 2) % 10];
    return '${stem.label}$branch';
  }

  static String naYinFor(String ganZhi) {
    final index = _cycleIndexFor(ganZhi);
    return NaYinCatalog.getByJiaZiIndex(index).name;
  }

  static String _branch(int index) => '子丑寅卯辰巳午未申酉戌亥'[index % 12];

  static int _cycleIndexFor(String label) {
    final gan = TianGan.fromLabel(label.substring(0, 1));
    final branch = label.substring(1);
    for (var i = 0; i < 60; i++) {
      if (TianGan.fromCycleIndex(i) == gan && _branch(i) == branch) {
        return i;
      }
    }
    throw ArgumentError.value(label, 'ganZhi', '非法干支');
  }
}
