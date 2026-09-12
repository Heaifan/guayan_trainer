/// 卦例「六爻明细表」与结尾脚注：阴阳动静 / 六神 / 纳甲 / 五行 / 六亲 / 变爻。
///
/// 表头较长，按初爻→上爻逐行输出；脚注包含结构自检异常提示与
/// 「变卦六亲仍以本卦之宫为我」的口径声明（后者是易错点，必须写在表下）。
library;

import '../../cases/derive.dart';

/// 六爻明细表 + 脚注（末尾带一个空行，与历史产物保持一致）。
String caseLineTable(CaseFacts f) {
  final cal = f.calendar;
  final chart = f.chart;
  final b = StringBuffer();
  b.writeln(
    '| 爻位 | 阴阳动静 | 六神 | 卦眼纳甲 | 软件纳甲 | 卦眼五行 '
    '| 软件五行 | 卦眼六亲 | 软件六亲 | 变爻纳甲 | 变爻六亲 | 世应 '
    '| 结果 |',
  );
  b.writeln(
    '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- '
    '| --- | --- | --- |',
  );
  for (var i = 0; i < 6; i++) {
    final l = chart.lines[i];
    final kong = cal.xunKong.contains(l.branch) ? '（空）' : '';
    b.writeln(
      '| ${_posName(i + 1)} '
      '| ${l.isYang ? '阳' : '阴'}${l.isMoving ? '·动' : '·静'} '
      '| ${l.spirit?.label ?? '—'} '
      '| ${l.ganZhi}$kong | | ${l.branch.wuXing.label} | '
      '| ${l.relative.label} | | ${l.changedGanZhi ?? '—'} '
      '| ${l.changedRelative?.label ?? '—'} '
      '| ${l.shiYingLabel.isEmpty ? '—' : l.shiYingLabel} | |',
    );
  }
  b.writeln();
  if (f.auditProblems.isNotEmpty) {
    b.writeln('> ⚠️ 结构自检异常：${f.auditProblems.join('；')}');
    b.writeln();
  }
  b.writeln(
    '> **变卦六亲口径**：仍以**本卦之宫**（${f.original.palace.label}·'
    '${f.original.palace.wuXing.label}）为「我」，不按变卦之宫计算。',
  );
  b.writeln();
  return b.toString();
}

const List<String> _posNames = <String>['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];

String _posName(int i) => _posNames[i - 1];
