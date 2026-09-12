/// 自检断言器与六爻小工具（自 `tools/selftest.dart` 拆出）。
///
/// `failures` 是本进程内**唯一**的失败计数：所有检查分组共用它，
/// 最后由 `reportVerdict()` 汇总成退出码 —— 分组再多也只有一处结论。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/line_state.dart';

import '../../core/audit/hexagram_audit.dart';

/// 失败计数（跨分组共享，禁止各分组自建一份）。
int failures = 0;

/// 由动静类型取六爻阴阳（自初爻至上爻）。
List<bool> linesOf(dynamic chart) => <bool>[
  for (final l in chart.lines) l.isYang as bool,
];

/// 打印六爻纳甲与冲/合配对详情（定位判定失败时用）。
void dumpBranches(String label, dynamic chart) {
  final list = branchesOf(chart);
  final seen = <DiZhi>{};
  final log = <String>[];
  for (final z in list) {
    final repeated = !seen.add(z);
    if (repeated) log.add('${z.label}(重复)');
    if (seen.contains(z.chong)) log.add('${z.label}-${z.chong.label}冲');
    if (seen.contains(z.he)) log.add('${z.label}-${z.he.label}合');
  }
  stdout.writeln(
    '  $label 纳甲：${list.map((z) => z.label).join(' ')}  '
    '判定过程：${log.join(' ')}',
  );
}

/// 由 6 位阴阳串（自初爻至上爻，1 = 阳）构造全部为「少」的静卦输入。
///
/// 用位串而非手写枚举，是因为手写 6 个枚举值已多次把卦写错 ——
/// 位串与 `resolveHexagram` 的键完全同构，肉眼可直接核对。
List<MovementType> movesOf(String bits) => <MovementType>[
  for (final ch in bits.split(''))
    if (ch == '1') MovementType.shaoYang else MovementType.shaoYin,
];

void check(String label, Object? actual, Object? expected) {
  final ok = '$actual' == '$expected';
  if (!ok) failures++;
  stdout.writeln(
    '${ok ? 'PASS' : 'FAIL'}  $label  → 实际 $actual'
    '${ok ? '' : ' / 期望 $expected'}',
  );
}

/// 打印最终结论；返回进程退出码（0 = 全部 PASS）。
int reportVerdict() {
  stdout.writeln(failures == 0 ? '全部自检 PASS' : '自检 FAIL $failures 项');
  return failures == 0 ? 0 : 1;
}
