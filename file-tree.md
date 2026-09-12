# 项目文件树 — 卦眼训练器

> **当前版本：** v0.1.10
> **创建时间：** 2026-05-15
> **最后编辑：** 2026-09-12 01:30

> 本文件用于记录项目目录结构、模块职责与版本演进。  
> 每次 AI 或人工修改代码后，如涉及新增、删除、重命名文件，必须同步更新本文档。

---

## Gate A 收口 — GATE-A-FINAL-CLOSEOUT（2026-09-12，未发布）

> 本轮不开发功能，只做事实收口。产品代码 diff = 0、历法数据 diff = 0。

### Gate 定义正式拆分

```text
Gate A-Truth   CORE DIVINATION TRUTH                —— R3 的 blocker
Gate A-Compat  PROFESSIONAL SOFTWARE COMPATIBILITY  —— 不阻塞 R3
```

**理由**：原 Gate A 把「某专业软件人工填写结果」设为唯一真值来源，
把一件本质上是「兼容性观察」的事变成了 R3 blocker。
核心真值改由可复核的独立证据承担（独立规则核验 + 官方历法双源 +
秒级真值 + 边界 Golden Test + 259/259 自动测试）；
专业软件之间的流派差异（23:00 / 00:00 日界、晚子时 / 早子时、其他配置）
记为**兼容性 / 配置差异**，不自动视为核心算法错误。

### 新增
| 文件 | 职责 |
| --- | --- |
| `tool/gate_a/gate_a_gate_status.dart` | 双 Gate 定义 + Gate A-Truth 逐项表 + R3 最终状态块（单一真源） |

### 修改
- `tool/gate_a/gate_a_main.dart`：README 头改双 Gate 结构；
  总表拆出 `Truth Result` / `Compatibility Result` 两列；
  使用说明改为 Gate A-Compat 专用；清理残留旧标题
- `tool/gate_a/gate_a_cross_source.dart`：注释归属改为 Gate A-Truth
- `tool/gate_a/gate_a_solar_term_report.dart`：注释改为 PARTIALLY SECOND-LEVEL VERIFIED
- `gate-a/*.md`：全部重新生成（改 generator 真源，非手改产物）

### 最终状态
```text
R3-A                        PASS
R3-B                        PASS
R3-B-DATA-PRECISION-FIX     PASS
GATE A-TRUTH                PASS
GATE A-COMPAT               NOT EXECUTED / DEFERRED — NON-BLOCKING
R3                          FINAL ACCEPTED
```

### 日界
```text
DAY BOUNDARY ENGINE      PASS
PRODUCT DEFAULT POLICY   OPEN（不阻塞 R3 Domain Foundation）
```

### 未做
R4 未进入；专业软件人工对照未执行（Gate A-Compat，不阻塞）。

---

## 节气数据精度专项修复 — R3-B-DATA-PRECISION-FIX（2026-09-12，未发布）

> **根因**：分钟级官方显示值被保存为 `:00` 秒 Instant，而该分钟内存在
> 可验证的真实秒级交节时刻 —— **分钟级数据不足以表达该秒级边界**。
> 不是「HKO 错了」：官方双源 HKO / NAOJ 24 / 24 分钟级一致。

### 契约变更：数据包支持**混合精度**（schemaVersion 2，向后兼容 v1）
- `TermPrecision`：`minute`（缺省）/ `second`；
- 冻结语义：`minute` 时 `instantUtc` 秒位恒为 `:00`，
  只表示「**该分钟内**交节」，**不**表示「恰在第 0 秒交节」；
- 逐节气可选 `sourceOverride`（`name` + `reference`），不覆盖时沿用年度 `source`；
- 未知 `precision`、残缺 `sourceOverride` 一律拒绝导入。
- 原则：**数据包可以混合精度，但每条数据必须说清精度与来源**。
  以后逐年补更高精度节气只需替换对应 term，不必推翻年度包。

### 数据变更（严格最小）
- `assets/calendar/2026.calendar.json`：`schemaVersion 1→2`、`revision 1→2`；
  立春 `2026-02-03T20:02:00Z` → `2026-02-03T20:02:08Z`，
  附 `precision: second` 与来源覆盖（中国科学院紫金山天文台科普部）。
- 其余 23 条节气、其余 9 个年份包：**未改动**。
  未取得可信秒级真值的节气不补秒、不插值、不估算。

### 新增
| 文件 | 职责 |
| --- | --- |
| `lib/domain/calendar/import/calendar_data_pack_term_source.dart` | 逐节气来源覆盖校验 |
| `test/domain/calendar/solar_term_second_boundary_test.dart` | 立春秒级边界 Golden Test |
| `test/domain/calendar/calendar_terms_precision_test.dart` | 精度 / 来源元数据校验 |
| `test/domain/calendar/solar_term_precision_revision_test.dart` | 精度修订导入回归 |
| `tool/gate_a/gate_a_precision_closeout.dart` | 验收断言（走真实产品链路） |
| `tool/gate_a/gate_a_hko_source.dart` | HKO 官方 XML 解析（交叉核验用原始发布件） |
| `tool/gate_a/hko/24SolarTerms_2026.xml` | HKO 官方 XML 夹具（离线可重复） |

### 修改
- `solar_term/solar_term.dart`：增加 `precision` / `sourceName` / `sourceReference`
- `import/calendar_data_pack.dart`：增加 `TermPrecision` 与逐节气可选字段
- `import/calendar_data_pack_parser.dart`：解析 `precision` / `sourceOverride`
- `import/calendar_data_pack_terms.dart`：精度校验
- `import/calendar_data_pack_validator.dart`：支持 `schemaVersion 1..2`
- `test/domain/calendar/calendar_engine_test.dart`：原断言「04:02:00 即寅月」
  已随数据修正更新（该断言原本把缺陷锁成了「正确行为」）

### NOT changed（冻结范围 diff = 0）
`MonthBranchResolver` / `CalendarEngine` / `GanzhiDay` / `XunKong` /
`CastingEngine` / 八宫 / 纳甲 / 六亲 / 世应 / 六神 / UI；
自建 Meeus 尺子保持 `DIAGNOSTIC ONLY / REJECTED AS GATE ORACLE`。

### 验收断言
```text
04:01:00 → 丑   04:02:00 → 丑（修复点）   04:02:07 → 丑
04:02:08 → 寅（交节瞬间，含）   04:02:09 → 寅   04:03:00 → 寅
```

### 验证
`flutter test` 259 / 259；scoped analyze 0 issue；
全仓 analyze 27 = 基线（new 0 / removed 0）。

---

## Gate A 专业排盘人工对照验收 — GUAYAN-2.0-GATE-A（2026-09-11，未发布）

> 本轮**不写产品功能**，只做 R3-A + R3-B 的业务真值验收：
> 把「起卦时间 + 卦象输入」交给专业排盘软件逐项对照，
> 确认月建 / 日辰 / 旬空 / 六神 / 本卦 / 变卦 / 纳甲 / 五行 / 六亲 / 世应
> 与专业软件一致。**人工对照是唯一真值来源，Agent 不做自动判定。**

### 新增（tool/gate_a/ — 验收案例生成器，不参与 App 运行时）
- `gate_a_main.dart` — 入口：装载真实数据包 → 结构自检 → 生成 6 份验收表单
- `gate_a_context.dart` — 与产品完全同路径的引擎装配（JSON→校验→导入→仓储→Provider→Engine）
- `gate_a_cases.dart` — 案例矩阵：普通 13 例 / 经典 6 例 / 节气 12 节全量 / 日界 3 日
- `gate_a_hexagram_facts.dart` — 卦例事实计算 + **案例锁定**（本卦/变卦与声明不符即报错）
- `gate_a_case_report.dart` — 卦例对照表渲染（逐爻对照 + 专业软件填写位）
- `gate_a_solar_term_report.dart` — 节气**差异窗口**测量与探测矩阵（窗口起点 ±1s）
- `gate_a_day_report.dart` — 日界跨子时连续时间轴 × 两种规则
- `gate_a_hexagram_audit.dart` — 八宫表完整性 / 纳甲组装顺序 独立复核
- `gate_a_pillars.dart` — 四柱旁证（年柱以立春换年 / 五虎遁 / 五鼠遁）
- `gate_a_sun_longitude.dart` — 自建天文尺子（Meeus 太阳视黄经）→ **已证伪，降为 diagnostic**
- `gate_a_naoj_source.dart` — NAOJ「暦要項」Shift_JIS 字节级解析（**官方第二真值源**）
- `gate_a_cross_source.dart` — HKO vs NAOJ 双源交叉核验（24 项逐条）
- `gate_a_oracle_residual.dart` — 自建尺子的**时间残差**评估（对官方发布时刻）
- `gate_a_diag_rate.dart` / `gate_a_diag_sun.dart` — 尺子根因定位（变率 + 中间量）
- `gate_a_solve.dart` — 卦名 → 位串 → 动爻位（防手写位串出错）
- `gate_a_format.dart` / `gate_a_selftest.dart` / `gate_a_enumerate.dart`
- `naoj/rekiyou262.2026.html` — NAOJ 2026 页面字节夹具（离线可重复）
- `gate_a_runner.ps1` — 本机 PATH 包装（**纯 ASCII**：PowerShell 5.1 对无 BOM 的 .ps1 按 ANSI 解析，
  中文注释会变成语法错误；中文文档一律放在 Dart 源里）

### GATE-A-PREP-FIX1（同日补正，仅改验收矩阵，未动产品代码）
- 原 GA-3 用 `-1min / -30s` 作「分钟精度是否足够」的判据 —— **该判据无效**：
  它隐含假设「数据包分钟值 = 真实交节四舍五入到分钟（误差 ≤ 30 秒）」，
  而当时用自建天文尺测得十二「节」差异窗口 16s ～ 729s。
