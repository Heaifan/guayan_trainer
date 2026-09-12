/// 卦例（GA-1 / GA-2）对照表渲染：卦眼结果 + 专业软件填写位。
///
/// 输出是**人工验收表单**，不是自动断言：每一行都留出「专业软件」列，
/// 由用户填入外部软件结果后回传。
library;

import '../cases/derive.dart';
import '../core/format.dart';
import '../core/pillars.dart';
import '../core/time_input.dart';
import '../gate_a_context.dart';

/// 顺序渲染一组卦例。
String renderCaseFacts(List<CaseFacts> facts) {
  final out = StringBuffer();
  for (final f in facts) {
    out.write(renderOneCase(f));
  }
  return out.toString();
}

/// 渲染单个卦例。
String renderOneCase(CaseFacts f) {
  final cal = f.calendar;
  final chart = f.chart;
  final local = parseWallClock(f.def.localTime);
  final b = StringBuffer();

  b.writeln('### ${f.def.id} · ${f.def.purpose}');
  b.writeln();
  b.writeln('```text');
  b.writeln('起卦时间    ${wallClockWithOffsetText(local)}');
  b.writeln('UTC 瞬间    ${cal.instantUtc.toIso8601String()}');
  b.writeln('日界规则    midnight（00:00 换日）');
  b.writeln(
    '六爻输入    ${f.def.inputText}'
    '   （7=少阳 8=少阴 9=老阳 6=老阴；自初爻至上爻）',
  );
  b.writeln('```');
  b.writeln();

  b.writeln('| 项目 | 卦眼 | 专业软件 | 一致 |');
  b.writeln('| --- | --- | --- | --- |');
  b.writeln('| 月建 | ${cal.monthBranchLabel} | | |');
  b.writeln('| 日辰 | ${cal.dayGanZhi} | | |');
  b.writeln(
    '| 旬空 | ${cal.xunKongLabel}（旬首 ${cal.xunKong.xunHeadLabel}） | | |',
  );
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
  b.writeln('| 八字（旁证） | ${f.yearPillarText}年 ${f.monthPillarText}月 '
      '${f.calendar.dayGanZhi}日 ${f.hourPillarText}时 | | |');
  b.writeln();

  b.writeln('| 爻位 | 阴阳动静 | 六神 | 卦眼纳甲 | 软件纳甲 | 卦眼五行 '
      '| 软件五行 | 卦眼六亲 | 软件六亲 | 变爻纳甲 | 变爻六亲 | 世应 '
      '| 结果 |');
  b.writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- '
      '| --- | --- | --- |');
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

String _shiYing(CaseFacts f, int pos) {
  final l = f.chart.lineAt(pos);
  return '$pos 爻（${l.ganZhi}·${l.relative.label}）';
}

const List<String> _posNames = <String>['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];

String _posName(int i) => _posNames[i - 1];
