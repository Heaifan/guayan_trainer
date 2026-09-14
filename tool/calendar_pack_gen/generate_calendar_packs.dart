/// 年度历法数据包生成器（**开发阶段工具，不参与 App 运行时**）。
///
/// 数据来源：香港天文台（HKO）二十四节气日期及時間資料。
/// HKO 注明其天文数据来自英国 HM Nautical Almanac Office 与美国
/// United States Naval Observatory；时间基准为香港时间（UTC+8）。
/// 端点：`https://www.hko.gov.hk/en/gts/astronomy/data/files/24SolarTerms_<YEAR>.xml`
///
/// HKO 仅提供到分钟，因此本生成器输出的瞬间秒位恒为 `:00`。
/// 这是**如实记录来源精度**，不虚构秒级精度。
///
/// 用法（仓库根目录）：
/// ```text
/// dart run tool/calendar_pack_gen/generate_calendar_packs.dart 2024 2025 2026 2027 2028
/// ```
library;

import 'dart:convert';
import 'dart:io';

/// 节气机器名，顺序必须与 HKO 返回顺序（自小寒起 24 条）一致。
const termNames = <String>[
  'xiaoHan',
  'daHan',
  'liChun',
  'yuShui',
  'jingZhe',
  'chunFen',
  'qingMing',
  'guYu',
  'liXia',
  'xiaoMan',
  'mangZhong',
  'xiaZhi',
  'xiaoShu',
  'daShu',
  'liQiu',
  'chuShu',
  'baiLu',
  'qiuFen',
  'hanLu',
  'shuangJiang',
  'liDong',
  'xiaoXue',
  'daXue',
  'dongZhi',
];

const _hkoBase =
    'https://www.hko.gov.hk/en/gts/astronomy/data/files/24SolarTerms_';
const _hktOffsetHours = 8;
const _cacheDir = 'tool/calendar_pack_gen/.cache';
const _outDir = 'assets/calendar';

Future<void> main(List<String> args) async {
  final years = args.isEmpty
      ? <int>[2024, 2025, 2026, 2027, 2028]
      : args.map(int.parse).toList();
  Directory(_cacheDir).createSync(recursive: true);
  Directory(_outDir).createSync(recursive: true);

  for (final year in years) {
    final xml = await _sourceXml(year);
    final entries = _parseHko(xml, year);
    if (entries.length != 24) {
      stderr.writeln('$year: 期望 24 条，实际 ${entries.length} —— 已跳过');
      exitCode = 1;
      continue;
    }
    final pack = _buildPack(year, entries);
    final path = '$_outDir/$year.calendar.json';
    File(path).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(pack) + '\n',
    );
    stdout.writeln('$year -> $path  (${entries.length} terms)');
  }
}

/// 读本地缓存，缺失则联网抓取（仅开发阶段）。
Future<String> _sourceXml(int year) async {
  final cache = File('$_cacheDir/hko_$year.xml');
  if (cache.existsSync()) return cache.readAsStringSync();

  final client = HttpClient();
  try {
    final req = await client.getUrl(Uri.parse('$_hkoBase$year.xml'));
    final res = await req.close();
    if (res.statusCode != 200) {
      throw StateError('HKO $year 返回 ${res.statusCode}');
    }
    final body = await res.transform(utf8.decoder).join();
    cache.writeAsStringSync(body);
    return body;
  } finally {
    client.close();
  }
}

/// 解析 HKO `<Data><M>01</M><D>05</D><hm>16:23</hm></Data>` 序列，
/// 折算为 UTC 瞬间。
List<Map<String, String>> _parseHko(String xml, int year) {
  final re = RegExp(
    r'<Data>\s*<M>(\d{1,2})</M>\s*<D>(\d{1,2})</D>\s*<hm>(\d{1,2}):(\d{2})</hm>',
  );
  final out = <Map<String, String>>[];
  for (final m in re.allMatches(xml)) {
    final month = int.parse(m.group(1)!);
    final day = int.parse(m.group(2)!);
    final hour = int.parse(m.group(3)!);
    final minute = int.parse(m.group(4)!);
    final utc = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
    ).subtract(const Duration(hours: _hktOffsetHours));
    out.add({'term': termNames[out.length], 'instantUtc': _iso(utc)});
  }
  return out;
}

Map<String, Object?> _buildPack(int year, List<Map<String, String>> terms) => {
  'schemaVersion': 1,
  'calendarYear': year,
  'timeStandard': 'UTC',
  'revision': 1,
  'source': {
    'name': 'Hong Kong Observatory (HKO)',
    'reference': '$_hkoBase$year.xml',
    'generatedAt': _iso(DateTime.now().toUtc()),
    'note':
        'Astronomical data by HM Nautical Almanac Office (UK) and '
        'United States Naval Observatory. Original times in HKT (UTC+8), '
        'converted to UTC. Source precision: 1 minute.',
  },
  'terms': terms,
};

String _iso(DateTime utc) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-'
      '${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:'
      '${two(utc.second)}Z';
}
