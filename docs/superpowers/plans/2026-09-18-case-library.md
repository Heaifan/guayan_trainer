# GUAYAN-R5 Case Library Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立一次生成一条 Case、历史事实可恢复、可编辑元数据可持久化、可查询管理且规则重算只追加 RuleRun 的卦例档案闭环。

**Architecture:** 在现有 `domain` / `services` / `presentation` 结构中扩展 `HexagramCase` 为 CaseRecord，新增不可变 `CastingSnapshot`、冻结显示数据的 `RuleRun` 与 metadata-index-backed `CaseRepository`。生成页、审卦页和 Cases Tab 只通过 repository/controller 交互，不复制排盘算法、关系系统或 RuleEngine。

**Tech Stack:** Flutter/Dart，现有 JSON/local persistence dependencies，Flutter unit/widget tests。

**Spec:** `docs/superpowers/specs/2026-09-18-case-library-design.md`

## Global Constraints

- `CastingSnapshot.castingTime` 是唯一事实源；索引中的 `castingTime` 只能是创建时派生的查询字段，禁止独立修改。
- RuleRun 必须携带规则身份/版本、命中结果、证据及历史显示所需文本/结构；恢复不得依赖未来仍存在的 RuleDefinition。
- G5 必须盘点 ReviewPage 全部现有可备注元素，全部按 `caseId` 持久化并支持 edit/save/reload。
- 列表最终稳定键固定为 `castingTime + createdAt + id`；JSON 实现必须有轻量 metadata index/manifest，列表查询不得反序列化所有完整 Snapshot。
- Pre-G0 baseline=`0ca8d335cb2733972b071448c6bda151b374c1a1`；G1 starting HEAD=`17c39c9`。
- 禁止修改 Rule DSL、AST、Operator 语义、排盘算法；禁止引入标签、归组、统计、AI、分享、云同步、导入导出和批量编辑。
- 保留当前工作区既有 dirty 修改；若任务文件与 dirty 文件直接冲突，停止并报告。
- 每个行为先写失败测试并确认失败原因，再写最小实现；每个 Gate 独立运行定向测试。

## 文件地图

- Create: `lib/domain/cases/casting_snapshot.dart`, `case_record.dart`, `rule_run.dart`, `case_metadata.dart` — 不可变事实、RuleRun 冻结结果与轻量索引模型。
- Create: `lib/services/cases/case_repository.dart`, `json_case_repository.dart`, `case_query.dart`, `case_migrations.dart` — repository API、metadata index、迁移与查询。
- Modify: `lib/domain/hexagram_case.dart` — 兼容旧领域入口并委托/暴露 CaseRecord 必需字段，不复制模型。
- Modify: `lib/presentation/casting/casting_page.dart`, `lib/app/app_shell.dart` — create-only 生成链与当前 Case 恢复。
- Modify/Create: `lib/presentation/cases/*` — 极简列表、筛选、加载更多、回收站和批量软删除。
- Modify: `lib/presentation/review/review_case_adapter.dart`, `review_page.dart` — Snapshot 优先恢复、case-scoped 元数据与 RuleRun 入口。
- Modify: 现有备注 stores — 接入持久化 case-scoped store，保留现有 stable IDs。
- Test: `test/domain/cases/*`, `test/services/cases/*`, `test/presentation/cases/*`, `test/presentation/review/*` — 逐 Gate 回归。

### Task 1: G1 Case domain and persistence

**Files:** 上述 domain/services cases 文件；`test/domain/cases/case_record_test.dart`、`test/services/cases/json_case_repository_test.dart`。

- [ ] 写失败测试：Case round-trip 保留 Snapshot、`castingTime != createdAt`、空 subject、Original RuleRun 冻结结果/证据，且 metadata index 不包含完整 Snapshot。
- [ ] 写失败测试：create/read、softDelete/list active、restore、favorite/unfavorite、permanentDelete；查询按 `castingTime + createdAt + id` 稳定排序。
- [ ] 运行 `flutter test test/domain/cases test/services/cases`，确认因类型/仓库缺失失败。
- [ ] 实现最小不可变模型、JSON codec、metadata manifest 和原子 repository 写入；用现有本地数据目录/依赖，不新增数据库。
- [ ] 运行同一命令至通过，再运行 `flutter analyze` 检查新增文件。
- [ ] 提交 `feat(case): add immutable case persistence`。

### Task 2: G2 Generate to auto-record

**Files:** `casting_page.dart`, `app_shell.dart`；`test/presentation/casting/casting_case_creation_test.dart`。

