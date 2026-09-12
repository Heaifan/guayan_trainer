/// 节气测试点的构造（自 `solar_term_report.dart` 拆出）。
///
/// 测试点**只由官方发布值派生**：
/// - 分钟级边界 → `边界 −1min / 边界 / 边界 +1min`；
/// - 另有可追溯秒级公开值 → 追加 `exact −1s / exact / exact +1s`。
///
/// 任何由自建天文尺推出的「差异窗口」都**不得**作为测试点
/// （该尺子已判为 REJECTED AS GATE ORACLE）。
library;

import 'term_reference.dart';

/// 一个测试点：标签 / 时刻（+08:00 挂钟）/ 说明。
typedef TermProbe = (String, DateTime, String);

/// 由官方参照构造测试点矩阵。
List<TermProbe> termProbes(OfficialTermReference r) {
  final probes = <TermProbe>[
    (
      '边界 −1min',
      r.packHkt.subtract(const Duration(minutes: 1)),
      '官方边界前 1 分钟 → 应给${r.oldMonth.label}月',
    ),
    ('边界', r.packHkt, '官方边界 → 应给${r.newMonth.label}月'),
    (
      '边界 +1min',
      r.packHkt.add(const Duration(minutes: 1)),
      '官方边界后 1 分钟 → 应给${r.newMonth.label}月',
    ),
  ];
  final exact = r.secondLevel?.hkt;
  if (exact != null) {
    probes.addAll(<TermProbe>[
      (
        '秒级 exact −1s',
        exact.subtract(const Duration(seconds: 1)),
        '秒级真值前 1 秒 → 应给${r.oldMonth.label}月',
      ),
      ('秒级 exact', exact, '秒级真值 → 应给${r.newMonth.label}月'),
      (
        '秒级 exact +1s',
        exact.add(const Duration(seconds: 1)),
        '秒级真值后 1 秒 → 应给${r.newMonth.label}月',
      ),
    ]);
  }
  return probes;
}
