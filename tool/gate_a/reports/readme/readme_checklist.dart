/// README 的「已有结果 / 覆盖矩阵 / 立春焦点 / 精度原则」四段
/// （自 `reports/readme_header.dart` 拆出）。
///
/// 段首紧接上一段的结尾空行 —— 拼接顺序见 `readme_header.dart`，不得调换。
library;

import '../../cases/derive.dart';
import '../cases/master_table.dart';
import '../status/gate_status.dart';

String checklistSection(List<CaseFacts> facts) =>
    '''## 已有结果 vs 尚未执行

**Gate A-Truth（已由自动核验完成，可复核）**

```text
GA0 Git baseline 核验                      DONE
GA1 GA-1 测试矩阵（${normalCases.length} 例）                    DONE
GA3 GA-2 测试矩阵（${classicCases.length} 例）                     DONE
GA4 GA-3 测试矩阵（2026 十二「节」× 官方测试点）  DONE
GA6 GA-4 测试矩阵（${dayBoundaryCases.length} 日 × 6 点 × 2 规则） DONE
结构自检（八宫表 / 纳甲组装 / 案例锁定）    DONE
官方双源交叉（HKO vs NAOJ 24/24）           DONE
秒级边界 Golden Test（立春 04:02:08）       DONE
自建天文尺子验证（REJECTED AS ORACLE）      DONE
```

**Gate A-Compat（尚未执行，不阻塞 R3）**

```text
专业软件人工对照          $compatStatus
差异分类（兼容性）        NOT EXECUTED — 需先有对照结果
```

## 覆盖矩阵（程序统计）

```text
普通案例        ${facts.where((f) => f.def.group == 'GA-1').length} 例（要求 >= 10）
经典卦体        ${facts.where((f) => f.def.group == 'GA-2').length} 例（要求 >= 6）
节气边界        2026 十二「节」全量（要求 >= 3，推荐 5）；各 3 点，立春另 3 点（秒级）
日界专项        ${dayBoundaryCases.length} 日 × ${dayBoundaryClockPoints.length} 时间点 × 2 规则
有变 / 无变     ${facts.where((f) => f.changed != null).length} / ${facts.where((f) => f.changed == null).length}
单变 / 多变     ${facts.where((f) => f.chart.movingPositions.length == 1).length} / ${facts.where((f) => f.chart.movingPositions.length > 1).length}
六冲卦例        ${caseNames(facts, (f) => f.isLiuChong)}
六合卦例        ${caseNames(facts, (f) => f.isLiuHe)}
变卦为六合      ${caseNames(facts, (f) => f.isChangedLiuHe)}
游魂卦例        ${caseNames(facts, (f) => f.original.rank.label == '游魂')}
归魂卦例        ${caseNames(facts, (f) => f.original.rank.label == '归魂')}
```

> 六十四卦中其余六冲卦（坎为水 / 艮为山 / 巽为风 / 离为火 / 兑为泽 /
> 雷天大壮 / 天雷无妄）**未**强行造例凑覆盖率 —— 需求明确禁止为覆盖率伪造案例。

## 立春 2026 是本轮精度焦点

```text
2026 LiChun = 04:02:08 +08:00（秒级，已纳入数据包）
已知 precision gap：FIXED
其余 2026 节气：MINUTE-LEVEL VERIFIED（via HKO + NAOJ）
               No fabricated second-level values
状态：PARTIALLY SECOND-LEVEL VERIFIED
```

> 不要写 `UNRESOLVED`（该点已有秒级真值）；
> 也**禁止**写 `ALL SOLAR TERMS SECOND-LEVEL VERIFIED`（那是假的）。

## 数据包精度原则（长期保留）

```text
数据包可以混合精度，但每条数据必须说清：
  - 是分钟级还是秒级（precision）
  - 来自哪里（年度 source / 逐节气 sourceOverride）

:00 秒 ≠ 「恰在第 0 秒交节」，只表示「该分钟内交节」。
以后逐年补更高精度节气时，只需替换对应 term，
不必推翻现有年度包。
```
''';
