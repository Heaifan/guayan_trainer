/// 历法测试夹具：构造数据包 JSON + 读取真实种子数据包。
library;

import 'dart:convert';
import 'dart:io';

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';

/// 24 个节气机器名，按公历年内顺序（自小寒起）。
List<String> get termNames => [for (final id in SolarTermId.values) id.name];

/// 生成一年 24 条递增节气瞬间：小寒落在 1 月，冬至落在 12 月。
List<Map<String, Object?>> defaultTerms(int year) => [
  for (var i = 0; i < 24; i++)
    {
      'term': termNames[i],
      'instantUtc': _iso(
        DateTime.utc(year, 1, 5).add(Duration(minutes: i * 21888)),
      ),
    },
];

/// 构造数据包 JSON 文本；可用 [overrides] 覆盖任意顶层字段。
String packJson({
  int? year = 2026,
  int? revision = 1,
  int? schemaVersion = 1,
  Object? timeStandard = 'UTC',
  Object? sourceName = 'Test Source',
  Object? sourceReference = 'https://example.invalid/x',
  Object? generatedAt = '2026-01-01T00:00:00Z',
  List<Map<String, Object?>>? terms,
  Map<String, Object?> overrides = const {},
}) {
  final map = <String, Object?>{
    'schemaVersion': schemaVersion,
    'calendarYear': year,
    'timeStandard': timeStandard,
    'revision': revision,
    'source': {
      'name': sourceName,
      'reference': sourceReference,
      'generatedAt': generatedAt,
    },
    'terms': terms ?? defaultTerms(year ?? 2026),
  };
  map.addAll(overrides);
  map.removeWhere((_, v) => v == null);
  if (map['source'] is Map) {
    (map['source']! as Map).removeWhere((_, v) => v == null);
  }
  return jsonEncode(map);
}

/// 读取 `assets/calendar/<year>.calendar.json`（真实种子数据包）。
String readSeedPack(int year) =>
    File('assets/calendar/$year.calendar.json').readAsStringSync();

/// 种子年份（与生成器输出保持一致）。
///
/// 这是**测试/种子年份，不是产品的永久支持范围**：
/// 其他年份由用户导入数据包获得，无需重新编译。
const seedYears = <int>[
  2019,
  2020,
  2021,
  2022,
  2023,
  2024,
  2025,
  2026,
  2027,
  2028,
];

String _iso(DateTime utc) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-'
      '${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:'
      '${two(utc.second)}Z';
}
