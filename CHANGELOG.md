# 卦眼训练器 — 文件审计与变更日志

> **仓库：** https://github.com/Heaifan/guayan_trainer.git
> **归档分支：** `feat/guayan-2.0`
> **最近正式发布：** v0.1.10（2026-05-22）
> **本文件创建：** 2026-08-27
> **完整文件树与历史：** 见 [file-tree.md](file-tree.md)

---

## 2026-08-31 · GUAYAN-2.0-REVIEW-ONSCREEN（审卦一屏版收口，未发布）

> 整体收口：一屏先看完整基本信息 + 四柱 + 4×4 神煞 + 完整卦盘；
> 「关系焦点」不再常驻大卡，改点某一爻 → 高亮 → Bottom Sheet（关系列表/规则依据/
> 关系备注/进入关系页）。卦盘彻底取消省略号（六亲地支与纳音拆两行）。

### 审卦页
| 路径 | 说明 |
| --- | --- |
| `review_page.dart` | 一屏布局重排；删除常驻关系焦点卡；点爻高亮 + 弹层；onOpenRelations |
| `review_basic_info_card.dart` | 紧凑单卡（问事/方式 chip/公历/农历/meta） |
| `review_four_pillars_strip.dart` | soft 底 44 高 + teal/warm 双色 + 旬空右对齐 |
| `review_shensha_card.dart` | chip 20 高紧凑 4×4 |
| `review_hexagram_result_table.dart` | 表头 + 行点击透传 + 新表尾提示 |
| `review_hexagram_line_row.dart` | 六亲地支/纳音拆两行、无省略号；11 列固定槽位；可点高亮 |
| `review_line_detail_sheet.dart`（新增） | 点爻弹层：当前爻 + 关系列表 + 规则依据 + 备注(GAP) + 进关系页 |
| 删除 `review_relation_focus_card.dart` | — |
| `review_page_state.dart` / `review_case_adapter.dart` | allRelations / relationsInvolving / relationLabel |
| `review_demo_data.dart` | 对齐一屏版 SVG（问事/09:30/七月十八 · 巳时/申酉空） |

### 排卦页
| 路径 | 说明 |
| --- | --- |
| `line_editor_sheet.dart` | 爻象选项卡 mainAxisExtent 58 固定（≥58 DIP 硬门禁），修复 BOTTOM OVERFLOWED 1.2px |

### Token / 共享
- `casting_tokens.dart`：gua #927848、pillarTeal #4F8685、新增 pillarWarm #A8605C
- `shared/yao_glyph.dart` / `moving_marker.dart`：描边宽度按一屏版 SVG 微调

### 测试
- `review_page_test.dart`：一屏版适配 + 点爻弹层（关系列表 / 进入关系页回调）+ 窄屏 360 无溢出
- `casting_page_test.dart`：新增「爻象弹层窄屏 360×640 无 RenderFlex 溢出」
- `foundation_test.dart`：审卦分支断言改为 神煞
- 验证：flutter test 102/102 通过；analyze 本轮文件 0 issue；debug APK 构建通过。

---

## 2026-08-30 · GUAYAN-2.0-UI-CORRECTION-R2（排卦 + 审卦增量修正，未发布）

> 在 R1 已定稿基础上做增量修正：删排卦顶部草稿摘要卡、起卦时间显示公历+农历、
> 六爻录入行统一 52 DIP、神煞固定 4 列、最终卦盘组件（内嵌主/变卦标题）、
> 统一爻槽 24×6（阳/阴/空亡仅内部填充不同）、动爻标记 12×12、文本不得压爻。

### 新增（lib/presentation/shared/ — 排卦/审卦强制复用）
| 路径 | 说明 |
| --- | --- |
| `yao_glyph.dart` | 统一爻槽 24×6：yang 实心 / yin 左右断线 / voidYao 空心描边 rx1 #7E9098 w1.5 |
| `moving_marker.dart` | 动爻标记 12×12：老阴 ○ #A17F45 / 老阳 × #567866，Bounding Box 一致 |
| `test/presentation/shared/yao_glyph_test.dart` | 共享组件尺寸冻结测试（UI-05/06 组件级） |