- 改为在「差异窗口起点」放测试点。
- ⚠️ **该轮结论已被 FIX2 推翻**（见下）：差异窗口本身是未验证尺子的产物。

### GATE-A-PREP-FIX2（同日二次补正，仅改验收工具与文档，未动产品代码）
- **撤回 FIX1 的结论**：自建尺子 `gate_a_sun_longitude.dart` 被证伪，不得作 Gate 真值。
  - 证据：对官方发布时刻的时间残差最大约 **729 秒**（立夏）；
    对 2026 立春秒级公开值残差约 **−343 秒**。
  - 根因（已定位）：视黄经**日变率正确**（1.0187 vs 官方 1.0187 °/日），
    但在官方交节瞬间本尺子已越过目标角 9～30 角秒，且偏差随季节变化（与中心差 C 同相）
    —— 属**绝对项偏差**；「求根反代 = 0.000000°」的自洽性不能证明绝对正确。
  - 处置：`REJECTED AS GATE ORACLE`，降为 diagnostic tool，不用于建窗、不作真值。
  - 旧自检 `<0.01°` 降级为 coarse sanity check（0.01° ≈ 14.6 分钟时间，
    通过它不足以证明分钟级/秒级精度）。
- **新增官方双源真值**：HKO（HKT）vs NAOJ「暦要項」（JST→HKT 减 1 小时），
  2026 年 **24 / 24 日期一致、分钟一致** → 官方分钟级真值成立。
- **GA-3 重建**：测试点只以官方发布值为准 ——
  全部十二「节」给 `边界 −1min / 边界 / 边界 +1min`；
  有可追溯秒级公开值者（当前仅立春 2026：紫金山天文台科普部 04:02:08 +08:00）
  追加 `exact −1s / exact / exact +1s`。
  **已删除**所有由未验证尺子推导的差异窗口测试点。
  来源无法确认的 `04:01:51` 不予收录。
- **Gate A2 状态**：当时为 `UNRESOLVED — ASTRONOMICAL ORACLE NOT YET VALIDATED`，
  既不 PASS 也不 FAIL 数据源、不得据此升级 CalendarDataPack。
  > ⚠️ **该状态已被同日后续的 R3-B-DATA-PRECISION-FIX 取代**：
  > 立春取得可信秒级真值并写入数据包，Gate A2 现为 `PARTIALLY VERIFIED`。
  > 本节保留为历史教训（不得删除）。

### 新增（gate-a/ — 生成的验收表单，待用户回填）
- `README.md` / `01-normal-cases.md` / `02-classic-cases.md` /
  `03-solar-term-boundaries.md` / `04-day-boundary.md` / `05-master-table.md`

### 结构与真值自检结论
- 八宫表：64 组合一一对应、每宫 8 卦、世应相隔三位 → PASS；
- 案例锁定：19 例本卦/变卦与声明一致、纳甲组装顺序正确 → PASS；
- 官方双源：HKO vs NAOJ 2026 年 24 / 24 日期一致、分钟一致 → PASS；
- 日柱锚点 1949-10-01 = 甲子（外部黄历源核），2026-02-04 = 己酉（跨 76 年独立源核）；
- 自检已捕获并修正的错误：动爻下标 0/1 基混用、节气误取相邻年份、
  六冲/六合 手感分类（水地比与地风升均非六冲）、六爻位串写错 6 处、手算日柱 3 处、
  自建尺子 JD↔Unix 纪元多加 0.5 天（全体偏移 12 小时）与章动缺项。

### 未做
产品代码未改动（`lib/`、`test/` diff = 0）；Gate A 未 PASS；
日界默认值未冻结；**节气数据源不升级**（Gate A2 未定论）。

---

## 离线历法基础层 — GUAYAN-2.0-R3-B-CALENDAR（2026-09-11，未发布）

> **路线变更**：不再把 1900–2100 的 4824 条节气硬编码进源码，
> 改为 **年度数据包 + 本地仓储 + 完全离线计算**。
> 已导入年份离线排盘；未导入年份**明确拒绝**，绝不近似补算。
> 纯 Dart，零 Flutter / 零运行时网络 / 零天文库 / 零近似 fallback。

### 新增（lib/domain/calendar/）
- 根：`calendar_engine.dart`（聚合）/ `calendar_request.dart` / `calendar_context.dart` /
  `calendar_error.dart`（类型化失败）/ `day_boundary_rule.dart`（两种规则，无默认值）
- `day/`：`ganzhi_day.dart`（JDN → 六十甲子）/ `xun_kong.dart`（旬空由旬首推导）
- `solar_term/`：`solar_term_id.dart` / `solar_term.dart` / `solar_term_provider.dart` /
  `calendar_year_data.dart` / `month_branch_resolver.dart`（十二「节」切月建）
- `import/`：`calendar_data_pack.dart` / `calendar_data_pack_parser.dart` /
  `calendar_data_pack_terms.dart` / `calendar_data_pack_validator.dart` /
  `calendar_data_pack_importer.dart`（解析→校验→修订→**原子提交**）
- `store/`：`calendar_data_store.dart`（仓储边界 + 内存实现）/
  `stored_solar_term_provider.dart`（仓储→Provider，装载快照后引擎保持同步）

### 新增（数据与工具）
- `assets/calendar/2019..2028.calendar.json` — 种子数据包 10 年，
  与用户导入**同一种格式**（不存在「内置走 Dart 常量」的第二套体系）
- `tool/calendar_pack_gen/generate_calendar_packs.dart` — 开发阶段生成器，
  **不参与 App 运行时**；权威源缓存 `.cache/` 已 gitignore

### 数据来源（可复核）
- 香港天文台 HKO「二十四節氣的日期及時間資料」；HKO 注明其天文数据来自
  英国 HM Nautical Almanac Office 与美国 United States Naval Observatory；
- 原始基准 HKT（UTC+8）→ 统一折算 UTC；
- **来源为分钟级，秒位恒为 `:00`**（如实记录，不虚构秒级精度）；
- 覆盖 2019–2028（HKO 公开范围）；与 NAOJ 在重叠年份逐项一致。

### 关键契约
- 月建边界：`instant < 交节 → 旧月建`，`instant >= 交节 → 新月建`（三态断言）；
- 缺年份抛 `CalendarDataMissing`；导入原子性（校验通过前不写仓储）；
- 修订四态 NEW / UPDATE / SAME / DOWNGRADE，降级拒绝且旧数据不变；
- 日界：仓库既有代码未冻结规则 → 核心层实现两种并要求显式传入。

### 测试（+103，共 232/232 通过；analyze 0 issue）
`test/domain/calendar/`：ganzhi_day / xun_kong / day_boundary /
month_branch_resolver / calendar_data_pack_parser / calendar_data_pack_validator /
calendar_pack_import / calendar_engine / offline_gate（+ 夹具 fixtures）

### 未做
历法管理 UI、导入按钮、文件选择器、覆盖确认弹窗；完整天文算法；
旺衰 / 月破 / 日冲 / 神煞 / 四柱完整系统。

---

## 排盘引擎 R3 卦体层 — GUAYAN-2.0-R3-ENGINE-A（2026-09-11，未发布）

> **排盘从演示档案变成真实计算。** 纯 Dart 领域层，零 Flutter 依赖；
> Widget 一律不得自行排卦（总计划 §10）。本轮覆盖 R3 清单 12 项中的 9 项。

### 新增（lib/domain/ — 基础坐标）
- `wu_xing.dart` — 五行 + 生克；`relationTo(self)` 是六亲判定唯一入口
- `di_zhi.dart` — 十二地支：五行 / 阴阳 / 六冲 / 六合
- `tian_gan.dart` — 十天干：五行 / 阴阳 / 六十甲子取干

### 新增（lib/domain/casting/ — 排盘引擎）
- `bagua.dart` — 八卦（三爻自下而上）+ 卦符 + 五行 + 先天序
- `najia.dart` — 纳甲表（干支）：乾纳甲壬、坤纳乙癸；内外卦分别装卦
- `palace.dart` — 京房八宫卦序 + 世应（算法生成，非硬编码 64 条）
- `hexagram_names.dart` — 六十四卦名表（上卦 × 下卦）
- `hexagram64.dart` — 六爻阴阳 → 卦名 / 宫位 / 世应
- `six_relative.dart` — 六亲（以宫位五行为「我」）
- `six_spirit.dart` — 六神（按日干起例，自初爻向上顺排）
- `cast_chart.dart` — 排盘结果模型（CastLine / CastChart）
- `casting_engine.dart` — 引擎组装：本卦 / 变卦 / 动变 / 纳甲 / 世应 / 六亲 / 六神

### 关键契约
- 世应由「本宫卦逐爻翻转 → 游魂回翻四爻 → 归魂还原内卦」推导，
  世爻序列恒为 6/1/2/3/4/5/4/3，不维护 64 条硬编码表；
- **变卦六亲仍取本卦之宫**为「我」（传统固定规则）；
- 静卦不生成变卦；无日干时六神为 null；非法输入抛异常。

### 测试（+23，共 129/129 通过；analyze 0 issue）
- `test/domain/casting/hexagram_tables_test.dart` — 表完整性与规则测试
- `test/domain/casting/casting_engine_test.dart` — 经典排盘对照
  （乾为天 / 坤为地 / 泽山咸 全爻纳甲·六亲·世应）

### 未做（R3-B）
- 四柱 / 月建 / 日辰 / 旬空（需干支历法 + 节气推算）；
- 引擎接入审卦页，替换 `ReviewTraditionalProfile` 占位字段。

---

## 基线收口 — GUAYAN-2.0-R5-BASELINE-CLOSEOUT（2026-09-10，未发布）

