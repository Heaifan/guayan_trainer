import '../../domain/calendar/calendar_engine.dart';
import '../../domain/calendar/calendar_request.dart';
import '../../domain/calendar/day_boundary_rule.dart';
import '../../domain/calendar_snapshot.dart';

/// 一次排卦使用的历法快照工厂。
///
/// 历法计算只发生在生成时，审卦与关系层只读取 [CalendarSnapshot]。
class CastingCalendarService {
  const CastingCalendarService(this._engine);

  static const utcOffset = Duration(hours: 8);
  static const dayBoundaryRule = DayBoundaryRule.midnight;

  final CalendarEngine _engine;

  CalendarSnapshot snapshotFor(DateTime localDateTime) {
    final context = _engine.resolve(
      CalendarRequest(
        localDateTime: localDateTime,
        utcOffset: utcOffset,
        dayBoundaryRule: dayBoundaryRule,
      ),
    );
    return CalendarSnapshot(
      monthBranch: context.monthBranchLabel,
      dayGanZhi: context.dayGanZhi,
    );
  }
}
