/// 年度历法数据包导入器：解析 → 校验 → 修订判定 → 原子提交。
///
/// 职责**仅限**这三件事：不涉及 UI、文件选择、权限、弹窗。
/// 调用方（未来的历法管理页）只需把数据包内容交进来。
///
/// 原子性：校验全部通过之前绝不写仓储，因此不存在
/// 「导了一半失败、留下半套数据」的中间态。
library;

import '../calendar_error.dart';
import '../solar_term/calendar_year_data.dart';
import '../store/calendar_data_store.dart';
import 'calendar_data_pack_parser.dart';
import 'calendar_data_pack_validator.dart';

/// 本次导入相对已安装数据的变更类型。
enum CalendarPackChange {
  /// 该年从未安装。
  isNew,

  /// revision 更高，属升级。
  update,

  /// revision 相同，幂等空操作。
  same,

  /// revision 更低，拒绝降级。
  downgrade,
}

/// 数据包导入器。
class CalendarDataPackImporter {
  const CalendarDataPackImporter(this.store);

  final CalendarDataStore store;

  /// 导入一个年度数据包，返回变更类型。
  ///
  /// 抛 [CalendarDataPackInvalid]（内容不合法）或
  /// [CalendarRevisionRejected]（降级导入）。两种情况下
  /// 已安装数据均保持**完全不变**。
  Future<CalendarPackChange> importPack(String json) async {
    // 1) 解析 + 2) 校验：任一步失败即整体拒绝，仓储尚未被触碰。
    final pack = CalendarDataPackParser.parse(json);
    final data = CalendarDataPackValidator.validate(pack);

    // 3) 修订判定。
    final installed = await store.loadYear(data.calendarYear);
    final change = changeOf(installed, data);
    if (change == CalendarPackChange.downgrade) {
      throw CalendarRevisionRejected(
        calendarYear: data.calendarYear,
        installed: installed!.revision,
        incoming: data.revision,
      );
    }
    if (change == CalendarPackChange.same) {
      return change;
    }

    // 4) 提交（数据此刻已完整可信）。
    await store.saveYear(data);
    return change;
  }

  /// 修订判定（纯函数，便于单测）。
  static CalendarPackChange changeOf(
    CalendarYearData? installed,
    CalendarYearData incoming,
  ) {
    if (installed == null) return CalendarPackChange.isNew;
    if (incoming.revision > installed.revision) {
      return CalendarPackChange.update;
    }
    if (incoming.revision == installed.revision) {
      return CalendarPackChange.same;
    }
    return CalendarPackChange.downgrade;
  }
}