- [ ] 写失败测试：使用同一可注入 repository，首次生成后 count=1，重新生成后 count=2，再次重新生成后 count=3；三条 Snapshot/Original RuleRun 独立，旧 Case 不 update。
- [ ] 运行定向测试确认失败。
- [ ] 在生成成功处创建 Snapshot/Original RuleRun 并调用 repository.create；`castingTime` 从生成时唯一确定的 Snapshot 写入 index；App Shell 切换到最新 Case。
- [ ] 运行定向测试和现有 casting tests；修复仅本任务引入的回归。
- [ ] 提交 `feat(case): record generated castings`。

### Task 3: G3 Case library UI and query flow

**Files:** `lib/presentation/cases/*`, Cases navigation/app shell；`test/presentation/cases/cases_page_test.dart`、`test/services/cases/case_query_test.dart`。

- [ ] 写失败测试：只渲染 subject/time/original→changed/favorite；空 subject 为“未填写事项”，静卦不显示箭头；搜索仅匹配 subject、本卦、变卦。
- [ ] 写失败测试：今天/7 天/30 天/自定义首尾边界、收藏筛选、ASC/DESC、20 条加载更多；每次筛选或排序变更从首项加载，分页无重复/遗漏。
- [ ] 写失败测试：多选只能批量软删除；主列表排除 deleted，回收站恢复、二次确认永久删除、清空回收站。
- [ ] 运行定向测试确认失败，再实现 controller/query widgets；所有过滤/排序/limit 通过 repository metadata 查询。
- [ ] 运行定向测试并提交 `feat(case): add case library`。

### Task 4: G4 Open historical Case to review

**Files:** `review_case_adapter.dart`, `review_page.dart`, `app_shell.dart`；`test/presentation/review/historical_case_restore_test.dart`。

- [ ] 写失败回归：保存 Case 后改变当前 casting input/算法状态，再打开 Case，Snapshot 中本卦、变卦、动爻、六爻、六亲、六神、世应、伏神、旬空、纳音、卦宫等事实与保存时一致。
- [ ] 运行定向测试确认现有 adapter 会重算/字段缺失。
- [ ] 实现 Snapshot-first adapter；旧 JSON 缺 Snapshot 时只走兼容回退，不回写或篡改历史 Case；点击列表直接进现有 ReviewPage，不新增详情页。
- [ ] 运行历史恢复、review 定向测试并提交 `feat(case): restore historical review`。

### Task 5: G5 Mutable metadata and all notes

**Files:** `case_record.dart`, metadata service/controller，所有已盘点的 review note stores 与相关 widgets；`test/services/cases/case_metadata_test.dart`、`test/presentation/review/case_notes_persistence_test.dart`。

- [ ] 先盘点 ReviewPage 所有可备注入口（总备注、关系、神煞及当前代码中其他 note），为每项写 edit/save/reload 失败测试，证明均按 caseId 隔离。
- [ ] 实现 metadata 更新与 500ms debounce；失焦、页面 dispose/退出强制 flush；更新 subject/备注不得改变 Snapshot 或 Original RuleRun。
- [ ] 运行定向测试，显式断言重载后所有备注存在且不同 Case 不串数据；提交 `feat(case): persist editable annotations`。

### Task 6: G6 RuleRun recompute history

**Files:** `rule_run.dart`, case application/recompute service，现有规则入口；`test/services/cases/rule_recompute_history_test.dart`。

- [ ] 写失败测试：Case 初始 1 RuleRun，重算后 Case 仍 1 条、RuleRun=2、Snapshot 深相等、Original RuleRun 深相等，新 RuleRun 自带完整显示结果/证据且不依赖 RuleDefinition。
- [ ] 运行定向测试确认 recompute API 缺失。
- [ ] 实现从原 Snapshot 调用现有 RuleEngine/规则服务的应用层入口，只 append RuleRun；保留 Original RuleRun，禁止创建 Case 或改 Snapshot。
- [ ] 运行定向测试并提交 `feat(case): preserve rule recompute history`。

### Task 7: Full regression and documentation

**Files:** `file-tree.md`、必要的测试/兼容迁移文件。

- [ ] 运行全部 case 定向测试，整理每个 Gate 的 PASS/阻塞证据。
- [ ] 运行 `flutter analyze` 与 `flutter test`；将新增失败和基线已存在的 13 个失败分开列出，不把既有红灯标为通过。
- [ ] 更新 `file-tree.md` 目录树、模块职责、最后编辑时间；核对 scope check 与 modified files。
- [ ] 仅提交本任务文件，输出 Pre-G0、G1 starting HEAD、最终 HEAD、测试数字和 commit 列表。