> 收口 `3c00187` 遗留基线：排卦 lines 顺序 Bug 独立落库（`7266332`）；
> 审卦 4 个红测逐项契约审计（3 项 TEST STALE、1 项混合），恢复全量测试绿色。

- `lib/services/draft/casting_draft.dart` — demo().lines 改升序，锁死
  `index = position - 1` 契约；`casting_page_test.dart` 补逐爻位回归
- `lib/presentation/review/widgets/review_hexagram_line_row.dart` —
  主/变卦文本列宽封顶（74/88 设计 px，列缘裁剪不压爻槽）；
  类文档对齐实际基线 18/24/34 与 FittedBox(contain)
- `lib/presentation/review/widgets/review_shensha_card.dart` — 类文档改为
  「数据驱动固定 4 列（按实际数据渲染，无强制空占位）」；移除未使用 import
- `test/presentation/review/review_page_test.dart` — F1 基线（六行共享基线 +
  恰 3 条基线带，不绑绝对坐标）/ F2 神煞（按数据渲染无占位）/ F3 基本信息
  （合并行信息在场）/ F4 超长纳音（缩放无关列契约 + 主变卦双侧不压爻槽）
  四测重写
- 验证：flutter test 106/106 通过；analyze 本轮文件 0 issue；无依赖浮动。

---

## 审卦首屏 R4 · Baseline Alignment 定稿 — GUAYAN-2.0-REVIEW-BASELINE-R4（2026-08-31，未发布）

> 只动两个组件（六爻卦盘 + 神煞），其余已定稿 UI 一律不动。
> 目标：真正建立"行基线"与"列中心线"，消灭视觉参差。

### 六爻卦盘（review_hexagram_line_row.dart 重写）
- **Primary Baseline = RowTop + 19**：六神 / 伏神1 / 伏神2 / 主卦正文 /
  主卦世应 / 变卦正文 / 变卦世应 全部用 Flutter `Baseline` 数学锁定同一条基线；
- **NaYin Baseline = RowTop + 35**：主卦/变卦纳音各自居中于正文列；
- 行高 48；列中心冻结（六神22 伏神1·62 伏神2·100 主卦正文174 主卦爻222
  世应250 动爻268 箭头280 变卦正文318 变卦爻358 变卦世应388）；
- 字号层级按定稿：六神 9.4 常规 / 伏神 9 常规 / 世应 8.8 常规 /
  正文 10.5 加粗（linePrimary #314D59）/ 纳音 9 常规；
- 整行 400 设计坐标空间 + FittedBox(scaleDown) 自适应（行内无边框，
  分割线由表格层独立绘制，保证 FittedBox 父高恰 48、不做纵向缩放）；
- 爻槽 24×6 / 动爻 12×12 / 箭头 6 固定，文本不侵占。

### 神煞（review_shensha_card.dart）
- **FIXED 4×4 Grid**：格宽 89、格高 18、列距 6、行距 4（数据驱动，
  <16 项留空占位保持 4×4，>16 才加第 5 行）；禁止自由 Wrap；
- 字号 9.4 / w600 / #5C7078；第 4 行永远在 Card 内。

### 表头
- guaTitle 13 / guaName 10.8（review_hexagram_result_table.dart）

### Token
- 新增 `linePrimary #314D59`、`shenShaItem #5C7078`

### 测试（+3）
- R4 基线数学锁定：行内全部 Baseline ∈ {19, 35}，主基线 6 条 / 纳音 2 条；
- R4 神煞固定 4×4：16 格无溢出、同列对齐、第 4 行在卡内；
- R4 神煞 <16 项：12 空位占位仍保持 4×4。
- 验证：flutter test 106/106 通过；analyze 本轮文件 0 issue；debug APK 构建通过。

---

## 审卦首屏 R3 舒适紧凑版 — GUAYAN-2.0-REVIEW-ONSCREEN-R3（2026-08-31，未发布）

> 目标：**六爻六行必须在审卦首屏完整露出**（硬门禁，不接受下滑才能看到朱雀/初爻）。

### 本轮布局规则（R3 总 SVG）
- **卦名 Header 66 → 54 DIP**：主卦/变卦标题 + 卦名各一行（h2 12 / gua 10）
- **伏神改 3 字短格式**：六亲简称 + 地支 + 五行（`财寅木 / 父未土`），
  替换被宽度裁切的 `财丙… / 父丁…`；演示数据 12 项全部转换
- **六爻行高 56 → 48 DIP**：主/变卦正文仍两行完整显示（六亲地支 10px +
  纳音 8.8px），**无省略号**；列宽重算（六神 24 / 伏神 28 / 世应 12 / 动爻 12 /
  箭头 6 / 爻槽 24），360 DIP 不横向溢出
- 紧凑化：四柱 44→40、神煞 chip 24→19（rx9.5、字号 8.8）、BasicInfo 84（h2 12）、
  页面间距 8→6
- 表尾文案：`点击任一爻查看关系、规则依据与关系备注`

### 文件
- `review_demo_data.dart` — 伏神 3 字短格式（财寅木/父未土/孙子水/兄酉金…）
- `review_hexagram_line_row.dart` — 行高 48、列宽重算、字号按 R3 SVG
- `review_hexagram_result_table.dart` — Header 54、表尾文案
- `review_basic_info_card.dart` / `review_four_pillars_strip.dart` /
  `review_shensha_card.dart` / `review_page.dart` — 紧凑化
- `test/presentation/review/review_page_test.dart` — 新增硬门禁测试：
  430×932 下六爻六行 + 表尾在导航区之上完整可见；伏神断言更新
- 验证：flutter test 103/103 通过；analyze 本轮文件 0 issue；debug APK 构建通过。

---

## 审卦一屏版收口 — GUAYAN-2.0-REVIEW-ONSCREEN（2026-08-31，未发布）

> 整体收口：一屏先看完整基本信息 + 神煞 + 四柱 + 完整卦盘；
> 点某一爻后再弹关系焦点（Bottom Sheet）。彻底解决"为塞关系焦点把卦盘挤小"。

### 审卦页
- `review_page.dart` — 一屏布局：AppBar → BasicInfo → 四柱 → 神煞 4×4 → 完整卦盘；
  「关系焦点」不再常驻（删除 RelationFocusCard）；点爻高亮 + 弹层；
  新增 `onOpenRelations` 回调（App Shell 切到关系 Tab）
- `widgets/review_basic_info_card.dart` — 紧凑单卡：问事 + 方式 chip + 公历/农历两栏 +
  meta（规则包 v1 · 手动起卦 · 排盘已生成）
- `widgets/review_four_pillars_strip.dart` — soft 底 44 高，teal/warm 双色，旬空右对齐
- `widgets/review_shensha_card.dart` — chip 20 高、间距 4 的紧凑 4×4 网格
- `widgets/review_hexagram_result_table.dart` — 表头 66 高（【主卦】/【变卦】）+ 行点击透传 +
  表尾「完整排盘 · 点击任一爻查看关系与规则依据」
- `widgets/review_hexagram_line_row.dart` — **彻底取消省略号**：六亲地支与纳音拆上下两行；
  11 列固定槽位，文本不侵占爻槽/世应槽；行可点（高亮）
- `widgets/review_line_detail_sheet.dart`（新增）— 点爻 Bottom Sheet：当前爻信息 +
  关系列表（来自 RelationInstance）+ 查看规则依据 + 关系备注（GAP）+ 进入关系页
- 删除 `review_relation_focus_card.dart`
- `review_page_state.dart` / `review_case_adapter.dart` — 新增 `allRelations` +
  `relationsInvolving(position)` + `relationLabel`（点爻弹层按爻过滤，仍来自 Domain）
- `review_demo_data.dart` — 演示数据对齐一屏版 SVG（问事/公历 09:30/农历 七月十八 · 巳时/
  旬空 申酉空）

### 排卦页
- `line_editor_sheet.dart` — 爻象选项卡固定 `mainAxisExtent: 58`（≥58 DIP 硬门禁），
  内容垂直居中，任何屏幕 RenderFlex 溢出 = 0（修复 BOTTOM OVERFLOWED 1.2px）

### 共享 / Token
- `casting_tokens.dart` — gua #927848、pillarTeal #4F8685、新增 pillarWarm #A8605C
- `shared/yao_glyph.dart` / `shared/moving_marker.dart` — 描边宽度按一屏版 SVG 微调
  （空亡 1.4 / ○× 1.6）

### 测试
- `review_page_test.dart` — 一屏版适配 + 点爻弹层（关系列表/进入关系页回调）+
  窄屏 360 无溢出；UI-04~08 保留
- `casting_page_test.dart` — 新增「爻象弹层窄屏 360×640 无 RenderFlex 溢出」测试
- `foundation_test.dart` — 审卦分支断言改为 神煞
- 验证：flutter test 102/102 通过；analyze 本轮文件 0 issue；debug APK 构建通过。

---

## 排卦页 + 审卦页增量修正 — GUAYAN-2.0-UI-CORRECTION-R2（2026-08-30，未发布）

> 在 R1 已定稿基础上做增量修正，禁止重新设计。本轮冻结：统一爻槽 24×6
> （阳/阴/空亡仅内部填充不同）、动爻标记 12×12、文本不得压爻。

### 新增（lib/presentation/shared/ — 排卦/审卦强制复用）
- `yao_glyph.dart` — 统一爻槽组件：YaoGlyph（24×6，yang/yin/voidYao）+ YaoKind；
  `YaoGlyph.fromMovement` 便捷工厂；空亡爻空心描边 rx1 #7E9098 w1.5
- `moving_marker.dart` — 动爻标记组件：MovingMarker（12×12，老阴 ○ #A17F45 /
  老阳 × #567866）+ `MovingMarker.of` 便捷工厂