### 排卦页
| 路径 | 说明 |
| --- | --- |
| `casting_page.dart` | 删除 CastingDraftContext（§1.1） |
| `casting_time_row.dart` | 重写：88 高，公历 + 农历 + 右上状态 chip（§2 SVG） |
| `casting_page_state.dart` | 新增 lunarPlaceholder（GAP：农历换算待接入，presentation mock） |
| `six_yao_input_row.dart` | 普通行 = 编辑行 = 52 DIP（§3）；迁移共享 YaoGlyph |
| `line_editor_sheet.dart` | 迁移共享 YaoGlyph + MovingMarker |
| 删除 `casting_draft_context.dart`、旧 `casting/widgets/yao_glyph.dart` | — |

### 审卦页
| 路径 | 说明 |
| --- | --- |
| `review_page_state.dart` | 伏神拆两列（hiddenSpirit1/2）+ isVoid（主卦/变卦）；纳音改半角括号 |
| `review_case_adapter.dart` / `review_demo_data.dart` | 伏神两列 + isVoid 透传；按 SVG #12：五爻丁酉、三爻丙申空亡 |
| `review_shensha_card.dart` | 神煞固定 4 列数据驱动网格（§5，>16 项继续加行） |
| `review_hexagram_result_table.dart` | 最终卦盘组件：内嵌【主卦】/【变卦】标题 + 六行排盘 + 表尾（§6/§12） |
| `review_hexagram_line_row.dart` | 11 列冻结布局：六神/伏神×2/主变卦文字/爻槽(24×6)/世应/动爻(12×12)/箭头；文本 Ellipsis 不压爻（§11） |
| `review_page.dart` | 移除 HexagramResultHeader（避免标题重复渲染） |
| 删除 `review_hexagram_result_header.dart` | — |

### 测试
- `casting_page_test.dart`：UI-01（无 DraftContext）/ UI-02（公历+农历）/ UI-03（行高 52 一致）
- `review_page_test.dart`：UI-04（神煞 4 列）/ UI-05（爻槽 24×6）/ UI-06（动爻 12×12）/
  UI-07（超长文本不压爻）/ UI-08（变卦爻槽+变卦世应同显）+ R1 测试适配
- `foundation_test.dart`：审卦分支断言改为【主卦】

### GAP / 偏差
- 农历为 presentation mock（lunarPlaceholder），真实换算待排盘引擎接入；
- 空亡 isVoid 仅 UI 表现（演示档案提供），Widget 不计算旬空；
- 演示 pos2（老阳）按语义渲染阳槽 + X，SVG #12 画作阴+X（有意修正，保持阴阳语义一致）。
- 验证：flutter test 100/100 通过；analyze 本轮文件 0 issue；debug APK 构建通过。

---

## 2026-08-30 · GUAYAN-2.0-REVIEW-UI-R1（审卦页 XYUI 工作台定稿实施，未发布）

> **审卦页最终视觉**：按人工定稿总 SVG 把「审卦」占位页实现为 XYUI 长页排盘工作台
> （BasicInfo → ShenSha → FourPillars → HexagramHeader → HexagramTable → RelationFocus）。
> 传统排盘字段由演示档案提供（排盘引擎 R3 前不造假算法）；真实卦例经 App Shell
> `onGenerated` 桥接接入，六爻/地支/关系焦点全部来自现有 Domain。

### 新增（lib/presentation/review/）
| 路径 | 说明 |
| --- | --- |
| `review_page.dart`（重写） | 审卦工作台组装（§3 布局） |
| `review_page_state.dart` | 纯 Dart 状态模型（§7 全部字段，未接入字段显式 nullable） |
| `review_case_adapter.dart` | HexagramCase + 传统档案 → ReviewPageState；焦点关系来自 calculateRelations |
| `review_demo_data.dart` | 视觉定稿演示数据（泽山咸→泽水困 / 16 神煞 / 丙午年…丁酉时 / 六神伏神六亲纳音世应） |
| `widgets/review_app_bar.dart` | 顶栏（返回 chevron + 审卦 + 排盘结果，§1） |
| `widgets/review_basic_info_card.dart` | 基本信息卡（§2） |
| `widgets/review_shensha_card.dart` | 神煞独立卡片 + 自适应 Wrap 网格（§3/§8） |
| `widgets/review_four_pillars_strip.dart` | 四柱条：年/月/日/时/旬空（§4/§9） |
| `widgets/review_hexagram_result_header.dart` | 排盘结果头 + 主/变卦标题（§5） |
| `widgets/review_hexagram_result_table.dart` | 六爻排盘主体表（§6，上爻在上初爻在下） |
| `widgets/review_hexagram_line_row.dart` | 六爻单行（六神/主卦含伏神/变卦 + 矢量爻象 + 世应/动爻） |
| `widgets/review_relation_focus_card.dart` | 关系焦点卡（§7/§13，规则依据跳转规则库） |
| `test/presentation/review/review_page_test.dart` | §22 Test A–H + 适配器/焦点关系/双数据路径 |

