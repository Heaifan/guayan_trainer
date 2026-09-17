import '../../domain/calendar/calendar_engine.dart';
import '../../domain/calendar/calendar_request.dart';
import '../../domain/calendar/calendar_pillars.dart';
import '../../domain/calendar/day_boundary_rule.dart';
import '../../domain/calendar/lunar_calendar.dart';
import '../../domain/calendar_snapshot.dart';
import '../../domain/casting/hexagram64.dart';
import '../../domain/tian_gan.dart';
import '../../domain/shensha/shensha_engine.dart';
import '../../domain/shensha/shensha_models.dart';

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
    final lunar = LunarCalendar.dateFor(localDateTime);
    final dayGan = context.dayGanZhi.substring(0, 1);
    return CalendarSnapshot(
      monthBranch: context.monthBranchLabel,
      dayGanZhi: context.dayGanZhi,
      lunarDate: lunar.displayLabel,
      shichen: _shichenForHour(localDateTime.hour),
      yearGanZhi: CalendarPillars.yearGanZhi(lunar),
      hourGanZhi: CalendarPillars.hourGanZhi(
        TianGan.fromLabel(dayGan),
        localDateTime.hour,
      ),
    );
  }

  /// 在排盘生成时把神煞结果写入同一份历法快照。
  CalendarSnapshot withHexagram(CalendarSnapshot snapshot, Hexagram hexagram) {
    final yearGanZhi = snapshot.yearGanZhi;
    final hourGanZhi = snapshot.hourGanZhi;
    if (yearGanZhi == null || hourGanZhi == null) return snapshot;
    final monthGanZhi = CalendarPillars.monthGanZhi(
      TianGan.fromLabel(yearGanZhi.substring(0, 1)),
      snapshot.monthBranch,
    );
    final results = const ShenShaEngine().calculate(
      ShenShaContext(
        yearGanZhi: yearGanZhi,
        monthGanZhi: monthGanZhi,
        dayGanZhi: snapshot.dayGanZhi,
        hourGanZhi: hourGanZhi,
        shiPosition: hexagram.shiPosition,
        shiIsYang: hexagram.isYangAt(hexagram.shiPosition),
      ),
    );
    return snapshot.copyWith(shenShaResults: results);
  }

  static String _shichenForHour(int hour) {
    const names = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    return names[((hour + 1) % 24) ~/ 2];
  }
}