### 排卦页修正
- `casting_page.dart` — 删除顶部 CastingDraftContext（§1.1）；正文顺序：
  AppBar → 起卦时间 → 问事信息 → 六爻录入 → 规则包 → 生成排盘
- `casting_time_row.dart` — 重写为 88 高卡片：标题 + 右上「已完成/待完善」chip +
  公历 + 农历（§2 SVG；农历为 lunarPlaceholder presentation mock，GAP 标注）
- `casting_page_state.dart` — 新增 `lunarPlaceholder(DateTime)`（GAP：真实农历换算待接入）
- `six_yao_input_row.dart` — 普通行 = 编辑行 = 52 DIP（§3：编辑态只变背景/边框/字重/徽标）；
  爻象迁移共享 YaoGlyph
- `line_editor_sheet.dart` — 迁移共享 YaoGlyph + 动爻补 MovingMarker
- 删除 `casting_draft_context.dart`、旧 `casting/widgets/yao_glyph.dart`

### 审卦页修正
- `review_page_state.dart` — ReviewLineView：hiddenSpirit 拆为 hiddenSpirit1/2（伏神两列）；
  新增 isVoid（主卦/变卦，UI 表现专用，Widget 不计算旬空）；纳音括号改半角 `(纳音)`
- `review_case_adapter.dart` / `review_demo_data.dart` — 伏神两列 + isVoid 透传；
  演示数据按 R2 SVG #12：五爻丁酉、三爻丙申空亡（旬空申酉）
- `review_shensha_card.dart` — 神煞固定 4 列 × N 行数据驱动网格（§5 SVG 402×178，
  >16 项继续加行）
- `review_hexagram_result_table.dart` — 最终卦盘组件（§6/§12 SVG 402×404）：
  内嵌【主卦】/【变卦】标题（浅底 #F8FBF9）+ 六行排盘 + 表尾说明
- `review_hexagram_line_row.dart` — 11 列冻结：六神 | 伏神1 | 伏神2 | 主卦文字 |
  主卦爻槽(24×6) | 主卦世/应 | 动爻(12×12) | 箭头 | 变卦文字 | 变卦爻槽 | 变卦世/应；
  文字列 Ellipsis 裁剪，爻槽/世应槽固定不被侵占（§11 硬门禁）
- `review_page.dart` — 移除 HexagramResultHeader（表内已含标题，避免重复）
- 删除 `review_hexagram_result_header.dart`

### 测试
- `test/presentation/casting/casting_page_test.dart` — UI-01（无 DraftContext）/
  UI-02（公历+农历）/ UI-03（普通行高==编辑行高==52）
- `test/presentation/review/review_page_test.dart` — UI-04（神煞首屏 4 列）/
  UI-05（爻槽统一 24×6）/ UI-06（动爻 12×12）/ UI-07（超长文本不压爻）/
  UI-08（变卦爻槽+变卦世应同显）+ R1 测试适配（YaoGlyph.kind、MovingMarker）
- `test/presentation/shared/yao_glyph_test.dart`（新增）— 共享组件尺寸冻结测试
- `test/foundation_test.dart` — 审卦分支断言改为【主卦】

### 说明
- 演示 pos2（老阳）主卦按语义渲染阳槽 + X；SVG #12 画作阴+X，属有意修正
  （保持阴阳语义一致，已注释记录）。
- 验证：flutter test 100/100 通过；analyze 本轮文件 0 issue；debug APK 构建通过。

---

## 审卦页 XYUI 工作台 — GUAYAN-2.0-REVIEW-UI-R1（2026-08-30，未发布）

> 目标：把「审卦」占位页实现为人工定稿的 XYUI 长页排盘工作台。
> 视觉以任务书总 SVG 为最高优先级；传统排盘字段（六神/伏神/六亲/神煞/四柱/卦名）
> 由演示档案提供，真实计算属后续排盘引擎（R3）—— 本轮不做假六爻算法。

### 新增（lib/presentation/review/）
- `review_page.dart`（重写占位页）— 审卦工作台：SafeArea → ReviewAppBar → Expanded
  SingleChildScrollView（BasicInfo → ShenSha → FourPillars → HexagramHeader →
  HexagramTable → RelationFocus）；MainTabBar 固定在 App Shell
- `review_page_state.dart` — 纯 Dart 状态模型：ReviewPageState（§7 全部字段）/
  ReviewLineView / ReviewChangedLine / ReviewShenShaItem + formatSolar
- `review_case_adapter.dart` — HexagramCase + ReviewTraditionalProfile → ReviewPageState；
  焦点关系一律来自 calculateRelations（Stable Relation Identity），禁止 UI 重算
- `review_demo_data.dart` — 视觉定稿演示数据（SVG 逐项转录：泽山咸→泽水困、16 神煞、
  丙午年丙申月丙子日丁酉时、六神/伏神/六亲/纳音/世应、两动爻）
- `widgets/review_app_bar.dart` — 顶栏（返回 chevron + 审卦 + 排盘结果，§1）
- `widgets/review_basic_info_card.dart` — 方式/事项/阳历/阴历 + 已生成 chip（§2）
- `widgets/review_shensha_card.dart` — 神煞独立卡片 + 自适应 Wrap 标签网格（§3/§8）
- `widgets/review_four_pillars_strip.dart` — 年/月/日/时/旬空 横向紧凑 Strip（§4）
- `widgets/review_hexagram_result_header.dart` — 排盘结果 + 主/变卦标题（§5）
- `widgets/review_hexagram_result_table.dart` — 六爻排盘主体表（§6，上爻在上初爻在下）
- `widgets/review_hexagram_line_row.dart` — 单行：六神 | 主卦（含伏神）| 变卦；
  爻象复用 YaoGlyph 矢量绘制，世应/动爻箭头矢量
- `widgets/review_relation_focus_card.dart` — 关系焦点卡（§7：世应/生克/回头生回头克
  入口 + 查看规则依据 › 跳转规则库）

### 修改
- `lib/presentation/casting/casting_tokens.dart` — 补充 §4 Token：relationRed 系 /
  relationBlue 系 / traditionalGold / pillarTeal（movingCircle 别名到 traditionalGold）
- `lib/presentation/casting/casting_page.dart` — 新增可选 `onGenerated` 回调（生成后通知 Shell）
- `lib/app/app_shell.dart` — 审卦页同样隐藏全局 AppBar（自带 XYUI TopBar）；
  `_latestCase` 桥接排卦生成结果 → 审卦页（T12 数据接入）
- `test/foundation_test.dart` — 审卦分支断言改为无全局 AppBar + 完整排盘/关系焦点
- `test/presentation/review/review_page_test.dart`（新增）— §22 Test A–H + 适配器单测

### 数据接入（T12/T13）
- 排卦页生成后经 `onGenerated` 把 HexagramCase 交给 App Shell，审卦页渲染真实卦例：
  六爻/地支/时间/规则版本来自 Domain，关系焦点由 calculateRelations 计算；
  六神/伏神/六亲/神煞/四柱/卦名等传统字段真实卦例下显式置空（GAP：排盘引擎 R3）。
- 未生成过卦例时审卦页渲染视觉定稿演示排盘（含完整传统档案），供人工视觉验收。

### 说明
- 演示爻序与 Domain 契约一致（1 初爻 .. 6 上爻升序）；动爻标记遵循 §22 D/E 语义
  （老阳=阳爻实线 + X），与 SVG 个别爻线画法存在一处有意修正（Row5），已记录。
- 验证：flutter test 84/84 通过；analyze 本轮文件 0 issue（21 条旧代码告警未动）；
  debug APK 构建通过。

---

## 卦眼 2.0 Foundation — feat/guayan-2.0

> 分支：`feat/guayan-2.0`（继承 GitHub 历史，2.0 App 架构重新开发，旧功能未来收编进「训练」入口）

### 新增 2.0 骨架
- **入口极简化**：`lib/main.dart` 只做 `runApp(const GuayanApp())`，不再跳旧 HomePage、不再初始化旧 MistakeStore。
- **`lib/app/`**：2.0 应用壳
  - `app.dart` — `GuayanApp`：MaterialApp 组装 + 全局主题（浅色、紧凑）
  - `app_shell.dart` — `AppShell`：IndexedStack 状态保持 + GuayanMainTabBar 五主导航（XYUI），`selectedIndex` 单一权威来源，默认 Index 0（排卦）；排卦页自带 XYUI TopBar（无全局 AppBar）
  - `navigation/main_tabs.dart` — 正式产品 IA：排卦/审卦/关系/卦例/训练（顺序固定）；MainTab 含 title / iconBuilder / builder
  - `navigation/guayan_main_tab_bar.dart` — XYUI 化底部导航（任务书 §15）：活动底色 + 矢量图标（GuayanTabIcons）+ 标签
  - `more_menu.dart` — 「更多」菜单：规则库 / 设置 / 关于（支持自定义 icon，排卦页用三点样式）