### 修改
| 路径 | 说明 |
| --- | --- |
| `lib/presentation/casting/casting_tokens.dart` | 补充 §4 Token：relationRed / relationBlue / traditionalGold / pillarTeal |
| `lib/presentation/casting/casting_page.dart` | 新增可选 `onGenerated` 回调（生成后通知 Shell） |
| `lib/app/app_shell.dart` | 审卦页隐藏全局 AppBar（自带 XYUI TopBar）；`_latestCase` 桥接排卦结果 |
| `test/foundation_test.dart` | 审卦分支断言适配（无全局 AppBar + 完整排盘/关系焦点） |

### GAP（本轮如实标注）
- 六神/伏神/六亲/神煞/四柱/卦名/纳音：排盘引擎（R3）落地前仅演示档案提供，
  真实卦例下显式置空，不做假六爻算法；
- 世应/生克/回头生回头克：关系规则属 R3/R4，本轮仅入口（RelationFocusCard chips）；
- 排卦页「查看审卦 ›」入口导航仍为视觉态（后续轮次接通）。
- 验证：flutter test 84/84 通过；analyze 本轮文件 0 issue（21 条旧代码告警未动）；
  debug APK 构建通过。

---

## 2026-08-30 · GUAYAN-2.0-CASTING-UI-R1（排卦页 XYUI 工作台定稿实施，未发布）

> **排卦页最终视觉**：废弃「方案 2 纵向流程轨」，按人工拍板的总 SVG 改为
> 排卦工作台 —— 1 起卦时间 → 2 问事信息 → 3 六爻录入 → 4 规则包 → 5 生成排盘。
> 本轮为视觉骨架 + 状态组件 + 必要交互基础；不做审卦页重构、关系引擎、完整规则 CRUD。

### 新增（lib/presentation/casting/widgets/）
| 路径 | 说明 |
| --- | --- |
| `casting_app_bar.dart` | 顶栏（卦眼 / 排卦 / 三点更多，§5.1） |
| `casting_draft_context.dart` | 草稿上下文卡（草稿中，§5.2） |
| `casting_time_row.dart` | 起卦时间第一行（§5.3，日期+时间+时辰） |
| `casting_question_row.dart` | 问事信息第二行（§5.4，主题/正文/对象/背景） |
| `six_yao_input_panel.dart` | 六爻录入第三行面板（§5.5，当前步骤 chip） |
| `six_yao_input_row.dart` | 六爻单行（已录/待录/编辑三态，§8/§9） |
| `yao_glyph.dart` | 爻矢量图形（阴阳线 + 老阴空心圆/老阳 X，§10） |
| `casting_rule_pack_row.dart` | 规则包第四行（§5.6，修改 ›） |
| `casting_generate_row.dart` | 生成排盘第五行（locked/ready/generated，§5.7/§14） |
| `casting_chip.dart` | XYUI 胶囊徽标 + 矢量 chevron |
| `line_editor_sheet.dart` | 爻象选择弹层（少阴/少阳/老阴/老阳 + 清除） |
| `time_editor_sheet.dart` | 起卦时间弹层（日期/时间/时辰自动换算，§11） |
| `question_editor_sheet.dart` | 问事信息弹层（四项文本，§12） |
| `rule_pack_sheet.dart` | 规则包占位弹层（§13，不造假 CRUD） |
| `test/presentation/casting/casting_page_test.dart`（重写） | Test A–D + 行顺序 + 草稿仓库 + 纯逻辑 |

