/// Gate A 生成器入口 —— **只负责编排**。
///
/// ```text
/// 装载历法上下文 → 结构自检 → 计算案例事实 → 生成文档 → 打印摘要
/// ```
/// 渲染逻辑在 `reports/`，落盘编排在 `commands/generate_reports.dart`，
/// 控制台输出在 `commands/digest.dart`。
///
/// 用法（仓库根目录）：
/// ```text
/// dart run tool/gate_a/gate_a_main.dart
/// # 或经本机包装：gate_a_runner.ps1 run tool/gate_a/gate_a_main.dart
/// ```
library;

import 'dart:io';

import 'cases/derive.dart';
import 'commands/digest.dart';
import 'commands/generate_reports.dart';
import 'core/audit/hexagram_audit.dart';
import 'gate_a_context.dart';

Future<void> main(List<String> args) async {
  final ctx = await loadGateAContext();
  stdout.writeln('Gate A · 已装载历年数据包：${ctx.installedYears.join(', ')}');

  final audit = verifyPalaceTable();
  stdout.writeln(
    audit.isEmpty
        ? '结构自检（八宫表完整性）：PASS — 64 组合一一对应，每宫 8 卦，世应相隔三位'
        : '结构自检（八宫表完整性）：FAIL\n  ${audit.join('\n  ')}',
  );

  final facts = computeAllCaseFacts(ctx);
  generateReports(ctx, facts);

  printDigest(
    facts.where((f) => f.def.group == 'GA-1').toList(),
    facts.where((f) => f.def.group == 'GA-2').toList(),
  );
  printLockCheck(facts);
  printCloseout(outDir);
}
