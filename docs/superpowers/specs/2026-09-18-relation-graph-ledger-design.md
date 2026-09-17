# Guayan Relation Graph & Visual Overlay V1 Design

**Date:** 2026-09-18  
**Scope:** R7-A Relation Ledger, R7-B Review Focus Overlay, R7-C Manual Relation

## Goal

将现有排盘事实、`RelationInstance` 与规则运行结果投影成可治理的统一 `RelationRecord`，供关系页 Ledger、搜索/筛选、审卦 Overlay、Focus 和手工关系共同消费。

## Non-goals

- `RelationRecord` 不计算六爻关系，不替代 `RelationInstance`、排盘事实或 Rule Runtime。
- R7 不扩展当前 Engine 尚未真实产出的关系类型。
- 不在第一版实现 A* 路由；仅使用曲线路径和平行 lane 做基础避让。

## Architecture

```text
HexagramCase / RelationInstance / Rule Result
                    ↓ deterministic projection
              RelationRecord + RelationAnnotation
                    ↓
       Ledger / Search / Filter / Review Overlay
```

`RelationRecord` 是展示与治理记录。FACT/RULE 记录可按稳定身份重建；用户备注、用户标签和 USER 关系通过独立 Annotation/Store 按稳定 id 重新挂载。

## Domain model

`RelationKind` 在 Domain 层区分 `relation` 与 `state`。RELATION 才能进入 Overlay；STATE 只能进入状态标签渲染。每条记录必须有 `participants`，位置筛选与 Focus 一律使用 `participants.contains(ref)`，不能只检查 `fromRef`。

字段至少包括：`id`, `kind`, `sourceKind`, `relationType`, `category`, `fromRef`, `toRef`, `participants`, `title`, `subtitle`, `ruleId`, `knowledgeRuleId`, `ruleVariantId`, `labels`, `keywords`, `evidence`, `note`, `createdAt`, `updatedAt`。

来源使用 `FACT`、`RULE`、`USER`，只展示为 `[事实]`、`[规则]`、`[手工]`，绝不使用动作颜色表达来源。

稳定 ID 由 Domain 投影层生成：相同事实、相同上下文、相同规则身份必须生成相同 ID；禁止每次投影随机 UUID。USER 关系可使用创建时 UUID。现有 `RelationKey` 是 FACT 的稳定身份输入；投影不得改写其语义。

## Projection and capability

新增 capability snapshot/diagnostic，列出当前 Runtime 对生、克、冲、合、刑、害、破、回头生、回头克、化进、化退及状态的真实支持情况。Runtime 仅投影真实输入；视觉 fixture 可以构造全协议样例，但不得进入生产排盘数据。

R7-A 的两个门禁：

1. 同一卦重新加载/重新投影后，FACT/RULE 的稳定 id 不变。
2. 重新投影后，按稳定 id 挂载的 Annotation/备注仍存在。

## Presentation

关系页为紧凑型 Ledger，不使用瀑布大卡片。筛选条件以 AND 叠加：记录类型、六爻位置、类别、搜索词。搜索覆盖标题、状态、端点/参与者、规则名、规则变体、规则输出、取象、标签、备注和 Evidence 摘要。点击记录打开详情层，可编辑备注；备注写入 Annotation Store。

审卦页采用 `Stack(Board, RelationOverlay)`。Overlay 接收 `RelationRecord`，负责路径、箭头、动作标签、anchor、hit test、Focus 和 selected relation。点击爻位在 `null → position → null` 间切换；点击其他爻直接切换；点击卦盘空白退出。点击关系与 Ledger 使用同一 `RelationRecord.id`。

手工关系流程为：`+连线 → 起点 → 终点 → 关系类型 → 备注 → 保存`，端点使用结构化引用，至少支持六爻、变爻、月建、日辰，生成 `sourceKind=USER`。

## Visual protocol

所有视觉参数集中在 `RelationVisualTokens`。颜色只映射动作：生 `#009E60`、克 `#D62F3A`、冲 `#FF7A00`、合 `#006DFF`、刑 `#C000A8`、害 `#00A6C8`、破 `#C99300`、回头生 `#00A88F`、回头克 `#9D1830`、化进 `#55A630`、化退 `#4055C8`。状态颜色独立：旬空 `#B7791F`、月破 `#C88732`、日破 `#D95C45`、入墓 `#795548`、出墓 `#C17B22`、旺态 `#259B72`、中性 `#77727A`。

关系线宽为 1.15px，Focus/selected 为 1.40px；箭头尺寸 4.20，anchor 半径 2.20；关系标签 9px/16px/8px；状态标签 8px/14px/7px，边框约 0.70px，填充透明度约 0.12，纵向间距 2px。全量关系透明度 0.33，Focus 0.90，selected 1.00，deemphasized 0.20。生克使用单箭头；冲合刑害破使用真正双向箭头；STATE 不绘制箭头。状态正文旬空继续保留 `□□`。

## Testing and acceptance

Domain 测试覆盖模型、稳定 ID、participants、来源投影、能力矩阵和 Annotation 重挂；查询测试覆盖关键字与 AND 筛选；Widget 测试覆盖 Ledger、备注、Focus 切换、点击定位、visual tokens、双向箭头、STATE 无箭头、360/390 宽度和状态标签不遮挡正文。执行 `flutter analyze`、定向测试、`flutter test`、`git diff --check`，并汇报真实 capability matrix 与 Git 状态。