### 新增（lib/services/draft/）
| 路径 | 说明 |
| --- | --- |
| `casting_draft.dart` | 草稿模型（含视觉定稿演示草稿 CastingDraft.demo） |
| `draft_repository.dart` | DraftRepository 接口边界 + 内存实现（§15，不把 DB 写进 Widget） |

### 修改
| 路径 | 说明 |
| --- | --- |
| `lib/presentation/casting/casting_page.dart` | 流程轨 → XYUI 排卦工作台（状态全部进入 CastingPageState） |
| `lib/presentation/casting/casting_page_state.dart` | 重写：GenerationState / DraftState / CastingPageState（§7 全部字段） |
| `lib/presentation/casting/casting_tokens.dart` | 对齐任务书 §3 定稿 Token 值 |
| `lib/app/navigation/guayan_main_tab_bar.dart` | 白底 + 胶囊选中；排卦图标 → 艮卦矢量（§16，无 Unicode ☶） |
| `test/foundation_test.dart`（重写） | Test E 五导航 / Test F 艮卦图标 / 状态保持 / 更多菜单 |

### 删除（方案 2 流程轨组件）
`casting_top_bar / casting_flow_header / casting_flow_rail / casting_workflow / casting_step_node / casting_step_card / casting_step_status / casting_generate_step / casting_context_strip`（widgets/ 下 9 个文件）

### 验证
- `flutter test`：全量通过（含 Test A–F）
- `flutter analyze`：本轮新增/修改文件 0 issue（存量遗留 21 项 lint 不变，记入 BACKLOG）
- Android debug 构建成功（`build/app/outputs/flutter-apk/app-debug.apk`）

### 说明（GAP，后续阶段）
- 完整干支历法引擎（年月日干支 / 旬空 / 纳甲）未做，本轮仅小时→时辰基础映射；
- 自定义规则包 CRUD 未做（占位弹层，保留 RuleId + RuleVersion）；
- 「查看审卦 ›」本轮为视觉占位，跨 tab 导航属后续；
- 草稿持久化为内存实现，接口边界已定型（DraftRepository）。

---

## 2026-08-30 · 排卦页 XYUI 改造（Vertical Casting Workflow，未发布）

> **方案 2 · 纵向排卦流程轨**：起卦时间 → 问事信息 → 六爻输入 → 规则包 → 生成排盘。
> 视觉以任务书 SVG 为唯一基准；本轮为视觉阶段（不做完整表单与排盘算法），
> 步骤摘要为演示占位值，待用户真机截图人工验收。

### 新增（lib/presentation/casting/）
| 路径 | 说明 |
| --- | --- |
| `casting_tokens.dart` | XYUI 视觉 Token 集中（§18） |
| `casting_page_state.dart` | CastingStepState（current/pending/completed/warning/locked）+ 数据模型 |
| `widgets/casting_top_bar.dart` | XYUI 顶栏（排卦/副标题/三点更多） |
| `widgets/casting_flow_header.dart` | CASTING FLOW 头部（当前步骤 x/5） |
| `widgets/casting_workflow.dart` | 流程轨组装（rail + 步骤行） |
| `widgets/casting_flow_rail.dart` | 纵向竖线 |
| `widgets/casting_step_node.dart` | 节点状态全集（数字/对勾/!/锁，矢量绘制） |
| `widgets/casting_step_card.dart` | 步骤卡四种状态（含完成摘要） |
| `widgets/casting_step_status.dart` | 状态徽标 + chevron |
| `widgets/casting_generate_step.dart` | 生成步骤（locked/ready/completed/warning） |
| `widgets/casting_context_strip.dart` | 流程上下文条（规则包/探针/已完成 x/5） |
| `test/presentation/casting/casting_page_test.dart` | 工作流状态测试（推进/生成/需重新生成/探针/组件状态） |

