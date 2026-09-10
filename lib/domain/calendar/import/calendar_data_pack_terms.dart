/// 数据包节气列表的解析与规则校验（从校验器拆出的单一职责单元）。
///
/// 只管「24 条节气本身」；schema / source / revision 等元数据由校验器负责。
library;

import '../solar_term/solar_term.dart';
import '../solar_term/solar_term_id.dart';
import 'calendar_data_pack.dart';

/// 节气列表校验规则。
class CalendarDataPackTerms {
  const CalendarDataPackTerms._();

  /// 每年必须恰好 24 个节气。
  static const int requiredTermCount = 24;

  /// 解析并检查节气列表，把问题追加进 [problems]。
  static List<SolarTerm> parse(CalendarDataPack pack, List<String> problems) {
    if (pack.terms.length != requiredTermCount) {
      problems.add('节气数量必须是 $requiredTermCount，实际 ${pack.terms.length}');
    }
    final seen = <SolarTermId>{};
    final terms = <SolarTerm>[];
    var previous = DateTime.utc(0);
    var first = true;

    for (var i = 0; i < pack.terms.length; i++) {
      final raw = pack.terms[i];
      final id = _termIdOf(raw.term);
      if (id == null) {
        problems.add('terms[$i].term 未知：${raw.term}');
        continue;
      }
      if (!seen.add(id)) {
        problems.add('terms[$i].term 重复：${id.name}');
      }
      final instant = DateTime.tryParse(raw.instantUtc ?? '');
      if (instant == null) {
        problems.add('terms[$i].instantUtc 不可解析：${raw.instantUtc}');
        continue;
      }
      if (!raw.instantUtc!.endsWith('Z')) {
        problems.add('terms[$i].instantUtc 必须为 UTC（以 Z 结尾）：${raw.instantUtc}');
      }
      final utc = instant.toUtc();
      if (!first && !utc.isAfter(previous)) {
        problems.add('terms[$i] 时间未严格递增：${raw.instantUtc}');
      }
      previous = utc;
      first = false;
      terms.add(SolarTerm(id: id, instantUtc: utc));
    }
    return terms;
  }

  /// 年份合理性：按**真实节气范围**判定（小寒必在 1 月、冬至必在 12 月），
  /// 外加 ±1 日外包围窗口。刻意不使用「全部落在 Y-01-01～12-31」这类僵硬
  /// 全范围规则，以免误杀跨公历年边界的正确数据。
  static void checkYearWindow(
    int year,
    List<SolarTerm> terms,
    List<String> problems,
  ) {
    if (terms.length != requiredTermCount) return;

    final edges = <(String, SolarTerm, SolarTermId, int)>[
      ('首条', terms.first, SolarTermId.xiaoHan, 1),
      ('末条', terms.last, SolarTermId.dongZhi, 12),
    ];
    for (final (label, term, expectedId, month) in edges) {
      if (term.id != expectedId ||
          term.instantUtc.year != year ||
          term.instantUtc.month != month) {
        problems.add(
          '$label 应为 $year 年 $month 月的${expectedId.label}，实际 '
          '${term.id.name} @ ${term.instantUtc.toIso8601String()}',
        );
      }
    }

    final low = DateTime.utc(year).subtract(const Duration(days: 1));
    final high = DateTime.utc(
      year,
      12,
      31,
      23,
      59,
      59,
    ).add(const Duration(days: 1));
    for (final t in terms) {
      if (t.instantUtc.isBefore(low) || t.instantUtc.isAfter(high)) {
        problems.add(
          '${t.id.name} 超出 $year 年合理范围：'
          '${t.instantUtc.toIso8601String()}',
        );
      }
    }
  }

  static SolarTermId? _termIdOf(String? name) {
    if (name == null) return null;
    for (final id in SolarTermId.values) {
      if (id.name == name) return id;
    }
    return null;
  }
}
