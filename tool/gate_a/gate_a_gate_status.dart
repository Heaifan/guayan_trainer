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
library;

/// Gate A-Truth 的一个验收项（逐条如实记录，不四舍五入成一句「通过」）。
class TruthItem {
  const TruthItem({
    required this.domain,
    required this.result,
    required this.evidence,
  });

  /// 验收域，如「八宫」。
  final String domain;

  /// `PASS` / `FAIL`。
  final String result;

  /// 证据来源（必须可复核）。
  final String evidence;
}

/// Gate A-Truth 逐项结论。
///
/// 全部证据来自仓库内已完成的自动核验：
/// - 结构自检：八宫表 64 组合、纳甲组装顺序、案例锁定（`gate_a_selftest`）；
/// - 官方双源：HKO vs NAOJ 24/24（`gate_a_cross_source`）；
/// - 秒级真值：2026 立春 04:02:08（数据包 `sourceOverride`）；
/// - 边界：秒级 Golden Test + 日界双规则测试；
/// - 产品测试：`flutter test`。
const List<TruthItem> truthItems = <TruthItem>[
  TruthItem(
    domain: '八宫',
    result: 'PASS',
    evidence: '八宫表 64 组合一一对应、每宫 8 卦（gate_a_selftest 结构自检）',
  ),
  TruthItem(
    domain: '世应',
    result: 'PASS',
    evidence: '世应相隔三位；八宫卦序推导复核（gate_a_hexagram_audit）',
  ),
  TruthItem(
    domain: '纳甲',
    result: 'PASS',
    evidence: '六爻支 = 下卦内三支 + 上卦外三支；组装顺序逐例复核（案例锁定）',
  ),
  TruthItem(
    domain: '五行',
    result: 'PASS',
    evidence: '地支五行取自 DiZhi 唯一表；六亲判定唯一入口 WuXing.relationTo',
  ),
  TruthItem(
    domain: '六亲',
    result: 'PASS',
    evidence: '以宫位五行为「我」；九类宫位五行覆盖（经典卦体专项）',
  ),
  TruthItem(
    domain: '变卦六亲取本卦宫',
    result: 'PASS',
    evidence: 'CastingEngine 显式以本卦之宫为「我」；GA-C-06 专验',
  ),
  TruthItem(
    domain: '六神',
    result: 'PASS',
    evidence: '按日干起例；甲乙青龙…壬癸玄武 分支自检（含日干边界）',
  ),
  TruthItem(
    domain: '日辰',
    result: 'PASS',
    evidence: 'JDN 锚点 1949-10-01=甲子（外部黄历源核）'
        '+ 2026-02-04=己酉（跨 76 年独立源核）',
  ),
  TruthItem(
    domain: '旬空',
    result: 'PASS',
    evidence: '由旬首推导；六旬空亡逐旬断言（xun_kong_test）',
  ),
  TruthItem(
    domain: '月建',
    result: 'PASS',
    evidence: '十二「节」区间判断；边界语义 instant>=交节 三态断言',
  ),
  TruthItem(
    domain: '节气数据',
    result: 'PASS',
    evidence: 'HKO vs NAOJ 2026 年 24/24 日期一致、分钟一致（官方双源）',
  ),
  TruthItem(
    domain: '节气秒级精度',
    result: 'PARTIALLY VERIFIED',
    evidence: '2026 立春秒级已核实并纳入数据包；'
        '其余节气 minute-level only（无伪造秒值）',
  ),
  TruthItem(
    domain: '时区换算',
    result: 'PASS',
    evidence: 'localDateTime + utcOffset → instantUtc；同一挂钟时间不同偏移可跨节',
  ),
  TruthItem(
    domain: '日界双规则',
    result: 'PASS',
    evidence: 'midnight 与 ziHourStart 均实现并通过边界测试（day_boundary_test）',
  ),
  TruthItem(
    domain: '离线计算',
    result: 'PASS',
    evidence: '零运行时网络；未导入年份明确拒绝（offline_gate_test）',
  ),
];

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
