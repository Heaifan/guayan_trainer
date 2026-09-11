/// 数据包**逐节气来源覆盖**（`sourceOverride`）的校验。
///
/// 刻意保持最小：只支持「年度默认来源 + 可选逐节气覆盖」这一层，
/// 不引入通用 provenance 框架（本轮只需表达「这一条来自别处」）。
library;

import 'calendar_data_pack.dart';

/// 逐节气来源覆盖的规则。
class CalendarDataPackTermSource {
  const CalendarDataPackTermSource._();

  /// 校验单条的 `sourceOverride`，把问题追加进 [problems]。
  static void check(CalendarDataPackTerm raw, int i, List<String> problems) {
    if (!raw.hasSourceOverride) return;
    if (raw.sourceName == null || raw.sourceName!.isEmpty) {
      problems.add('terms[$i].sourceOverride 缺少 name');
    }
    if (raw.sourceReference == null || raw.sourceReference!.isEmpty) {
      problems.add('terms[$i].sourceOverride 缺少 reference');
    }
  }
}
