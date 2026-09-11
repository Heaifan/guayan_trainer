# 卦眼 2.0 · Gate A 专业排盘人工对照验收

> 本目录全部文件由 `tool/gate_a/gate_a_main.dart` 生成，**不含任何自动判定**。
> 「专业软件」列必须由人填写 —— 这是 Gate A 的唯一真值来源。

## 状态

```text
Gate A1 PROFESSIONAL SOFTWARE COMPATIBILITY
  WAITING FOR USER MANUAL INPUT

Gate A2 SOLAR TERM ABSOLUTE PRECISION
  UNRESOLVED — ASTRONOMICAL ORACLE NOT YET VALIDATED

GATE A
  NOT PASSED
```

## 数据来源

```text
数据包年份      2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028
节气来源        Hong Kong Observatory（HKO），分钟精度（秒位恒为 :00）
第二官方源      日本国立天文台 NAOJ「暦要項」（JST → HKT 减 1 小时）
双源交叉        2026 年 24 / 24 日期一致、分钟一致
秒级公开值      仅立春 2026（紫金山天文台科普部 04:02:08 +08:00）
时区基准        +08:00
卦眼日界（本表）midnight（00:00 换日）
```

> 自建天文尺子（Meeus）状态：**REJECTED AS GATE ORACLE**，仅作 diagnostic。
> 详见 `03-solar-term-boundaries.md` 的「自建天文尺子的现状」一节。

## 文件说明

| 文件 | 内容 |
| --- | --- |
| `01-normal-cases.md` | GA-1 普通真实卦例 13 例（月建/日辰/旬空/卦体/纳甲/六亲/世应） |
| `02-classic-cases.md` | GA-2 经典卦体 6 例（乾为天/坤为地/泽山咸/归魂/游魂…） |
| `03-solar-term-boundaries.md` | GA-3 节气边界：2026 十二「节」差异窗口全量测量 + 窗口最大的前 6 个详表 |
| `04-day-boundary.md` | GA-4 日界 3 个日期 × 6 个时刻 × 2 种规则 |
| `05-master-table.md` | Gate A 总表（回填后定稿） |

## 用户需要做的三件事

1. 打开专业排盘软件（建议 **2 个独立来源**）；
2. 按 `01`/`02`/`03`/`04` 中给出的时间与卦象输入；
3. 把结果填回或截图发回，并注明**软件名与版本**（不同软件流派不同）。

> 用户不需要自己设计测试案例 —— 测试设计责任在 Agent。

## 已有结果 vs 待人工判定

**Agent 已完成（可复核）**

```text
GA0 Git baseline 核验                      DONE
GA1 GA-1 测试矩阵（13 例）                    DONE
GA3 GA-2 测试矩阵（6 例）                     DONE
GA4 GA-3 测试矩阵（2026 十二「节」× 官方测试点）  DONE
GA6 GA-4 测试矩阵（3 日 × 6 点 × 2 规则） DONE
结构自检（八宫表 / 纳甲组装 / 案例锁定）    DONE
官方双源交叉（HKO vs NAOJ 24/24）           DONE
自建天文尺子验证（REJECTED AS ORACLE）      DONE
```

**待用户人工对照（Agent 不得代做）**

```text
GA2  GA-1 人工对照        BLOCKED — 等待专业软件结果
GA5  GA-3 人工对照        BLOCKED — 等待专业软件结果
GA7  GA-4 人工对照        BLOCKED — 等待专业软件结果
GA8  差异分类             BLOCKED — 需先有差异
GA9  必要时最小 FIX       BLOCKED
GA11 Gate A 总表定稿      BLOCKED
GA14 Final Gate Decision  BLOCKED
```

## 覆盖矩阵（程序统计）

```text
普通案例        13 例（要求 >= 10）
经典卦体        6 例（要求 >= 6）
节气边界        2026 十二「节」全量（要求 >= 3，推荐 5）；详表出窗口最大的 6 个
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

## 已知需要重点观察的三处

1. **GA-3 · 立春 2026**：唯一有秒级公开值的节气 ——
   `边界 −1min / 边界 / 边界 +1min / 秒级 exact −1s / exact / exact +1s` 六点，
   是 `Gate A1` 最关键的一组。
2. **GA-4 · 23:00—23:59**：日界流派分歧窗口，只判日辰与旬空。
3. **GA-2 · GA-C-06**：验证**变卦六亲仍取本卦之宫**（不得按变卦宫计算）。

## 关于 Gate A2

`Gate A2` 现为 **UNRESOLVED**：官方双源（HKO / NAOJ）已互相印证分钟级真值，
但**独立秒级天文真值尚未建立**，因此既不 PASS 也不 FAIL 数据源。
**不要据此升级 `CalendarDataPack`。**
