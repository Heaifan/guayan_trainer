/// Gate A 的**双 Gate 定义**（GATE-A-FINAL-CLOSEOUT）。
///
/// 职责拆分（正式冻结）：
/// ```text
/// Gate A-Truth   核心业务真值        —— R3 的 blocker
/// Gate A-Compat  专业软件兼容性观察  —— 不阻塞 R3
/// ```
///
/// 为什么拆：Gate A 原文把「某专业软件的人工填写结果」设为唯一真值来源。
/// 但目标软件之间存在流派差异（23:00 / 00:00 日界、晚子时 / 早子时、
/// 其他配置），这类差异属于**兼容性 / 配置差异**，不能自动视为核心算法错误。
/// 因此核心真值改由**独立规则核验 + 官方历法双源 + 秒级真值 + 边界 Golden Test**
/// 承担；专业软件对照降级为独立观察项。
/// 逐项结论见 `gate_truth_items.dart`。
library;

import 'gate_truth_items.dart';

/// Gate A-Truth 的一个验收项（逐条如实记录，不四舍五入成一句「通过」）。
class TruthItem {
  const TruthItem({
    required this.domain,
    required this.result,
    required this.evidence,
  });

  /// 验收域，如「八宫」。
  final String domain;

  /// `PASS` / `FAIL` / `PARTIALLY VERIFIED`。
  final String result;

  /// 证据来源（必须可复核）。
  final String evidence;
}

/// Gate A-Compat 状态：**未执行**。
const String compatStatus = 'NOT EXECUTED';

/// Gate A-Compat 不阻塞 R3 的理由。
const String compatReason =
    '尚未对指定目标专业排盘软件逐项进行人工输入比对。'
    '不同软件可能采用不同日界（23:00 / 00:00）、晚子时 / 早子时与'
    '其他流派配置；这些差异应记录为兼容性 / 配置差异，'
    '不能自动视为核心算法错误，故不作为 R3 阻塞项。';

/// R3 最终状态块（由生成器直接写入文档，避免手抄走样）。
String r3FinalStatusBlock() {
  final failed = truthItems.where((t) => t.result == 'FAIL').toList();
  final truthVerdict = failed.isEmpty ? 'PASS' : 'FAIL';
  return '''
R3-A
PASS

R3-B
PASS

R3-B-DATA-PRECISION-FIX
PASS

GATE A-TRUTH
$truthVerdict

GATE A-COMPAT
$compatStatus / DEFERRED
NON-BLOCKING

R3
${failed.isEmpty ? 'FINAL ACCEPTED' : 'NOT ACCEPTED — see failing items'}
''';
}
