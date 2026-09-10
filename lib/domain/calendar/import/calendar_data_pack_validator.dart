/// 年度历法数据包校验器：原始数据包 → 可信的 [CalendarYearData]。
///
/// 任何一条不通过即整体拒绝（抛 [CalendarDataPackInvalid]，携带全部原因）。
/// 校验通过前绝不触碰已安装数据，这是导入原子性的第一道保证。
///
/// 职责边界：本文件只管**元数据**（schema / 年份 / 来源 / revision），
/// 节气列表本身的规则见 [CalendarDataPackTerms]。
library;

import '../calendar_error.dart';
import '../solar_term/calendar_year_data.dart';
import 'calendar_data_pack.dart';
import 'calendar_data_pack_terms.dart';

/// 数据包校验器（无状态）。
class CalendarDataPackValidator {
  const CalendarDataPackValidator._();

  /// 当前支持的数据包结构版本。
  static const int supportedSchemaVersion = 1;

  /// 校验并转换；失败抛 [CalendarDataPackInvalid]。
  static CalendarYearData validate(CalendarDataPack pack) {
    final problems = <String>[];

    _checkMetadata(pack, problems);
    final terms = CalendarDataPackTerms.parse(pack, problems);

    // 只有在元数据与节气都干净时才做年份合理性判断，
    // 否则会产生大量由同一根因派生的噪音问题。
    if (problems.isEmpty) {
      CalendarDataPackTerms.checkYearWindow(
        pack.calendarYear!,
        terms,
        problems,
      );
    }
    if (problems.isNotEmpty) throw CalendarDataPackInvalid(problems);

    return CalendarYearData(
      calendarYear: pack.calendarYear!,
      schemaVersion: pack.schemaVersion!,
      revision: pack.revision!,
      sourceName: pack.sourceName!,
      sourceReference: pack.sourceReference!,
      generatedAt: DateTime.parse(pack.generatedAt!).toUtc(),
      terms: terms,
    );
  }

  static void _checkMetadata(CalendarDataPack pack, List<String> problems) {
    if (pack.schemaVersion == null) {
      problems.add('缺少 schemaVersion');
    } else if (pack.schemaVersion != supportedSchemaVersion) {
      problems.add(
        'schemaVersion 不支持：${pack.schemaVersion}'
        '（支持 $supportedSchemaVersion）',
      );
    }

    if (pack.calendarYear == null) {
      problems.add('缺少 calendarYear');
    } else if (pack.calendarYear! < 1 || pack.calendarYear! > 9999) {
      problems.add('calendarYear 非法：${pack.calendarYear}');
    }

    if (pack.timeStandard == null) {
      problems.add('缺少 timeStandard');
    } else if (pack.timeStandard != 'UTC') {
      problems.add('timeStandard 必须为 UTC，实际 ${pack.timeStandard}');
    }

    if (pack.revision == null) {
      problems.add('缺少 revision');
    } else if (pack.revision! < 1) {
      problems.add('revision 必须 >= 1，实际 ${pack.revision}');
    }

    if (pack.sourceName == null || pack.sourceName!.isEmpty) {
      problems.add('缺少 source.name');
    }
    if (pack.sourceReference == null || pack.sourceReference!.isEmpty) {
      problems.add('缺少 source.reference');
    }
    if (DateTime.tryParse(pack.generatedAt ?? '') == null) {
      problems.add('source.generatedAt 缺失或不可解析');
    }
  }
}