### 修改
| 路径 | 说明 |
| --- | --- |
| `lib/presentation/casting/casting_page.dart` | 占位页 → 纵向流程轨（状态机驱动） |
| `lib/app/navigation/guayan_main_tab_bar.dart`（新增） | XYUI 底部导航 + 五图标 CustomPainter（§15） |
| `lib/app/navigation/main_tabs.dart` | MainTab 增加 iconBuilder |
| `lib/app/app_shell.dart` | NavigationBar → GuayanMainTabBar；排卦页无全局 AppBar |
| `lib/app/more_menu.dart` | 支持自定义 icon（排卦页三点） |
| `test/foundation_test.dart` | 适配新 UI（XYUI 导航/流程轨/探针 Key/三点更多） |
| `file-tree.md`、`CHANGELOG.md` | 本文件 |

### 验证
- `flutter test`：**63/63 通过**（领域 53 + foundation 更新 10 + 排卦页新增 10）
- `flutter analyze`：本轮新增/修改文件 0 issue（存量遗留 21 项 lint 记入 BACKLOG）
- Android debug 构建成功（`build/app/outputs/flutter-apk/app-debug.apk`）

### 说明
- 状态进入真实 State，不从颜色反推；已完成步骤可重新进入；
  生成后修改关键数据 → 生成步骤标记「需重新生成」（不清空已填内容）。
- 原「状态探针：0」孤立文本移除，探针语义保留在 Context Strip（可点击递增）。
- 完整起卦时间选择器 / 问事编辑器 / 六爻编辑器 / 规则包管理 / 排盘算法 → 后续阶段（BACKLOG）。

---

## 2026-08-30 · GUAYAN-2.0-DOMAIN-HARDENING（Stable Relation Identity 收口，未发布）

> **背景：** 人工核验 DOMAIN 阶段后认可主体设计，要求封死 4 个数据兼容问题
> （canonical 碰撞 / 规则版本 replay / Domain 不变量 / 本机脚本入库），
> 不重构、不进入 R3。验收句升级：
> RelationInstance 可重建；RelationNote 不失忆；RuleVersion 变化不能让历史卦例失忆；
> 任意合法 RuleId/Subtype 不能制造身份碰撞；坏 Case 数据不能制造重复身份。

### 新增

