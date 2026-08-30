# 卦眼训练器 — 文件审计与变更日志

> **仓库：** https://github.com/Heaifan/guayan_trainer.git
> **归档分支：** `feat/guayan-2.0`
> **最近正式发布：** v0.1.10（2026-05-22）
> **本文件创建：** 2026-08-27
> **完整文件树与历史：** 见 [file-tree.md](file-tree.md)

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
