# domain/ — GUAYAN-2.0-DOMAIN（Stable Relation Identity · HARDENING 后）

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
| `relation_calculator.dart` | 最小确定性关系计算（动变/六冲/六合），输出按 key 稳定排序 |
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

## 本轮明确不做（见 BACKLOG / GAP）

- 完整六爻排盘引擎（纳甲/六亲/六神/世应/旬空…）—— R3；
- 回头生/回头克等依赖纳甲的关系计算 —— R3 后接入，key 机制已就绪；
- 完整关系引擎（月日/墓库/空破…）—— R4；
- 自定义规则 CRUD / 规则包 / 规则编辑器 —— R7；
- 一条关系多条笔记（isPinned）—— R6 关系页阶段；
- 持久化实现（SQLite/Drift）—— 待正式决定后落地，Domain 保持无关；
- 全局「最新规则版本」注册表 —— replay 现阶段以 case 上下文为准。