- **`lib/core/constants/app_info.dart`**：应用名「卦眼」、内部版本、主题种子色常量
- **`lib/domain/`（预留）**：GUAYAN-2.0-DOMAIN 阶段在此建立 HexagramCase / LineState / RelationInstance / RelationNote 等
- **`lib/application/`（预留）**：后续用例层；Foundation 阶段仅 AppShell 用 StatefulWidget，不引入状态管理框架
- **`lib/presentation/`**：五个主页面 + 规则库/设置/关于
  - `casting/casting_page.dart` — 排卦页：XYUI 排卦工作台（R1 定稿布局：起卦时间 → 问事信息 → 六爻录入 → 规则包 → 生成排盘）
  - `casting/casting_tokens.dart` — XYUI 视觉 Token（任务书 §3 定稿值，排卦页 + 底部导航共用）
  - `casting/casting_page_state.dart` — GenerationState / DraftState / CastingPageState（§7 全部字段）
  - `casting/widgets/` — casting_app_bar / draft_context / time_row / question_row / six_yao_input_panel / six_yao_input_row / yao_glyph / rule_pack_row / generate_row / chip / 四个编辑弹层（line/time/question/rule_pack sheet）
  - `review/review_page.dart` — 审卦工作台
  - `relations/relations_page.dart` — 关系工作台
  - `cases/cases_page.dart` — 卦例工作台
  - `training/training_page.dart` — 训练（旧功能未来统一收编，本阶段仅 Skeleton）
  - `rules/rule_library_page.dart` — 规则库 Skeleton（自定义规则/规则包/系统规则，无 CRUD）
  - `settings/settings_page.dart`、`about/about_page.dart` — 占位页
  - `shared/module_placeholder.dart` — 模块占位共用组件
- **`lib/services/draft/`**：草稿自动保存边界（§15）
  - `casting_draft.dart` — 草稿模型（含视觉定稿演示草稿 CastingDraft.demo）
  - `draft_repository.dart` — DraftRepository 接口 + 内存实现（后续可换本地存储）
- **`test/foundation_test.dart`**：App Shell 五导航 / 艮卦图标 / 状态保持 / 更多菜单验收
- **`test/presentation/casting/casting_page_test.dart`**：排卦工作台测试（Test A–D / 行顺序 / 草稿仓库 / 纯逻辑）

### 修改
- `android/app/src/main/AndroidManifest.xml` — Activity 增加 `android:screenOrientation="portrait"` 锁定竖屏；label 确认「卦眼」
- `lib/main.dart` — 替换为 2.0 极简入口
- `file-tree.md` — 记录 2.0 骨架

### 说明
- 旧训练资产（`lib/pages/`、`lib/data/`、`lib/services/`、`lib/models/`、`lib/widgets/effects/`、`五行相克特效/`、`五行相生特效/` 等）一律保留未迁移，后续进入「训练」阶段统一处理。
- 旧 `lib/app.dart`（`GuayanTrainerApp`）保留供旧测试引用，与 `lib/app/` 目录共存。
- 分支创建前已将未发布 hotfix 提交至 master（`610e81f`）并合并远端学习模块提交（`5c4bdb6`）。

---

## 成果归档提交 — 2026-08-27（未发布）

> 背景：开发机内存耗尽崩溃重启（Gradle 提交内存 errno 1455），判定本机暂不具备继续开发条件，全部工作成果一次性归档提交并推送 GitHub（`feat/guayan-2.0`），防止成果丢失。详见 `CHANGELOG.md`。

### 新增
- `AGENTS.md` — 项目代码规则（文件组织 / 架构分层 / 命名规范 / 文档纪律 / 版本与构建），AI 自动遵守
- `lib/data/training_question.dart` — 2.0 训练数据模型：`TrainingModule` / `RelationType` / `TrainingQuestion`
- `lib/data/wuxing_questions.dart` — 五行生克题库：相生 5 题 + 相克 5 题（10 题）
- `uploads/` — 参考资料：`XYUI1ComponentDocumentView.axaml`、`卦眼 2.0 总开发计划.md`
- `五行相克特效/` — 5 个相克 HTML 动画原型（金克木/木克土/土克水/水克火/火克金）
- `五行相生特效/` — 5 个相生 HTML 动画原型（金生水/水生木/木生火/火生土/土生金）
- `CHANGELOG.md` — 文件审计与变更日志

### 修改
- `android/gradle.properties` — 低内存开发机约束：JVM 堆 1G、Kotlin daemon 256m、`org.gradle.workers.max=1`，避免构建提交内存耗尽
- `file-tree.md` — 记录归档提交、新增文件与最后编辑时间

---

## GUAYAN-2.0-DOMAIN — Stable Relation Identity（2026-08-30，未发布）

> 阶段目标：**RelationInstance 可以重建，RelationNote 不能失忆。**
> 只做四个核心 Domain + 稳定关系身份，不扩范围；完整设计见 `lib/domain/README.md`。

### 新增（lib/domain/ — 纯 Dart 领域层，零 Flutter/外部依赖）
- `hexagram_case.dart` — 卦例持久化根对象（最小骨架）
- `line_state.dart` — 一爻状态：稳定爻位 + 动静 + 所值地支
- `line_endpoint.dart` — 关系端点稳定身份（卦侧 + 爻位）
- `relation_type.dart` — 关系类型枚举 + 系统规则 RuleId 常量
- `relation_key.dart` — **Stable Relation Identity 核心**（单一构造入口）
- `relation_instance.dart` — 一条具体关系（重算可重建）
- `relation_calculator.dart` — 最小确定性关系计算（动变/六冲/六合）
- `relation_note.dart` — 关系笔记（caseId + RelationKey 重新绑定）
- `relation_note_store.dart` — 笔记绑定存储（纯内存 + JSON 导入导出）

### 新增（test/domain/）
- `domain_test_utils.dart` — 共享演示卦例（动变 + 六冲）
- `relation_key_test.dart` — Test A 确定性 / Test B 差异性 / 方向处理
- `relation_key_serialization_test.dart` — RelationKey JSON round-trip 与展示名解耦
- `relation_rebinding_test.dart` — Test C 重算恢复笔记 / Test D 不串笔记 / Test E 顺序无关
- `relation_serialization_test.dart` — T8 序列化 → 反序列化 → 重算 → 重新绑定全链

### 新增（scripts/）
- `flutter.ps1` → 已删除：本机 Flutter 包装脚本移出版本控制（HARDENING T4）。
  本机工作区保留 `scripts/flutter.local.ps1`（含机器路径与代理端口，已 .gitignore，不入库）

### 修改
- `lib/domain/README.md` — 占位说明替换为 Stable Relation Identity 设计文档
- `test/domain/`（新建目录）、`scripts/`（新建目录）
- `file-tree.md` — 记录 DOMAIN 阶段新增与职责

### 说明
- RelationKey = 语义坐标（类型机器名 + RuleId + RuleVersion + subtype + 端点），
  与运行时对象 / UI 顺序 / 数据库 row id 解耦；方向显式处理（有向保序、对称排序）。

---

## GUAYAN-2.0-DOMAIN-HARDENING — 身份收口（2026-08-30，未发布）

> 人工核验后封死 4 个数据兼容问题；不重构、不进入 R3。
> 验收句：RelationInstance 可重建；RelationNote 不失忆；
> RuleVersion 变化不能让历史卦例失忆；任意合法 RuleId/Subtype 不能制造身份碰撞；
> 坏 Case 数据不能制造重复身份。

