/// 规则实现的**自证夹具**：先用临时目录证明「计数器数的是直接文件」，再去数仓库
/// —— 否则一次改错就能让整轮治理拿到假 PASS。
///
/// 背景（POST-R3-GOV-01 · S0 独立核验）：旧规则 2 写成
/// `dir.listSync(recursive: true).whereType<File>().length`，于是 `cases/`
/// （1 直接文件 + 2 子目录）被报成「6 个文件」、`reports/`（7 直接文件）数字被
/// 写成 9、根目录漏掉全部 7 个子目录；而状态文件与提交 1541660 都写着
/// 「规则 2 PASS」。完整记录见 `memory/post-r3-gov-01-state.md`。
library;

import 'dart:io';

import 'dir_scan.dart';

/// 夹具目录预算（与 `gov_rules.dart` 的 `maxFilesPerDir` 一致）。
const int fixtureBudget = 5;

/// 运行自证夹具；返回问题清单（空 = 规则实现可信）。
///
/// 夹具只建在系统临时目录、用完即删，**不触碰仓库内任何文件**。
List<String> ruleImplementationProblems() {
  final tmp = Directory.systemTemp.createTempSync('gov_rules_regression');
  try {
    final root = _seed(tmp);
    return <String>[
      ..._directIsNotRecursive(root),
      ..._budgetVerdicts(tmp, root),
      ..._walksWholeTree(root),
    ];
  } finally {
    tmp.deleteSync(recursive: true);
  }
}

/// 夹具树（`root` 对应真实仓库的 `tool/gate_a`）：
///
/// root/          3 文件 + 3 子目录
/// root/wide/     4 文件（另有 nested/ 20 文件）→ 直接 4 / 后代 24，不得判超限
/// root/crowded/  6 文件                        → 必须判超限
/// root/roomy/    5 文件 + 4 子目录             → 文件未超；子目录不占父预算
Directory _seed(Directory tmp) {
  final root = Directory('${tmp.path}/root');
  _files('${root.path}/wide', 4);
  _files('${root.path}/wide/nested', 20);
  _files('${root.path}/crowded', 6);
  _files('${root.path}/roomy', 5);
  for (var i = 0; i < 4; i++) {
    Directory('${root.path}/roomy/sub$i').createSync(recursive: true);
  }
  _files(root.path, 3);
  return root;
}

/// 造 [count] 个空文件。
void _files(String path, int count) {
  Directory(path).createSync(recursive: true);
  for (var i = 0; i < count; i++) {
    File('$path/f$i.dart').writeAsStringSync('// fixture\n');
  }
}

/// 「直接 ≠ 后代」：这是整套夹具的立足点。
List<String> _directIsNotRecursive(Directory root) {
  final wide = Directory('${root.path}/wide');
  final direct = directFileCount(wide);
  // 旧实现的口径，只作反例对照。
  final nested = wide.listSync(recursive: true).whereType<File>().length;
  return <String>[
    if (direct != 4) 'wide 直接文件应为 4，实际 $direct（后代 $nested）',
    if (direct == nested) '夹具失效：wide 直接数与后代数相同，无法分辨两种口径',
    if (directFileCount(root) != 3) 'root 直接文件应为 3，实际 ${directFileCount(root)}',
    if (directSubdirCount(root) != 3)
      'root 直接子目录应为 3，实际 ${directSubdirCount(root)}',
  ];
}

List<String> _budgetVerdicts(Directory tmp, Directory root) {
  final over = overBudgetDirs(
    root,
    tmp,
    fixtureBudget,
  ).map((line) => line.split('  ').first).toSet();
  const mustFlag = <String>['root/crowded', 'root/wide/nested'];
  const mustNotFlag = <String>['root/wide', 'root/roomy'];
  return <String>[
    for (final d in mustFlag)
      if (!over.contains(d)) '漏报：$d 直接文件超预算却未列出（实际 $over）',
    for (final d in mustNotFlag)
      if (over.contains(d)) '误报：$d 直接文件未超预算却被列出（实际 $over）',
    if (over.length != mustFlag.length)
      '夹具应恰好报出 ${mustFlag.length} 个超限目录，实际 ${over.length}：$over',
  ];
}

/// 必须走到**每一级**目录：旧的根目录特判只数根下的文件，漏掉所有子目录。
List<String> _walksWholeTree(Directory root) {
  final dirs = scanDirs(root).map((d) => dirLabel(root, d.path)).toList();
  if (dirs.length == 9) return const <String>[];
  return <String>['目录枚举应为 9 个（根 + 全部后代），实际 ${dirs.length}：$dirs'];
}
