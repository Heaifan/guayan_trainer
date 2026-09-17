# GUAYAN-R5 卦例档案库设计

## 目标

建立“生成排盘 → 自动形成卦例 → 卦例库管理 → 点击恢复审卦现场 → 编辑事项/备注 → 收藏/删除/恢复 → 基于新规则重算”的闭环。卦例页是档案库，只负责保存、查找和重新打开过去的一次真实排盘，不扩展标签、统计、归组、AI 或分享能力。

## G0 真实调用链审计

当前排卦链：

```text
CastingPage._generate()
  ↓
+六个 LineState 的 MovementType
  ↓
CastingEngine.cast(..., dayGan: ...)
  ↓
CastChart（original / changed / lines / movingPositions）
  ↓
HexagramCase（当前只保存 id、question、lines、createdAt、calendar、ruleContext）
  ↓
AppShell.onGenerated → _latestCase
  ↓
ReviewPage.latestCase
  ↓
ReviewCaseAdapter.adapt()
  ↓
ReviewPageState 与现有审卦 widgets
```

当前历史恢复不是持久化恢复：`AppShell` 只保存内存中的 `_latestCase`；`ReviewCaseAdapter.adapt()` 会从 `HexagramCase.lines` 再次调用 `CastingEngine.cast()`。本轮将把恢复入口改为读取 Case 中的不可变快照，并保留旧数据缺快照时的兼容回退。

当前规则链可确认的持久化边界是 `RuleExecutionContext` 与 `RuleVersionRef(ruleId, version)`；规则 DSL、AST、OperatorRegistry、PredicateEvaluator、RuleEngine 均不改语义。本轮 RuleRun 先保存现有规则身份/版本与已产生的命中证据结构，重算只追加 RuleRun。

当前关系/备注：关系由 `calculateRelations(HexagramCase)` 计算并经 `RelationProjection` 投影；`RelationAnnotationStore` 与 `ManualRelationStore` 目前是进程内存储，并按 `caseId` 作用域。神煞备注由 `ShenShaNoteStore` 按 `caseId + shenShaId` 作用域。卦例级备注尚未形成统一持久化边界，本轮将以 Case 元数据承载总备注，并把已有关系/神煞备注接入统一的可持久化 case-scoped store，不复制关系领域模型。

## 数据边界

`CaseRecord` 表示一次真实生成的事实档案；`RuleRun` 表示对同一档案事实的一次规则观察。

### 不可变事实

`CastingSnapshot` 保存起卦输入、`castingTime`、日历快照、六爻原始状态、由当前排盘引擎得到的本卦/变卦/动爻及审卦恢复所需的确定性字段。生成后不可被事项、备注、收藏、删除或规则重算修改。

### 可变元数据

Case 保存 `subject`、总备注、`createdAt`、`updatedAt`、`favorite`、`deletedAt`。`castingTime` 是实际起卦时间；列表筛选与排序只使用 `castingTime`，`createdAt` 仅作稳定第二排序键。

### RuleRun

首次生成写入 Original RuleRun；当前规则重算从原始 `CastingSnapshot` 读取并追加新的 RuleRun。Original RuleRun 永不覆盖，重算不创建新 Case。

## 持久化与查询

新增 `CaseRepository` 抽象，页面不直接操作文件或 JSON。实现复用项目已有依赖和本地数据目录；若当前数据层没有统一数据库，本轮采用当前架构可支持的本地 JSON repository，并集中实现 schema 版本、兼容读取和原子写入。查询 API 在 repository 层完成 `subject/originalName/changedName` 搜索、基于本地时间的日期范围、收藏/删除状态、稳定排序及 `limit`/cursor 或 offset 的加载更多。

旧 `HexagramCase` JSON 允许读取：缺少新字段时提供默认值；缺少完整 `CastingSnapshot` 时只在兼容适配路径重建，禁止静默改写旧事实。

## 页面与导航

复用现有 Cases Tab 与卦眼视觉 token。列表首屏只显示事项、`castingTime`、本卦→变卦和收藏状态；空事项显示“未填写事项”，无变卦不显示箭头。点击列表项直接进入现有 `ReviewPage`，不新增详情页。

提供搜索防抖、今天/近 7 天/近 30 天/自定义日期、全部/收藏、ASC/DESC、首屏加加载更多、多选批量软删除。回收站提供恢复、二次确认永久删除、清空回收站。备注编辑使用 500ms 防抖，并在失焦和退出页面时 flush。

## 测试与基线

每个 Gate 遵循 TDD：先写失败测试、确认失败原因、写最小实现、运行定向测试，再进入下一 Gate。覆盖 Case round-trip、时间分离、空事项、软删除/恢复/永久删除、生成新增 Case、历史快照不变、列表查询、加载更多、备注自动保存和 RuleRun 重算边界。

执行前基线：当前分支 `feat/guayan-2.0`，HEAD `0ca8d335cb2733972b071448c6bda151b374c1a1`，`flutter test` 为 `479` 通过、`13` 失败。失败来自既有 `lib/presentation/relations/relations_page.dart` 编译问题及既有 review 页面布局断言，后续报告中与本轮结果分开统计。

## 范围守则

- 不修改 Rule DSL、AST、Operator 语义或排盘算法。
- 不复制 `HexagramCase`、关系、备注或 RuleEngine 领域模型。
- 不引入标签、项目归组、统计、AI、分享、云同步、导入导出或批量编辑。
- 不覆盖工作区已有 dirty 修改；发生直接冲突时停止并报告。
