# 卦眼 2.0 · Gate A 收口（真值 Gate + 兼容性 Gate）

> 本目录全部文件由 `tool/gate_a/gate_a_main.dart` 生成。
> **核心真值不来自专业软件**：由独立规则核验、官方历法双源与边界 Golden Test 承担。
> 专业软件对照是**独立观察项**，见 `Gate A-Compat`。

## 状态

```text
R3-A
PASS

R3-B
PASS

R3-B-DATA-PRECISION-FIX
PASS

GATE A-TRUTH
PASS

GATE A-COMPAT
NOT EXECUTED / DEFERRED
NON-BLOCKING

R3
FINAL ACCEPTED

```

### Gate A-Truth 逐项

| 验收域 | 结果 | 证据 |
| --- | --- | --- |
| 八宫 | **PASS** | 八宫表 64 组合一一对应、每宫 8 卦（gate_a_selftest 结构自检） |
| 世应 | **PASS** | 世应相隔三位；八宫卦序推导复核（gate_a_hexagram_audit） |
| 纳甲 | **PASS** | 六爻支 = 下卦内三支 + 上卦外三支；组装顺序逐例复核（案例锁定） |
| 五行 | **PASS** | 地支五行取自 DiZhi 唯一表；六亲判定唯一入口 WuXing.relationTo |
| 六亲 | **PASS** | 以宫位五行为「我」；九类宫位五行覆盖（经典卦体专项） |
| 变卦六亲取本卦宫 | **PASS** | CastingEngine 显式以本卦之宫为「我」；GA-C-06 专验 |
| 六神 | **PASS** | 按日干起例；甲乙青龙…壬癸玄武 分支自检（含日干边界） |
| 日辰 | **PASS** | JDN 锚点 1949-10-01=甲子（外部黄历源核）+ 2026-02-04=己酉（跨 76 年独立源核） |
| 旬空 | **PASS** | 由旬首推导；六旬空亡逐旬断言（xun_kong_test） |
| 月建 | **PASS** | 十二「节」区间判断；边界语义 instant>=交节 三态断言 |
| 节气数据 | **PASS** | HKO vs NAOJ 2026 年 24/24 日期一致、分钟一致（官方双源） |
| 节气秒级精度 | **PARTIALLY VERIFIED** | 2026 立春秒级已核实并纳入数据包；其余节气 minute-level only（无伪造秒值） |
| 时区换算 | **PASS** | localDateTime + utcOffset → instantUtc；同一挂钟时间不同偏移可跨节 |
| 日界双规则 | **PASS** | midnight 与 ziHourStart 均实现并通过边界测试（day_boundary_test） |
| 离线计算 | **PASS** | 零运行时网络；未导入年份明确拒绝（offline_gate_test） |

```text
Gate A-Truth  = R3 的 blocker（当前 PASS）
Gate A-Compat = NOT EXECUTED，NON-BLOCKING
```

> Gate A-Compat 未执行的理由：尚未对指定目标专业排盘软件逐项进行人工输入比对。不同软件可能采用不同日界（23:00 / 00:00）、晚子时 / 早子时与其他流派配置；这些差异应记录为兼容性 / 配置差异，不能自动视为核心算法错误，故不作为 R3 阻塞项。

## 数据来源

```text
数据包年份      2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028
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
| `01-normal-cases.md` | GA-1 普通真实卦例 13 例（月建/日辰/旬空/卦体/纳甲/六亲/世应） | Truth + Compat |
| `02-classic-cases.md` | GA-2 经典卦体 6 例（乾为天/坤为地/泽山咸/归魂/游魂…） | Truth + Compat |
| `03-solar-term-boundaries.md` | GA-3 节气边界：2026 十二「节」官方测试点 + 立春秒级三点 | Truth（精度另外记） |
| `04-day-boundary.md` | GA-4 日界 3 个日期 × 6 个时刻 × 2 种规则 | Truth + Compat |
| `05-master-table.md` | 总表：**Truth Result 与 Compatibility Result 分列** | 两者 |

## Gate A-Compat 怎么用（后续可选）

1. 打开专业排盘软件（建议 **2 个独立来源**）；
2. 按 `01`/`02`/`03`/`04` 中给出的时间与卦象输入；
3. 把结果填回或截图发回，并注明**软件名与版本**。

> 用户不需要自己设计测试案例 —— 测试设计责任在 Agent。
> 结果只用于记录**兼容性 / 配置差异**，不会改写 Gate A-Truth 的结论。

## 已有结果 vs 尚未执行

**Gate A-Truth（已由自动核验完成，可复核）**

```text
GA0 Git baseline 核验                      DONE
GA1 GA-1 测试矩阵（13 例）                    DONE
GA3 GA-2 测试矩阵（6 例）                     DONE
GA4 GA-3 测试矩阵（2026 十二「节」× 官方测试点）  DONE
GA6 GA-4 测试矩阵（3 日 × 6 点 × 2 规则） DONE
结构自检（八宫表 / 纳甲组装 / 案例锁定）    DONE
官方双源交叉（HKO vs NAOJ 24/24）           DONE
秒级边界 Golden Test（立春 04:02:08）       DONE
自建天文尺子验证（REJECTED AS ORACLE）      DONE
```

**Gate A-Compat（尚未执行，不阻塞 R3）**

```text
专业软件人工对照          NOT EXECUTED
差异分类（兼容性）        NOT EXECUTED — 需先有对照结果
```

## 覆盖矩阵（程序统计）

```text
普通案例        13 例（要求 >= 10）
经典卦体        6 例（要求 >= 6）
节气边界        2026 十二「节」全量（要求 >= 3，推荐 5）；各 3 点，立春另 3 点（秒级）
日界专项        3 日 × 6 时间点 × 2 规则
有变 / 无变     11 / 8
单变 / 多变     9 / 2
六冲卦例        GA-01:乾为天、GA-02:坤为地、GA-05:震为雷、GA-06:坤为地、GA-08:震为雷、GA-C-01:乾为天、GA-C-02:坤为地
六合卦例        GA-03:地雷复、GA-11:地雷复、GA-13:地雷复
变卦为六合      GA-05:震为雷、GA-08:震为雷、GA-09:泽地萃、GA-10:地火明夷、GA-13:地雷复
游魂卦例        GA-10:地火明夷、GA-12:山雷颐、GA-C-05:山雷颐
归魂卦例        GA-04:地水师、GA-07:地水师、GA-C-04:火天大有、GA-C-06:地水师
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
