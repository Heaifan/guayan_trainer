/// 年度历法数据包解析器：JSON 文本 → [CalendarDataPack]。
///
/// 只负责**语法与结构**：JSON 是否合法、根节点与 terms 形状是否正确。
/// 字段缺失、类型错误、年份不符等**语义问题一律交给校验器**汇总，
/// 以便一次性报出全部原因，而不是抛出第一个错就停。
library;

import 'dart:convert';

import '../calendar_error.dart';
import 'calendar_data_pack.dart';

/// 数据包解析器（无状态）。
class CalendarDataPackParser {
  const CalendarDataPackParser._();

  /// 解析 JSON 文本；语法或结构错误抛 [CalendarDataPackInvalid]。
  static CalendarDataPack parse(String json) {
    final Object? root;
    try {
      root = jsonDecode(json);
    } on FormatException catch (e) {
      throw CalendarDataPackInvalid(['JSON 语法错误：${e.message}']);
    }
    if (root is! Map) {
      throw const CalendarDataPackInvalid(['数据包根节点必须是 JSON 对象']);
    }

    final termsRaw = root['terms'];
    if (termsRaw is! List) {
      throw const CalendarDataPackInvalid(['terms 必须是数组']);
    }
    final terms = <CalendarDataPackTerm>[
      for (var i = 0; i < termsRaw.length; i++) _term(termsRaw[i], i),
    ];

    final sourceRaw = root['source'];
    final source = sourceRaw is Map ? sourceRaw : const <String, Object?>{};

    return CalendarDataPack(
      schemaVersion: _int(root['schemaVersion']),
      calendarYear: _int(root['calendarYear']),
      timeStandard: _str(root['timeStandard']),
      revision: _int(root['revision']),
      sourceName: _str(source['name']),
      sourceReference: _str(source['reference']),
      generatedAt: _str(source['generatedAt']),
      terms: terms,
    );
  }

  /// 解析单条节气记录（含可选的 precision / sourceOverride）。
  static CalendarDataPackTerm _term(Object? entry, int i) {
    if (entry is! Map) {
      throw CalendarDataPackInvalid(['terms[$i] 必须是对象']);
    }
    final overrideRaw = entry['sourceOverride'];
    final override = overrideRaw is Map
        ? overrideRaw
        : const <Object?, Object?>{};
    return CalendarDataPackTerm(
      term: _str(entry['term']),
      instantUtc: _str(entry['instantUtc']),
      precision: _str(entry['precision']),
      sourceName: _str(override['name']),
      sourceReference: _str(override['reference']),
      sourceNote: _str(override['note']),
      hasSourceOverride: overrideRaw != null,
      hasPrecisionKey: entry.containsKey('precision'),
    );
  }

  static int? _int(Object? v) => v is int ? v : null;

  static String? _str(Object? v) => v is String ? v : null;
}
