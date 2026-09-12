/// 生成 6 份 Gate A 文档（编排：调用各渲染模块并落盘）。
///
/// 只负责「谁写到哪个文件」，不承载渲染逻辑 ——
/// 渲染实现分别在 `reports/` 各模块，便于单独阅读与复核。
library;

import 'dart:convert';
import 'dart:io';

import '../cases/derive.dart';
import '../gate_a_context.dart';
import '../reports/cases/case_report.dart';
import '../reports/cases/master_table.dart';
import '../reports/day_report.dart';
import '../reports/readme/readme_header.dart';
import '../reports/readme/readme_instructions.dart';
import '../reports/solar_term/boundary_section.dart';

/// 输出目录（仓库根目录下的 `gate-a/`）。
const String outDir = 'gate-a';

/// 生成全部文档；返回写出的文件数。
int generateReports(GateAContext ctx, List<CaseFacts> facts) {
  final normal = facts.where((f) => f.def.group == 'GA-1').toList();
  final classic = facts.where((f) => f.def.group == 'GA-2').toList();
  Directory(outDir).createSync(recursive: true);

  write(outDir, 'README.md', renderReadmeHeader(ctx, facts));
  write(
    outDir,
    '01-normal-cases.md',
    _doc('GA-1 普通真实卦例（${normal.length} 例）', renderCaseFacts(normal)),
  );
  write(
    outDir,
    '02-classic-cases.md',
    _doc('GA-2 经典卦体专项（${classic.length} 例）', renderCaseFacts(classic)),
  );
  write(
    outDir,
    '03-solar-term-boundaries.md',
    _doc('GA-3 节气边界专项（2026 年十二「节」官方测试点 + 立春秒级三点）', renderSolarTermSection(ctx)),
  );
  write(
    outDir,
    '04-day-boundary.md',
    _doc(
      'GA-4 日界专项（${dayBoundaryCases.length} 个日期）',
      dayBoundaryCases.map((c) => renderDayBoundaryCase(ctx, c)).join(),
    ),
  );
  write(
    outDir,
    '05-master-table.md',
    _doc(
      'Gate A 总表（Truth Result 与 Compatibility Result 分列）',
      renderMasterTable(facts),
      withInstructions: false,
    ),
  );
  return 6;
}

/// 单份文档 = 标题 + 使用说明 + 正文。
///
/// 总表自带列说明，故不加「使用方式」段（与历史产物保持一致）。
String _doc(String title, String body, {bool withInstructions = true}) =>
    '# $title\n\n${withInstructions ? '${renderInstructions()}\n' : ''}$body';

/// 写文件（UTF-8，无 BOM）。
void write(String dir, String name, String content) {
  File('$dir/$name').writeAsStringSync(content, encoding: utf8);
}
