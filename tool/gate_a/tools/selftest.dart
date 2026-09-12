/// Gate A 自检：验证旁证计算（四柱/六冲/六合/日柱）在已知锚点上正确。
///
/// 旁证本身若算错，会让人工对照得出错误结论，因此必须先自证。
///
/// 本文件只做**编排**（保持 `dart run tool/gate_a/tools/selftest.dart`
/// 这个历史入口不变），检查分组与断言器在 `selftest/` 下：
///
/// ```text
/// selftest/suite.dart             断言器 check() + 六爻工具 + 终判
/// selftest/checks_astro.dart      Meeus 尺子 · 官方双源 · 数据包忠实转写
/// selftest/checks_pillars.dart    日柱锚点 · 五虎遁 · 五鼠遁 · 年柱
/// selftest/checks_liuchong.dart   六冲 / 六合 判定与已知陷阱
/// selftest/checks_tables.dart     六冲全表 · 八宫表 · 八卦爻序
/// ```
///
/// ⚠️ 分组的**调用顺序**决定了打印顺序；`suite.dart` 的 `failures`
/// 是唯一计数器，任一分组失败都会让退出码非 0。
library;

import 'dart:io';

import 'selftest/checks_astro.dart';
import 'selftest/checks_liuchong.dart';
import 'selftest/checks_pillars.dart';
import 'selftest/checks_tables.dart';
import 'selftest/suite.dart';

Future<void> main() async {
  await checkAstro();
  checkPillars();
  checkLiuChong();
  checkTables();

  stdout.writeln('');
  exitCode = reportVerdict();
}
