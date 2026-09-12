# domain/ — GUAYAN-2.0-DOMAIN（Stable Relation Identity · R4 基础关系引擎）

> 阶段：GUAYAN-2.0-DOMAIN + GUAYAN-2.0-DOMAIN-HARDENING
> 目标：**RelationInstance 可以重建；RelationNote 不能失忆；
> RuleVersion 变化不能让历史卦例失忆；
> 任意合法 RuleId/Subtype 不能制造身份碰撞；
> 坏 Case 数据不能制造重复身份。**

本目录承载卦眼 2.0 的最小领域模型，全部为纯 Dart（零 Flutter 依赖、零外部依赖），
storage-agnostic：只通过 JSON（`dart:convert`）证明
「序列化 → 反序列化 → 重算 → 重新绑定」链条成立，持久化实现（SQLite/Drift）后续再定。

## 文件职责

| 文件 | 职责 |
| --- | --- |
| `hexagram_case.dart` | 卦例持久化根对象（id / question / createdAt / lines[6] / ruleContext） |
| `line_state.dart` | 一爻状态：稳定爻位 + 动静（动爻判定）+ 所值地支 |
| `line_endpoint.dart` | 关系端点稳定身份：卦侧（本卦/变卦）+ 爻位（1..6） |
| `relation_type.dart` | 关系类型枚举（机器名/方向类别/展示名）+ 系统规则 RuleId 常量 |
| `relation_key.dart` | **Stable Relation Identity 核心**：关系稳定语义 key（单一构造入口） |
| `relation_instance.dart` | 一条具体关系（重算可重建，身份一律以 key 为准） |
| `relation_calculator.dart` | R4 基础关系引擎编排：四类规则合并 + canonical 稳定排序 + 缺失输入诊断 |
| `relation_endpoint.dart` | 关系端点领域身份（sealed：爻 / 月建 / 日辰），canonical 语义 id |
| `relation_diagnostics.dart` | 关系计算诊断（missingInputs / warnings，缺失不得静默） |
| `calendar_snapshot.dart` | 起卦当时的历法快照（月建支 + 日辰干支），历史可复现 |
| `relation_note.dart` | 关系笔记（通过 caseId + RelationKey 重新绑定） |
| `relation_note_store.dart` | 笔记绑定存储：纯内存 + JSON 导入导出 |
| `rule_execution_context.dart` | **规则版本 replay 上下文**：记录计算关系时各规则使用的版本 |

## Stable Relation Identity 设计

### RelationKey 组成（语义坐标，非生成时间）

```text
RelationType 机器名 + RuleId + RuleVersion + subtype + 端点（卦侧, 爻位）
```

- **RelationType 机器名**：如 `hui_tou_sheng`，展示名（中文标题）绝不入 key；
- **RuleId**：系统规则 `sys.*` 常量；自定义规则未来用 JSON `id` 字段（机制不变）；
- **RuleVersion**：规则语义变更时递增，key 随之变化（有意为之）——
  **因此 HexagramCase 必须保存 replay 所需规则上下文（见 RuleExecutionContext）**；
- **端点**：`(original|changed, 1..6)`，如 `changed-3`、`original-6`；
- **caseId 不入 key**：笔记按 `(caseId + RelationKey)` 外置绑定（总计划 §22 的存储复合键）。

### 方向性显式处理

- **有向**（生/克/动变/回头生克）：端点顺序即方向，`A→B ≠ B→A`；
- **对称**（六冲/六合）：端点排序后入 key，`A-B == B-A`。

### Canonical 序列化（无歧义编码）

```text
有向: {type}|{ruleId}|v{ruleVersion}|{subtype|-}|{source}->{target}
对称: {type}|{ruleId}|v{ruleVersion}|{subtype|-}|{min}<->{max}
```

例：`hui_tou_sheng|sys.hui_tou_sheng|v1|-|changed-3->original-3`

**无歧义性（HARDENING T1）**：所有字符串字段（type / ruleId / subtype / 端点）在拼接前
经稳定转义（`\` → `\\`，`|` → `\|`），编码单射 —— 任意合法 RuleId / Subtype
（可来自自定义规则 JSON，含 `|` / `->` / `<->` / `\` 等字符）都不可能拼出相同 canonical。

### Rule Version Replay 契约（HARDENING T2）

`RelationKey` 含 RuleVersion，因此 `HexagramCase.ruleContext`
（`RuleExecutionContext`）持久化「计算关系时各规则使用的版本」：

```text
旧卦例（context 记录 sys.liu_chong = v1）→ 写笔记
        ↓ 系统规则升级为 v2
重新打开旧卦例 → replay 使用 context 中的 v1
        ↓
