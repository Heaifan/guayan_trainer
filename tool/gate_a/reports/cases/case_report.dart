/// 卦例（GA-1 / GA-2）对照表渲染：卦眼结果 + 专业软件填写位。
///
/// 输出是**人工验收表单**，不是自动断言：每一行都留出「专业软件」列，
/// 由用户填入外部软件结果后回传。
///
/// 三段拼装（各自成文件，便于单独复核）：
/// 案例头（本文件）→ 项目对照表（`case_columns_table.dart`）
/// → 六爻明细表与脚注（`case_line_table.dart`）。
library;

import '../../cases/derive.dart';
import '../../core/formatting/format.dart';
import '../../core/time/time_input.dart';
import 'case_columns_table.dart';
import 'case_line_table.dart';

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
  final b = StringBuffer()
    ..write(_caseHeadBlock(f))
    ..write(caseColumnsTable(f))
    ..write(caseLineTable(f));
  return b.toString();
}

/// 案例头：标题 + 起卦时间 / UTC 瞬间 / 日界规则 / 六爻输入。
String _caseHeadBlock(CaseFacts f) {
  final local = parseWallClock(f.def.localTime);
  final b = StringBuffer();
  b.writeln('### ${f.def.id} · ${f.def.purpose}');
  b.writeln();
  b.writeln('```text');
  b.writeln('起卦时间    ${wallClockWithOffsetText(local)}');
  b.writeln('UTC 瞬间    ${f.calendar.instantUtc.toIso8601String()}');
  b.writeln('日界规则    midnight（00:00 换日）');
  b.writeln(
    '六爻输入    ${f.def.inputText}'
    '   （7=少阳 8=少阴 9=老阳 6=老阴；自初爻至上爻）',
  );
  b.writeln('```');
  b.writeln();
  return b.toString();
}