| 路径 | 说明 |
| --- | --- |
| `lib/domain/rule_execution_context.dart` | 规则版本 replay 上下文（RuleVersionRef / RuleExecutionContext） |
| `test/domain/relation_key_collision_test.dart` | T1 canonical 无歧义性（含 `|`/`->`/`<->`/`\` 的碰撞回归） |
| `test/domain/rule_version_replay_test.dart` | T2 旧卦例 v1 → 系统升级 v2 → reload → replay v1 → 笔记恢复 |
| `test/domain/domain_invariants_test.dart` | T3 爻位/六爻不变量 + 坏 JSON 拒绝 |

### 修改

| 路径 | 说明 |
| --- | --- |
| `lib/domain/relation_key.dart` | canonical 无歧义化：字符串字段稳定转义（`\`→`\\`，`|`→`\|`），单射编码 |
| `lib/domain/hexagram_case.dart` | 新增 `ruleContext` 字段（跟随持久化）；runtime 校验恰好 6 爻、position 恰为 1..6、无重复 |
| `lib/domain/line_endpoint.dart` | 构造改为 runtime 校验爻位（1..6），JSON 反序列化同校验 |
| `lib/domain/line_state.dart` | 同上 |
| `lib/domain/relation_calculator.dart` | 规则版本优先取 `case.ruleContext.versionForOrDefault(ruleId)`，无记录回退 v1 |
| `.gitignore` | `scripts/flutter.local.ps1` 不入库；`*.apk` 忽略 |
| `scripts/flutter.ps1` | 移出版本控制（删除；工作区改为 `scripts/flutter.local.ps1`） |
| `lib/domain/README.md` | 补充 escaping / replay 契约 / runtime 不变量设计说明 |
| `file-tree.md`、`CHANGELOG.md` | 本文件 |

### 验证

- `flutter test`：**53/53 通过**（原 Test A–E + T8 全部继续通过；新增 T1 碰撞 7 项、
  T2 replay 4 项、T3 不变量 12 项）
- `flutter analyze`：本轮新增/修改文件 0 issue（存量遗留 21 项 lint 记入 BACKLOG）
- Android debug 构建成功（`build/app/outputs/flutter-apk/app-debug.apk`）
- 未启动 Android 模拟器

---

## 2026-08-30 · GUAYAN-2.0-DOMAIN（Stable Relation Identity，未发布）

> **阶段目标：** RelationInstance 可以重建，RelationNote 不能失忆。
> 只做四个核心 Domain（HexagramCase / LineState / RelationInstance / RelationNote）
> 与稳定关系身份 RelationKey，不扩范围。设计文档见 `lib/domain/README.md`。

### 新增文件

| 路径 | 说明 |
| --- | --- |
| `lib/domain/hexagram_case.dart` | 卦例持久化根对象（最小骨架） |
| `lib/domain/line_state.dart` | 一爻状态：爻位 / 动静 / 所值地支 |
| `lib/domain/line_endpoint.dart` | 关系端点稳定身份（卦侧 + 爻位） |
| `lib/domain/relation_type.dart` | 关系类型枚举 + 系统 RuleId 常量 |
| `lib/domain/relation_key.dart` | 关系稳定语义 key（Stable Relation Identity 核心） |
| `lib/domain/relation_instance.dart` | 具体关系实例（重算可重建） |
| `lib/domain/relation_calculator.dart` | 最小确定性关系计算（动变/六冲/六合） |
| `lib/domain/relation_note.dart` | 关系笔记（caseId + RelationKey 绑定） |
| `lib/domain/relation_note_store.dart` | 笔记绑定存储（纯内存 + JSON 导入导出） |
| `test/domain/domain_test_utils.dart` | 共享演示卦例（动变 + 六冲） |
| `test/domain/relation_key_test.dart` | Test A 确定性 / Test B 差异性 / 方向处理 |
| `test/domain/relation_key_serialization_test.dart` | RelationKey JSON round-trip 与展示名解耦 |
| `test/domain/relation_rebinding_test.dart` | Test C 重算恢复 / Test D 不串笔记 / Test E 顺序无关 |
| `test/domain/relation_serialization_test.dart` | T8 序列化 → 反序列化 → 重算 → 重新绑定全链 |
| `scripts/flutter.ps1` | 本机 Flutter 包装脚本（APPDATA/代理/直调 snapshot） |

### 修改文件

| 路径 | 说明 |
| --- | --- |
| `lib/domain/README.md` | 占位说明 → Stable Relation Identity 设计文档 |
| `file-tree.md` | 记录 DOMAIN 阶段新增文件、目录树与职责 |
| `CHANGELOG.md` | 本文件 |

### 验证

- `flutter test`：**31/31 通过**（21 领域 + 10 Foundation/Widget）
- `flutter analyze`：本轮新增文件 0 issue（存量遗留 21 项 lint 记入 BACKLOG）
- 未启动 Android 模拟器；手机验收包构建见构建产物
- RelationKey 组成：类型机器名 + RuleId + RuleVersion + subtype + 端点（卦侧, 爻位）；
  有向关系保序（A→B ≠ B→A），对称关系排序（A-B == B-A）；caseId 不入 key，笔记按
  `(caseId + RelationKey)` 绑定。

---

## 2026-08-27 · 成果归档提交（未发布）

> **背景：** 开发机内存耗尽崩溃重启（Gradle 提交内存 errno 1455），判定本机暂不具备继续开发条件。
> 为避免成果丢失，将工作区全部未提交成果一次性归档提交，并推送 GitHub。
>
> 提交：`feat: archive 2.0 training data layer, design assets and low-mem build config`
> 分支：`feat/guayan-2.0`（推送后与远端同步）

### 本次提交文件审计

| 路径 | 类型 | 大小 | 说明 |
| --- | --- | --- | --- |
| `lib/data/training_question.dart` | 新增 | 586 B | 2.0 训练数据模型：`TrainingModule` / `RelationType` / `TrainingQuestion` |
| `lib/data/wuxing_questions.dart` | 新增 | 3.0 KB | 五行生克题库：相生 5 题 + 相克 5 题（`allWuxingQuestions`） |
| `AGENTS.md` | 新增 | 2.1 KB | 项目代码规则：文件组织 / 架构分层 / 命名 / 文档纪律 / 版本与构建 |
| `CHANGELOG.md` | 新增 | 本文件 | 文件审计与变更日志 |
| `uploads/XYUI1ComponentDocumentView.axaml` | 新增 | 5.2 KB | 参考资料：Avalonia 组件视图文档 |
| `uploads/卦眼 2.0 · 六爻排卦、关系可视化、自定义规则与卦例复盘总开发计划.md` | 新增 | 20.9 KB | 参考资料：卦眼 2.0 总开发计划 |
| `五行相克特效/金克木.html` | 新增 | 8.7 KB | 相克动画原型：金克木 |
| `五行相克特效/木克土.html` | 新增 | 7.0 KB | 相克动画原型：木克土 |
| `五行相克特效/土克水.html` | 新增 | 5.5 KB | 相克动画原型：土克水 |
| `五行相克特效/水克火.html` | 新增 | 10.2 KB | 相克动画原型：水克火 |
| `五行相克特效/火克金.html` | 新增 | 8.1 KB | 相克动画原型：火克金 |
| `五行相生特效/金生水.html` | 新增 | 6.8 KB | 相生动画原型：金生水 |
| `五行相生特效/水生木.html` | 新增 | 8.7 KB | 相生动画原型：水生木 |
| `五行相生特效/木生火.html` | 新增 | 5.9 KB | 相生动画原型：木生火 |
| `五行相生特效/火生土.html` | 新增 | 7.1 KB | 相生动画原型：火生土 |
| `五行相生特效/土生金.html` | 新增 | 6.7 KB | 相生动画原型：土生金 |
| `android/gradle.properties` | 修改 | — | 低内存约束：JVM 堆 `-Xmx1G`、Kotlin daemon `-Xmx256m`、`org.gradle.workers.max=1`，避免构建提交内存耗尽（errno 1455） |
| `file-tree.md` | 修改 | — | 同步新增文件、目录树、职责表与最后编辑时间 |

### 提交后仓库快照审计

- 跟踪文件数：**109 → 125**（+16）
- 顶层分布：`lib/` 77 · `android/` 19 · `五行相克特效/` 5 · `五行相生特效/` 5 · `test/` 2 · `memory/` 2 · `uploads/` 2 · 根目录杂项 13
- 分支状态：`feat/guayan-2.0`（HEAD = `b408199 feat: establish Guayan 2.0 foundation`，领先 `master` 1 个提交；`master` 与 `origin/master` 同步于 `5c4bdb6`）
- 未跟踪/未提交内容：无（全部已归档）
- 大型目录说明：`build/`（约 3 GB 构建产物）与 `.dart_tool/` 由 `.gitignore` 排除，不入库

---

## 版本历史摘要

| 版本 | 日期 | 类型 | 说明 |
| --- | --- | --- | --- |
| `v0.1.10` | 2026-05-22 | 新增 | 关系连连看：25 组配对 + 50 张卡消除 + 回炉 |
| `v0.1.9` | 2026-05-22 | 新增 | 方块速答游戏模板，单题下落 + 计时 + 回炉 |
| `v0.1.8.3` | 2026-05-18 | 重构 | 旧入口迁移到通用练习框架 |
| `v0.1.7.x` | 2026-05-18 | 新增/重构 | 以我为中心学习页、圆盘结构升级、旺相休囚死 |
| `v0.1.6.x` | 2026-05-16 | 优化/修复 | 轮盘尺寸稳定、三阶段统计、回炉来源标签 |
| `v0.1.5` | 2026-05-16 | 新增 | 五行相克学习页、wrongCount 修复、回炉弹窗 |
| `v0.1.4.x` | 2026-05-16 | 新增/修复 | 回炉错题重做系统、相生练习三阶段、答题反馈色 |
| `v0.1.3.x` | 2026-05-16 | 新增/优化 | 五条相生 HTML 动画接入、钻木取火、轮盘节奏优化 |
| `v0.1.1` – `v0.1.2.x` | 2026-05-15 | 基础 | 项目骨架与五行基础功能 |

> 完整版本历史见 `file-tree.md` 第 8 节。标签 v0.1.1 – v0.1.10 均已推送 GitHub。
