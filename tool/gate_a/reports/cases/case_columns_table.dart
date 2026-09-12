/// 卦例「项目对照表」：月建 / 日辰 / 旬空 / 卦体 / 世应 / 四柱旁证。
///
/// 这是用户拿去和专业软件逐项对照的表；每行末尾留「专业软件 / 一致」两列。
/// 六爻明细（纳甲、六亲、变爻）见 `case_line_table.dart`。
library;

import '../../cases/derive.dart';
import '../../core/pillars/case_pillars.dart';

/// 项目对照表（末尾带一个空行，与历史产物保持一致）。
String caseColumnsTable(CaseFacts f) {
  final cal = f.calendar;
  final b = StringBuffer();
  b.writeln('| 项目 | 卦眼 | 专业软件 | 一致 |');
  b.writeln('| --- | --- | --- | --- |');
  b.writeln('| 月建 | ${cal.monthBranchLabel} | | |');
  b.writeln('| 日辰 | ${cal.dayGanZhi} | | |');
  b.writeln('| 旬空 | ${cal.xunKongLabel}（旬首 ${cal.xunKong.xunHeadLabel}） | | |');
  b.writeln('| 本卦 | ${f.original.name} | | |');
  b.writeln('| 变卦 | ${f.changed?.name ?? '（静卦·无变卦）'} | | |');
  b.writeln(
    '| 卦宫 | ${f.original.palace.label}宫·'
    '${f.original.palace.wuXing.label} | | |',
  );
  b.writeln('| 八宫位次 | ${f.original.rank.label} | | |');
  b.writeln('| 世爻 | ${_shiYing(f, f.original.shiPosition)} | | |');
  b.writeln('| 应爻 | ${_shiYing(f, f.original.yingPosition)} | | |');
  b.writeln('| 卦体特征 | ${f.bodyLabelText} | | |');
  b.writeln('| 年柱（旁证） | ${f.yearPillarText} | | |');
  b.writeln('| 月柱（旁证） | ${f.monthPillarText} | | |');
  b.writeln('| 时柱（旁证） | ${f.hourPillarText} | | |');
  if (f.isLateZiHour) {
    b.writeln(
      '| 时柱（晚子时口径） | ${f.hourPillarNextDayText}'
      '（按次日日干起例） | | |',
    );
  }
  b.writeln(
    '| 八字（旁证） | ${f.yearPillarText}年 ${f.monthPillarText}月 '
    '${f.calendar.dayGanZhi}日 ${f.hourPillarText}时 | | |',
  );
  b.writeln();
  return b.toString();
}

String _shiYing(CaseFacts f, int pos) {
  final l = f.chart.lineAt(pos);
  return '$pos 爻（${l.ganZhi}·${l.relative.label}）';
}