### 新增
- `lib/domain/rule_execution_context.dart` — 规则版本 replay 上下文（RuleVersionRef / RuleExecutionContext）
- `test/domain/relation_key_collision_test.dart` — T1 canonical 无歧义性（含 `|`/`->`/`<->`/`\` 碰撞回归）
- `test/domain/rule_version_replay_test.dart` — T2 旧卦例 v1 → 升级 v2 → reload → replay v1 → 笔记恢复
- `test/domain/domain_invariants_test.dart` — T3 爻位/六爻不变量 + 坏 JSON 拒绝

### 修改
- `lib/domain/relation_key.dart` — canonical 无歧义化：字符串字段稳定转义（`\`→`\\`，`|`→`\|`），单射编码
- `lib/domain/hexagram_case.dart` — 新增 `ruleContext` 字段；runtime 校验恰好 6 爻、position 恰为 1..6、无重复
- `lib/domain/line_endpoint.dart` / `line_state.dart` — 构造与 JSON 反序列化 runtime 校验爻位（1..6）
- `lib/domain/relation_calculator.dart` — 规则版本优先取 `case.ruleContext.versionForOrDefault(ruleId)`，无记录回退 v1
- `.gitignore` — `scripts/flutter.local.ps1` 不入库；`*.apk` 忽略
- `lib/domain/README.md` — 补充 escaping / replay 契约 / runtime 不变量设计
- `scripts/flutter.ps1` — 删除（移出版本控制）

### 验证
- `flutter test` 53/53 通过（原 Test A–E + T8 无回归；新增 23 项）
- `flutter analyze` 本轮文件 0 issue；Android debug 构建成功；未启动模拟器

---

## 排卦页 XYUI 改造 — Vertical Casting Workflow（2026-08-30，未发布）

> 方案 2 · 纵向排卦流程轨：起卦时间 → 问事信息 → 六爻输入 → 规则包 → 生成排盘。
> 视觉以任务书 SVG 为唯一基准；本轮为视觉阶段，步骤摘要为演示占位值，
> 完整表单与排盘算法属后续阶段。

### 新增（lib/presentation/casting/）
- `casting_tokens.dart` — XYUI 视觉 Token 集中（页面/面板/边框/文字/警示/徽标/生成步骤）
- `casting_page_state.dart` — `CastingStepState`（current/pending/completed/warning/locked）+ `CastingStepData` + `CastingFlowState`
- `widgets/casting_top_bar.dart` — XYUI 顶栏（标题/副标题/三点更多）
- `widgets/casting_flow_header.dart` — CASTING FLOW 头部（当前步骤 x/5）
- `widgets/casting_workflow.dart` — 流程轨组装（rail + 步骤行）
- `widgets/casting_flow_rail.dart` — 纵向竖线
- `widgets/casting_step_node.dart` — 节点状态全集（数字/对勾/!/锁，矢量绘制）
- `widgets/casting_step_card.dart` — 步骤卡（current/pending/completed/warning）
- `widgets/casting_step_status.dart` — 状态徽标 + chevron
- `widgets/casting_generate_step.dart` — 生成步骤（locked/ready/completed/warning）
- `widgets/casting_context_strip.dart` — 流程上下文条（规则包/探针/已完成 x/5）

### 新增 / 修改
- `lib/app/navigation/guayan_main_tab_bar.dart`（新增）— XYUI 底部导航 + 五图标 CustomPainter
- `lib/app/navigation/main_tabs.dart` — MainTab 增加 iconBuilder（XYUI 图标）
- `lib/app/app_shell.dart` — NavigationBar → GuayanMainTabBar；排卦页无全局 AppBar
- `lib/app/more_menu.dart` — 支持自定义 icon
- `lib/presentation/casting/casting_page.dart` — 重写为流程轨页面（状态机：推进/生成/需重新生成/探针）
- `test/foundation_test.dart` — 适配新 UI（XYUI 导航/排卦流程轨/探针 Key/三点更多）
- `test/presentation/casting/casting_page_test.dart`（新增）— 工作流状态测试

### 说明
- 状态进入真实 State（CastingStepState），不从颜色反推；已完成步骤可重新进入，
  生成后修改关键数据 → 生成步骤标记「需重新生成」（不清空已填内容）。
- 原「状态探针：0」孤立文本移除，探针语义保留在 Context Strip（可点击递增）。
- 验证：flutter test 63/63 通过；analyze 本轮文件 0 issue；debug 构建通过。

---

## 未发布变更 — 2026-05-26

### 修复
- **错题回炉初始化**：`MistakeStore` 新增显式 `init()`，应用启动时真正等待 SharedPreferences 数据加载，避免首页/练习/回炉首次读取错题数量为空。
- **连连看构建错误**：修复 `LinkMatchGamePage` HUD 中动态错误数使用 `const TextStyle` 导致的编译失败。

### 修改文件
- `lib/main.dart` — 启动时调用 `MistakeStore.instance.init()`。
- `lib/services/mistake_store.dart` — 暴露初始化入口，保留同步 `all` 读取缓存。
- `lib/pages/practice/games/link_match_game_page.dart` — 修复动态 HUD 样式的 const 使用。
- `file-tree.md` — 更新最后编辑时间、未发布变更和相关职责说明。

---

## 未发布更新日志（远端合并）

### 新增
- **五行意象学习页**：`WuxingImageryPage` — 五行知识总卡 + 颜色、五味、脏腑、方位、品质、数字、四季、地支五行分板块意象
- **八卦学习页**：`BaguaStudyPage` — 八卦产生、歌诀、知识总卡、八卦分卡、病象折叠与文王卦使用提示

### 修改
- **学习入口命名**：`五行生克` 改为 `五行模块`
- **学习入口扩展**：新增 `八卦模块`，位于五行模块之后、十二地支之前
- **五行模块目录**：拆分 `五行颜色` 与 `五行意象`，后续相生、相克、以我为中心顺延
- **五行颜色页**：下一步跳转改为进入 `五行意象`

---

## 当前版本更新日志 — v0.1.10

> 发布日期：2026-05-22 · [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.10)

### 新增
- **关系连连看游戏**：`LinkMatchGamePage` — 25 组配对 / 50 张卡牌消除模板
- **`PracticeMode.linkMatch`**：第三种练习模式
- **`HitEffectKind` / `FallingRuleKind`** 枚举：为后续地支合/冲预留

### 游戏规则
- 上方源牌 25 张 + 下方目标牌 25 张，各自打乱
- 点击源牌 → 高亮 → 点击目标牌完成配对
- 正确：❤️/⚡ 反馈 + 两张牌消除消失 + 加分连击
- 错误：扣命 + 显示正确答案 + 写入回炉
- 默认 5 条命，全部配完或命用完 → 结果页

### 新增文件
- `lib/pages/practice/games/link_match_game_page.dart` — 连连看游戏主页面

### 修改文件
- `lib/models/practice/practice_enums.dart` — PracticeMode.linkMatch + HitEffectKind + FallingRuleKind
- `lib/pages/practice/practice_setup_page.dart` — 新增连连看模式选择与跳转
- `lib/pages/practice/practice_result_page.dart` — 新增 matchedCount/totalPairs 参数
- `lib/pages/practice/practice_page.dart` — 趣味游戏区增加连连看入口
- `lib/utils/practice_labels.dart` — PracticeStage 增加 linkMatch
- `lib/theme/wuxing_colors.dart` — 金颜色优化

---

## 前版更新日志 — v0.1.9

> 发布日期：2026-05-22 · [GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.9)

### 新增
- **方块速答游戏**：通用单方块下落模板 `FallingBlockGamePage`
- **`PracticeMode.fallingBlock`**：正式启用方块速答模式
- **`PracticeSetupPage` 模式选择**：普通练习 / 方块速答 二选一切换
- **`PracticeResultPage` 游戏统计**：新增 `score` / `maxCombo` / `remainingLives` 可选显示
- **错题写入**：答错/漏掉统一走 `MistakeStore.addOrUpdateMistake`，漏掉显示"未作答"

### 游戏规则
- 题目方块从上往下掉，点击底部正确答案
- 答对：得分 +10+连击，连击递增
- 答错：生命 -1，连击清零，写入回炉
- 漏掉：生命 -1，标记超时，写入回炉
- 基础下落 4500ms，每 5 连击加速 250ms，最低 2200ms
- 题目用完或生命归零 → 结果页

### 新增文件
- `lib/pages/practice/games/falling_block_game_page.dart` — 打方块游戏主页面

### 修改文件
- `lib/models/practice/practice_enums.dart` — PracticeMode 增加 fallingBlock
- `lib/pages/practice/practice_setup_page.dart` — 增加模式选择与跳转
- `lib/pages/practice/practice_result_page.dart` — 增加游戏统计字段

---

**卦眼训练器** 是断卦基本功训练 App，用于训练五行生克、地支、六冲六合等基础知识。

当前技术栈：

| 类型 | 技术 |
| --- | --- |
| 前端框架 | Flutter 3.x |
| 语言 | Dart 3.x |
| 目标平台 | Android |

核心训练闭环：学习 → 练习 → 出错/迟疑 → 回炉 → 再练习。

---

## 2. 顶层目录结构

```text
guayan_trainer/
├── .claude/                # AI 协作规则
├── android/                # Android 原生壳
├── assets/                 # 随包资源（assets/calendar/ = 年度历法数据包）
├── lib/                    # 主程序源码
├── memory/                 # 记忆与反馈记录
├── scripts/                # 开发辅助脚本（本机 flutter 包装）
├── test/                   # 测试
├── tool/                   # 开发阶段工具（不参与 App 运行时）
├── uploads/                # 参考资料（开发计划、组件文档）
├── 五行相克特效/            # 相克 HTML 动画原型（5 个）
├── 五行相生特效/            # 相生 HTML 动画原型（5 个）
├── AGENTS.md               # 项目代码规则（AI 自动遵守）
├── CHANGELOG.md            # 文件审计与变更日志
├── file-tree.md            # 项目结构说明文档
└── pubspec.yaml            # Flutter 依赖配置
```

---

## 3. lib 目录结构

```text
lib/
├── main.dart               # 应用入口
├── app.dart                # MaterialApp 主题配置
├── app/                    # 2.0 应用壳（GuayanApp / AppShell / 导航）
├── core/                   # 2.0 常量
├── domain/                 # 2.0 领域层（DOMAIN + R3 排盘引擎 + R3-B 历法层）
├── application/            # 2.0 用例层（预留）
├── presentation/           # 2.0 五个主页面 + 规则库/设置/关于
├── shell/                  # 旧导航壳（1.0 遗留）
├── theme/                  # 颜色系统
├── data/                   # 数据层：纯数据映射与常量
├── models/                 # 模型层：类型定义
├── services/               # 服务层：业务逻辑
├── pages/                  # 页面层：按功能分子目录（1.0 遗留）
└── widgets/                # 组件层：可复用组件（1.0 遗留）
```

---

## 4. 模块职责说明

| 模块 | 职责 | 是否依赖 Flutter/Widget |
| --- | --- | --- |
| `theme/` | 五行颜色系统、主题色常量 | 是（Color） |
| `shell/` | 底部导航壳、页面切换 | 是 |
| `data/` | 数据表、常量、纯映射（五行/地支/冲合） | 否 |
| `models/` | 类型定义、数据结构 | 否 |
| `services/` | 出题引擎、错题存储 | 否 |
| `pages/` | 页面组件与用户交互 | 是 |
| `widgets/` | 可复用 UI 组件 | 是 |

---

## 5. 关键文件职责

### 5.1 根目录

| 文件 | 职责 |
| --- | --- |
| `pubspec.yaml` | 项目元信息、依赖声明与 flutter 配置 |
| `file-tree.md` | 项目文件树与模块说明文档 |

### 5.2 .claude/

| 文件 | 职责 |
| --- | --- |
| `CLAUDE.md` | AI 协作规则：文件组织、架构分层、命名规范、文档纪律 |

### 5.3 lib/

| 文件 | 职责 |
| --- | --- |
| `main.dart` | 应用入口，初始化错题缓存后调用 `runApp` 启动 `GuayanTrainerApp` |
| `app.dart` | MaterialApp 组装，配置古风主题色系，home 指向 `MainShell` |

### 5.3.1 lib/domain/（2.0 领域层）

| 文件 | 职责 |
| --- | --- |
| `hexagram_case.dart` | 卦例持久化根对象：id / question / createdAt / lines[6] |
| `line_state.dart` | 一爻状态：爻位 / 动静（老阴老阳发动）/ 所值地支 |
| `line_endpoint.dart` | 关系端点稳定身份：卦侧（original/changed）+ 爻位（1..6） |
| `relation_type.dart` | 关系类型枚举 + 方向类别 + 展示名 + 系统 RuleId 常量 |
| `relation_key.dart` | 关系稳定语义 key（Stable Relation Identity 核心） |
| `relation_instance.dart` | 一条具体关系实例（身份以 key 为准，可重算重建） |
| `relation_calculator.dart` | 最小确定性关系计算：动变 / 六冲 / 六合 |
| `relation_note.dart` | 关系笔记实体（caseId + RelationKey 绑定） |
| `relation_note_store.dart` | 笔记绑定存储：纯内存 + JSON 导入导出 |
| `README.md` | 领域设计与 Stable Relation Identity 说明 |
| `wu_xing.dart` | 五行 + 生克；`relationTo(self)` 为六亲判定唯一入口（R3） |
| `di_zhi.dart` | 十二地支：五行 / 阴阳 / 六冲 / 六合（R3） |
| `tian_gan.dart` | 十天干：五行 / 阴阳 / 六十甲子取干（R3） |

### 5.3.2 lib/domain/casting/（R3 排盘引擎）

| 文件 | 职责 |
| --- | --- |
| `bagua.dart` | 八卦（三爻自下而上）+ 卦符 + 五行 + 先天序 |
| `najia.dart` | 纳甲表（干支）：乾纳甲壬、坤纳乙癸；内外卦分别装卦 |
| `palace.dart` | 京房八宫卦序 + 世应（算法生成，非硬编码 64 条） |
| `hexagram_names.dart` | 六十四卦名表（上卦 × 下卦） |
| `hexagram64.dart` | 六爻阴阳 → 卦名 / 宫位 / 世应 |
| `six_relative.dart` | 六亲（以宫位五行为「我」） |
| `six_spirit.dart` | 六神（按日干起例，自初爻向上顺排） |
| `cast_chart.dart` | 排盘结果模型（CastLine / CastChart） |
| `casting_engine.dart` | 引擎组装：本卦 / 变卦 / 动变 / 纳甲 / 世应 / 六亲 / 六神 |

### 5.3.3 lib/domain/calendar/（R3-B 离线历法层）

| 文件 | 职责 |
| --- | --- |
| `calendar_engine.dart` | 历法引擎：聚合月建 / 日辰 / 旬空 |
| `calendar_request.dart` | 输入契约：localDateTime + utcOffset + dayBoundaryRule |
| `calendar_context.dart` | 输出契约：完整历法上下文（不允许半成品） |
| `calendar_error.dart` | 类型化失败：InvalidCalendarDate / CalendarDataMissing / PackInvalid / RevisionRejected |
| `day_boundary_rule.dart` | 日界规则：midnight / ziHourStart，无隐式默认值 |
| `day/ganzhi_day.dart` | 日柱：儒略日序 → 六十甲子（锚点 1949-10-01 甲子日） |
| `day/xun_kong.dart` | 旬空：由旬首推导，不维护手抄表 |
| `solar_term/solar_term_id.dart` | 二十四节气 + 太阳黄经 + 节/气区分 |
| `solar_term/solar_term.dart` | 节气记录（真源为「瞬间」而非日期） |
| `solar_term/solar_term_provider.dart` | 节气来源抽象（可替换边界） |
| `solar_term/calendar_year_data.dart` | 已校验的单年历法数据 |
| `solar_term/month_branch_resolver.dart` | 月建：十二「节」区间判断（与公历月无关） |
| `import/calendar_data_pack.dart` | 数据包原始形态（字段可空，交由校验器汇总） |
| `import/calendar_data_pack_parser.dart` | JSON → 数据包（只负责语法与结构） |
| `import/calendar_data_pack_terms.dart` | 节气列表规则：数量 / 唯一 / 递增 / 年份合理性 |
| `import/calendar_data_pack_validator.dart` | 元数据校验 + 一次性汇总全部失败原因 |
| `import/calendar_data_pack_importer.dart` | 解析→校验→修订判定→**原子提交** |
| `store/calendar_data_store.dart` | 本地仓储边界 + 内存实现 |
| `store/stored_solar_term_provider.dart` | 仓储 → Provider（异步装载快照，引擎保持同步） |

### 5.3.4 lib/presentation/review/（2.0 审卦工作台）

| 文件 | 职责 |
| --- | --- |
| `review_page.dart` | 审卦工作台组装（§3 布局：BasicInfo → ShenSha → FourPillars → Header → Table → Focus） |
| `review_page_state.dart` | 纯 Dart 状态模型（§7 全部字段，未接入字段显式 nullable） |
| `review_case_adapter.dart` | HexagramCase + 传统档案 → ReviewPageState；焦点关系来自 Domain 计算 |
| `review_demo_data.dart` | 视觉定稿演示数据（SVG 逐项转录） |
| `widgets/review_app_bar.dart` | 顶栏（返回 chevron + 审卦 + 排盘结果） |
| `widgets/review_basic_info_card.dart` | 基本信息卡（方式/事项/阳历/阴历 + 已生成） |
| `widgets/review_shensha_card.dart` | 神煞卡（Wrap 标签网格，数据驱动） |
| `widgets/review_four_pillars_strip.dart` | 四柱条（年/月/日/时/旬空，soft 底 44 高） |
| `widgets/review_hexagram_result_table.dart` | 完整卦盘组件（内嵌主/变卦标题 + 六行排盘 + 表尾） |
| `widgets/review_hexagram_line_row.dart` | 六爻单行（11 列冻结，六亲地支/纳音拆两行无省略号，可点高亮） |
| `widgets/review_line_detail_sheet.dart` | 点爻 Bottom Sheet（关系列表/规则依据/备注/进入关系页） |

### 5.3.5 lib/presentation/shared/（2.0 共享爻组件，排卦/审卦强制复用）

| 文件 | 职责 |
| --- | --- |
| `yao_glyph.dart` | 统一爻槽 24×6（yang/yin/voidYao，仅内部填充不同） |
| `moving_marker.dart` | 动爻标记 12×12（老阴 ○ / 老阳 ×，Bounding Box 一致） |

### 5.4 lib/shell/

| 文件 | 职责 |
| --- | --- |
| `main_shell.dart` | 底部四栏导航（首页/学习/练习/回炉），`IndexedStack` 页面保持 |

### 5.5 lib/theme/

| 文件 | 职责 |
| --- | --- |
| `wuxing_colors.dart` | 五行主色 + 浅底色映射，地支→五行→颜色查询，文字对比色计算 |

### 5.6 lib/data/

| 文件 | 职责 |
| --- | --- |
| `wuxing_data.dart` | 五行列表 + 相生相克映射表 + 反向查询 |
| `wuxing_self_center_data.dart` | 以我为中心关系映射 + 旺相休囚死 |
| `dizhi_data.dart` | 十二地支结构化数据：五行、阴阳、方位、月份 |
| `relation_data.dart` | 六冲六合映射 + 双端查询 + 关系判定 |
| `training_question.dart` | 2.0 训练数据模型：TrainingModule / RelationType / TrainingQuestion |
| `wuxing_questions.dart` | 五行生克题库：相生 5 题 + 相克 5 题 |
| `practice/wuxing_practice_question_generator.dart` | 通用题库生成器：四类五行题库混合出题 |

### 5.7 lib/models/

| 文件 | 职责 |
| --- | --- |
| `mistake_item.dart` | 错题记录模型，持久化 JSON 序列化 |
| `training_question.dart` | 题目类型枚举（8 种）+ 题目数据类 |
| `training_result.dart` | 单题作答记录 + 训练会话统计（正确率/回炉/迟疑） |
| `practice/practice_enums.dart` | 通用练习枚举，Domain / Topic / AnswerKind / Stage |
| `practice/practice_question.dart` | 通用题目模型 |
| `practice/practice_answer_record.dart` | 答题记录 + 会话统计 + 分项统计 |

### 5.8 lib/services/

| 文件 | 职责 |
| --- | --- |
| `question_generator.dart` | 出题引擎：5 种训练模式 × 8 种题型随机生成 |
| `mistake_store.dart` | 错题回炉存储器：启动初始化、收录答错/迟疑，标记已会后移除 |

### 5.9 lib/utils/

| 文件 | 职责 |
| --- | --- |
| `practice_labels.dart` | 通用练习中文标签、题库容量、时间格式化函数 |

### 5.10 lib/pages/home/

| 文件 | 职责 |
| --- | --- |
| `home_page.dart` | 学习仪表盘：标题说明 + 学习状态卡 + 回炉提醒 + 快捷入口 |

### 5.11 lib/pages/study/

| 文件 | 职责 |
| --- | --- |
| `study_page.dart` | 学习页入口：五行模块/八卦模块/十二地支/六冲六合四张学习卡片 |
| `bagua_study_page.dart` | 八卦模块详情页：八卦产生、歌诀、知识总卡、分卡、病象与文王卦提示 |
| `wuxing_study_menu_page.dart` | 五行模块目录页：颜色、意象、生克、以我为中心导航卡片 + 综合练习 + 学习建议 |
| `wuxing_color_page.dart` | 五行颜色详情页：颜色卡片、对照表、记忆提示，下一步进入五行意象 |
| `wuxing_imagery_page.dart` | 五行意象详情页：五行知识总卡 + 颜色/五味/脏腑/方位/品质/数字/四季/地支五行分板块 |
| `wuxing_generate_page.dart` | 五行相生（占位：即将开放） |
| `wuxing_control_page.dart` | 五行相克学习页：五角星图、关系解释、断卦提示 |
| `wuxing_center_page.dart` | 以我为中心学习页：五行选择 + 关系图 + 旺相休囚死 |
| `dizhi_study_page.dart` | 地支学习详情：地支彩色网格、五行归类、地支分类 |
| `relation_study_page.dart` | 六冲六合学习详情：冲合对展示、跳转练习 |

### 5.12 lib/pages/practice/

| 文件 | 职责 |
| --- | --- |
| `practice_page.dart` | 练习页入口：按基础/关系/综合分组展示训练卡片 |
| `training_page.dart` | 训练页：题目展示 + 彩色选项 + 即时反馈 + 进度条 |
| `result_page.dart` | 结果页：正确率 + 回炉/迟疑汇总 + 错题列表 + 继续操作 |
| `practice_setup_page.dart` | 综合练习设置页：选择板块 + 题数 + 练习方式 |
| `practice_session_page.dart` | 通用练习页：计时 + 反馈 + 回炉写入 |
| `practice_result_page.dart` | 通用结果页：分项表现 + 平均反应 + 迟疑统计 |
| `games/falling_block_game_page.dart` | 方块速答游戏：单题下落 + 生命/分数/连击 + 回炉 |
| `games/link_match_game_page.dart` | 关系连连看：25组配对 + 50张卡牌消除 + 回炉 |

### 5.13 lib/pages/review/

| 文件 | 职责 |
| --- | --- |
| `review_page.dart` | 回炉页：错题列表 + 单题重做 + 重做全部错题 |
| `review_training_page.dart` | 回炉练习页：无色单选重做，答对移除答错保留 |

### 5.14 lib/widgets/

| 文件 | 职责 |
| --- | --- |
| `wuxing_wheel.dart` | 五行轮盘组件：累计箭头动画、自动循环、节点高亮、中央特效 |
| `wuxing_arrow_painter.dart` | 圆弧箭头 CustomPainter：沿轮盘圆周绘制相生弧线 |
| `wuxing_control_wheel.dart` | 五行相克轮盘：五角星累计箭头 + 五槽位特效自播 |
| `wuxing_control_arrow_painter.dart` | 五角星直线箭头 CustomPainter：跨节点红色克制线 |
| `wuxing_control_painter.dart` | 静态相克五角星 CustomPainter |
| `wuxing_self_center_wheel.dart` | 以我为中心圆盘：中心+四向外圈节点 |
| `wuxing_self_center_painter.dart` | 四向箭头 + 中心双环 CustomPainter |
| `effects/control/earth_water_control_html.dart` | 土克水 HTML/SVG 动画，土堤束水 |
| `effects/control/fire_metal_control_html.dart` | 火克金 HTML/SVG 动画，烈火熔金 |
| `effects/control/metal_wood_control_html.dart` | 金克木 HTML/SVG 动画，金刃断木 |
| `effects/control/water_fire_control_html.dart` | 水克火 HTML/SVG 动画，水幕压火 |
| `effects/control/wood_earth_control_html.dart` | 木克土 HTML/SVG 动画，木根破土 |
| `effects/control/control_relation_effect.dart` | 相克 HTML WebView 封装 |
| `effects/control/control_relation_effects_layer.dart` | 五相克槽位关系动画层 |
| `effects/earth_metal_html.dart` | 土生金 HTML/SVG 动画，金石破土而出 |
| `effects/fire_earth_html.dart` | 火生土 HTML/SVG 动画，灰烬掩埋火苗循环 |
| `effects/generate_relation_effects_layer.dart` | 五槽位关系动画层：固定坐标渲染多条关系动画 |
| `effects/html_relation_effect.dart` | WebView 封装组件，IgnorePointer 防拦截，支持全部五条相生 |
| `effects/metal_water_html.dart` | 金生水 HTML/SVG 动画，寒风凝水珠滴落 |
| `effects/water_wood_html.dart` | 水生木 HTML/SVG 动画，春雨润木发芽繁茂 |
| `effects/wood_fire_html.dart` | 木生火钻木取火 HTML/SVG 动画 |

### 5.15 test/

| 文件 | 职责 |
| --- | --- |
| `widget_test.dart` | Widget 冒烟测试：首页正确渲染 |
| `foundation_test.dart` | App Shell 五导航 / 艮卦图标 / 状态保持 / 更多菜单验收 |
| `presentation/casting/casting_page_test.dart` | 排卦工作台测试（Test A–D / 行顺序 / 草稿仓库 / 纯逻辑 / UI-01~03） |
| `presentation/review/review_page_test.dart` | 审卦工作台测试（§22 A–H / UI-04~08 / 适配器 / 双数据路径） |
| `presentation/shared/yao_glyph_test.dart` | 共享爻组件尺寸冻结测试（24×6 / 12×12） |
| `domain/casting/hexagram_tables_test.dart` | R3 表与规则：八卦/64 卦唯一性/八宫世应/纳甲/六亲/六神 |
| `domain/casting/casting_engine_test.dart` | R3 引擎：经典排盘对照（乾为天/坤为地/泽山咸）+ 动变 |
| `domain/calendar/ganzhi_day_test.dart` | R3-B 日柱：13 个跨年代基准（双独立源校验） |
| `domain/calendar/xun_kong_test.dart` | R3-B 旬空：六旬 + 60 日循环 + 独立性质验证 |
| `domain/calendar/day_boundary_test.dart` | R3-B 日界：两种规则 × 四个关键时刻 |
| `domain/calendar/month_branch_resolver_test.dart` | R3-B 月建：十二「节」× 三时点边界 |
| `domain/calendar/calendar_data_pack_parser_test.dart` | R3-B 数据包解析 |
| `domain/calendar/calendar_data_pack_validator_test.dart` | R3-B 数据包校验（数量/唯一/时间/来源/年份） |
| `domain/calendar/calendar_pack_import_test.dart` | R3-B 导入原子性 Golden + 修订四态 |
| `domain/calendar/calendar_engine_test.dart` | R3-B 引擎综合 Golden + 缺年份拒绝 |
| `domain/calendar/offline_gate_test.dart` | R3-B 离线门禁（无网络 / 无 Flutter / 无 DateTime.now） |
| `domain/calendar/calendar_pack_fixtures.dart` | R3-B 测试夹具（构造数据包 + 读取种子包） |

---

## 6. 模块依赖方向

```text
theme/  data/  ←  models/  ←  services/  ←  pages/  +  widgets/
                                                    ←  shell/
