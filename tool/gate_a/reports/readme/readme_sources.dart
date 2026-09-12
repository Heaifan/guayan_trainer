/// README 的「数据来源 / 文件说明 / Compat 怎么用」三段
/// （自 `reports/readme_header.dart` 拆出）。
///
/// 段首紧接上一段的结尾空行 —— 拼接顺序见 `readme_header.dart`，不得调换。
library;

import '../../cases/derive.dart';
import '../../gate_a_context.dart';

String sourcesSection(GateAContext ctx) =>
    '''## 数据来源

```text
数据包年份      ${ctx.installedYears.join(', ')}
节气来源        Hong Kong Observatory（HKO），分钟精度（秒位恒为 :00）
第二官方源      日本国立天文台 NAOJ「暦要項」（JST → HKT 减 1 小时）
双源交叉        2026 年 24 / 24 日期一致、分钟一致
秒级公开值      仅立春 2026（紫金山天文台科普部 04:02:08 +08:00）
时区基准        +08:00
卦眼日界        midnight 与 ziHourStart 均已实现并通过测试
                产品默认策略 OPEN（属产品配置决定，不阻塞 R3 Domain Foundation）
```

> 自建天文尺子（Meeus）状态：**REJECTED AS GATE ORACLE**，仅作 diagnostic。
> 详见 `03-solar-term-boundaries.md` 的「自建天文尺子的现状」一节。

## 文件说明

| 文件 | 内容 | 归属 |
| --- | --- | --- |
| `01-normal-cases.md` | GA-1 普通真实卦例 ${normalCases.length} 例（月建/日辰/旬空/卦体/纳甲/六亲/世应） | Truth + Compat |
| `02-classic-cases.md` | GA-2 经典卦体 ${classicCases.length} 例（乾为天/坤为地/泽山咸/归魂/游魂…） | Truth + Compat |
| `03-solar-term-boundaries.md` | GA-3 节气边界：2026 十二「节」官方测试点 + 立春秒级三点 | Truth（精度另外记） |
| `04-day-boundary.md` | GA-4 日界 ${dayBoundaryCases.length} 个日期 × 6 个时刻 × 2 种规则 | Truth + Compat |
| `05-master-table.md` | 总表：**Truth Result 与 Compatibility Result 分列** | 两者 |

## Gate A-Compat 怎么用（后续可选）

1. 打开专业排盘软件（建议 **2 个独立来源**）；
2. 按 `01`/`02`/`03`/`04` 中给出的时间与卦象输入；
3. 把结果填回或截图发回，并注明**软件名与版本**。

> 用户不需要自己设计测试案例 —— 测试设计责任在 Agent。
> 结果只用于记录**兼容性 / 配置差异**，不会改写 Gate A-Truth 的结论。

''';