RelationKey 仍是 v1 → 旧笔记正确重新绑定
```

- 可 JSON 持久化、跟随 HexagramCase 保存、不依赖当前全局最新版规则；
- `calculateRelations()` 优先读取 `case.ruleContext.versionForOrDefault(ruleId)`，
  无记录时回退默认 v1（旧数据向后兼容）；
- 完整 Rule CRUD / RulePack 属后续 R7，本契约只封住 replay 边界。

### Domain Runtime 不变量（HARDENING T3）

不依赖 Dart `assert`（release 下不生效），构造与 JSON 反序列化均强制：

```text
LineEndpoint.position ∈ 1..6
LineState.position     ∈ 1..6
HexagramCase:
  lines.length == 6
  positions 恰好为 {1,2,3,4,5,6}（无重复、无缺失）
```

坏数据（含 malformed JSON）在进入关系计算器之前被拒绝，
避免生成重复语义端点 / 重复 RelationKey。

### 绑定语义

```text
写笔记: (caseId, RelationKey) → RelationNote
重算后: 新 RelationInstance → 计算同一 RelationKey → 笔记自动挂回
```

## R4 · 基础关系引擎（已落地）

### 端点身份契约

```text
RelationKey 的 source / target 必须表示真实语义对象。
禁止为了复用六爻 position 模型，给非爻对象制造虚假的 position。
```

因此 R4 引入 `relation_endpoint.dart` 的 `sealed class RelationEndpoint`：

| 端点 | semanticId | position |
| --- | --- | --- |
| `YaoEndpoint(scope, 1..6)` | `yao:original:3` / `yao:changed:6` | 有（真实爻位） |
| `MonthEndpoint()` | `month` | **无** |
| `DayEndpoint()` | `day` | **无** |

后续可无破坏扩展：时、卦名、神煞、纳音、伏神、六神…
`LineEndpoint`（`line_endpoint.dart`）**降级为绘线定位键**，只服务于
可视化层（R5 adapter 把领域端点解析成控件位置），不再是关系身份真源。

### 输入 = HexagramCase（确定性契约）

```text
相同 HexagramCase + 相同 ruleVersion  =>  相同 RelationInstance 集合
```

一切影响关系结果的事实都必须能从 `HexagramCase` 自身复现，**禁止第二隐式输入**：

- `HexagramCase.calendar`（`CalendarSnapshot`：月建支 + 日辰干支）
  是**起卦当时的历法快照**，不重新调用历法引擎 —— 历法数据包将来升级时，
  历史卦例的月建 / 日辰不得漂移（否则复盘会看到「同一个卦几年后月建变了」）。
- `LineState.changedBranch`：动爻的变爻地支（回头生/克必需）。
- 缺失是**显式状态**：`calculateRelationResult()` 返回
  `RelationCalculationDiagnostics.missingInputs`（如 `calendar.monthBranch`、
  `line[3].changedBranch`），缺失时该类关系**不产出**，
  **禁止**自动补算、猜测或用本爻地支冒充变爻地支。

### 两层语义（事实账本 vs 作用力）

```text
ElementRelation / 五行事实关系  —— 全量、客观、无解释倾向（R4 = 本层）
EffectRelation  / 作用关系      —— 哪些关系在当前卦里真正参与判断（后续规则层）
```

R4 对本卦六爻执行无序两两组合（C(6,2) = 15 对）：

```text
A 生 B → A -> B · sheng        A 克 B → A -> B · ke
B 生 A → B -> A · sheng        B 克 A → B -> A · ke
同五行 → 本层不产出
```

**本层不判断作用力**：静爻与静爻之间同样产出事实关系。
UI 通过筛选器（生 / 克 / 动爻相关 / 月建 / 日辰 / 选中对象）控制可视关系，
**不得**为了图面简洁反向裁剪 Domain 数据。

### 模块划分

| 文件 | 职责 |
| --- | --- |
| `relation_rules/changed_lines.dart` | 动变 · 回头生 · 回头克 |
| `relation_rules/branch_pairs.dart` | 六冲 · 六合（只用 `DiZhi.chong/he`，禁止自带映射表） |
| `relation_rules/wu_xing_pairs.dart` | 五行相生 · 相克（本卦六爻两两，事实账本） |
| `relation_rules/month_day.dart` | 月建基础作用 · 日辰基础作用（只读日历快照） |
| `relation_rules/rule_support.dart` | 规则共用：replay 版本取值 + 地支解析 + 端点构造 |

## 本轮明确不做（见 BACKLOG / GAP）

- 完整六爻排盘引擎（纳甲/六亲/六神/世应/旬空…）—— R3；
- 墓库 / 空破 / 旺衰等高级关系 —— R8；
- 作用力判定（EffectRelation：哪些关系真正参与断卦）—— 后续规则层；
- 自定义规则 CRUD / 规则包 / 规则编辑器 —— R7；
- 一条关系多条笔记（isPinned）—— R6 关系页阶段；
- 持久化实现（SQLite/Drift）—— 待正式决定后落地，Domain 保持无关；
- 全局「最新规则版本」注册表 —— replay 现阶段以 case 上下文为准。
