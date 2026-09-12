/// Gate A-Truth 逐项验收结论（证据必须可复核）。
library;

import 'gate_status.dart';

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

