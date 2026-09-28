import 'dart:io';

void main() {
  final file = File('docs/governance/version-events.tsv');
  if (!file.existsSync()) {
    stderr.writeln('BLOCKED: version-events.tsv missing');
    exitCode = 2;
    return;
  }
  final rows = file
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty && !line.startsWith('#'))
      .skip(1)
      .map((line) => line.split('\t'))
      .where((row) => row.length >= 9)
      .toList();
  final counts = <String, int>{};
  final domains = <String, Map<String, int>>{};
  var chain = 0, longest = 0;
  for (final row in rows) {
    final type = row[4];
    final domain = row[5];
    counts[type] = (counts[type] ?? 0) + 1;
    final bucket = domains.putIfAbsent(domain, () => <String, int>{});
    bucket[type] = (bucket[type] ?? 0) + 1;
    chain = type == 'FIX' ? chain + 1 : 0;
    if (chain > longest) longest = chain;
  }
  final feature = counts['FEATURE'] ?? 0;
  final fix = counts['FIX'] ?? 0;
  final ratio = feature == 0 ? 'N/A' : (fix / feature).toStringAsFixed(2);
  print('Feature Count: $feature');
  print('Fix Count: $fix');
  print('Perf Count: ${counts['PERF'] ?? 0}');
  print('Fix / Feature: $ratio');
  print('Longest Fix Chain: $longest');
  for (final entry in domains.entries) {
    print('${entry.key}: F=${entry.value['FEATURE'] ?? 0} '
        'X=${entry.value['FIX'] ?? 0}');
  }
}