```

依赖约束：

1. `data/`、`theme/` 不依赖任何上层模块。
2. `models/` 不依赖任何上层模块。
3. `services/` 可以依赖 `data/` 与 `models/`，但不能依赖 Flutter Widget。
4. `pages/` 可以依赖 `services/`、`models/`、`data/`、`theme/`。
5. `shell/` 可以依赖所有页面模块。
6. `widgets/` 只依赖 `models/`。
7. 禁止循环依赖。
8. 禁止在页面组件中写复杂业务逻辑（出题、计分、错题管理）。

---

## 7. 当前架构原则

### 7.1 分层原则

```text
数据定义 → 主题系统 → 业务逻辑 → 状态管理 → UI 页面
```

| 层级 | 说明 |
| --- | --- |
| 数据定义 | 五行生克映射、地支信息、冲合关系 |
| 主题系统 | `WuxingColors` 颜色体系 |
| 业务逻辑 | 出题算法、计时判定、错题收录 |
| 状态管理 | `MistakeStore` 单例管理错题状态 |
| UI 页面 | 四栏导航 + 5 个子页面区 |

### 7.2 当前不做的内容

当前版本暂不开发：

- 地支圆盘可视化组件；
- 三合三会数据与训练；
- 天干数据与训练；
- 纳音五行；
- 六十四卦；
- 统计图表与学习曲线；
- 多用户/多设备同步。

---

## 8. 版本历史

| 版本 | 日期 | 类型 | 说明 |
| --- | --- | --- | --- |
| `v0.1.10` | 2026-05-22 | 新增 | 关系连连看：25组配对+50张卡消除+回炉 |
| `v0.1.9` | 2026-05-22 | 新增 | 方块速答游戏模板，单题下落 + 计时 + 回炉 |
| `v0.1.8.3` | 2026-05-18 | 重构 | 旧入口迁移到通用练习框架，经典按钮备份 |
| `v0.1.7.2` | 2026-05-18 | 优化 | 圆盘排版精修，箭头避让，胶囊节点 |
| `v0.1.7.1` | 2026-05-18 | 重构 | 以我为中心升级圆盘结构，四色箭头 |
| `v0.1.7` | 2026-05-18 | 新增 | 以我为中心学习页，旺相休囚死 |
| `v0.1.6.2` | 2026-05-18 | 优化 | 轮盘尺寸稳定，结果页三阶段统计，回炉来源标签 |
| `v0.1.6.1` | 2026-05-16 | 修复 | 答题前隐藏提示，答题后显示特效 |
| `v0.1.5` | 2026-05-16 | 新增 | 五行相克学习页，wrongCount 修复，回炉弹窗，阶段标签 |
| `v0.1.4.2` | 2026-05-16 | 修复 | 金元素灰色文字，答题反馈色通用化 |
| `v0.1.4.1` | 2026-05-16 | 新增 | 回炉错题重做系统，持久化存储 |
| `v0.1.4` | 2026-05-16 | 新增 | 相生练习三阶段：轮盘→彩色单选→无色单选 |
| `v0.1.3.13` | 2026-05-16 | 优化 | 箭头 3500ms 对齐 5s 特效，一轮 25 秒 |
| `v0.1.3.12` | 2026-05-16 | 优化 | 箭头 1800ms、火生土纯 CSS 版修复 viewBox |
| `v0.1.3.11` | 2026-05-16 | 新增 | 全部五条相生 HTML 动画接入，轮盘还原慢速 |
| `v0.1.3.10` | 2026-05-16 | 优化 | 轮盘加速至 5 秒一轮 |
| `v0.1.3.9` | 2026-05-16 | 变更 | 木生火替换为钻木取火动画 |
| `v0.1.3.8` | 2026-05-16 | 新增 | 火生土 HTML 动画，HtmlRelationEffect 泛化 |
