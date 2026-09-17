# G2-R4 Rule Folder Tree Design

## Goal

将现有用户规则包/自定义规则的扁平展示升级为可持久化的多级文件夹树，同时保持 RuleDefinition、AST、DSL、RuleId、Version 和历史 RuleRun 语义不变。

## Boundaries

文件夹是规则库管理元数据，不写入 RuleDefinition、PredicateExpr、DSL 或 AST。文件夹开关只决定以后规则运行时的有效集合，不修改规则自身 enabled，也不修改已经保存的历史 Case/RuleRun。

## Data model

新增 `RuleFolder`：

- `folderId`：稳定唯一 ID；
- `name`：展示名称；
- `parentFolderId`：根节点为 null；
- `enabled`：文件夹自身开关；
- `sortOrder`：同级排序。

新增 `RuleLibraryIndex`：

- 文件夹集合；
- `ruleId -> folderId` 归属映射；
- 文件夹展开状态；
- schema version。

`RuleDefinition.enabled` 是单条规则 enabled 的唯一真相源，索引不得复制该字段。

保留系统文件夹“未分类”和“导入规则”。首次加载没有归属的用户规则迁移到“未分类”，迁移只写索引，不改变规则 JSON。

保留文件夹使用稳定 ID；“未分类”禁止删除，“导入规则”允许重命名但不能改变 ID。文件夹行的规则数是所有后代文件夹的递归规则总数。任何 CUSTOM Rule 必须且只能有一个有效 folderId；悬空或缺失归属自动回落到“未分类”。

## Runtime behavior

规则实际是否参与新排卦：

```text
effectiveEnabled(rule) = rule.enabled
  && folder.enabled
  && every ancestor folder.enabled
```

关闭或开启文件夹不得批量改写子规则的自身 enabled。Runtime assembler 消费有效规则集合；历史 Case 继续使用保存时的 RuleRun，只有显式重算才生成新结果。

## Operations

文件夹支持创建、重命名、创建子文件夹、移动、展开/收起、启用/禁用和删除。移动禁止把节点移动到自身或任意后代。删除空文件夹直接确认；删除非空文件夹默认将内容移动到上一级，删除内容需要二次确认。

规则支持移动、启用/禁用、复制、编辑、删除、JSON 导入和导出。当前文件夹内导入默认归入当前文件夹；根页面导入归入“导入规则”。既有 Portable JSON schema 不变。

## UI

规则库页面以折叠树显示文件夹行和规则行：文件夹行包含展开箭头、名称、规则数量和开关；规则行包含名称、开关和操作菜单。创建、移动、复制、删除和导入等低频操作放入 `⋮` 菜单，保留当前移动端浅色视觉风格。

## Compatibility and migration

旧扁平规则数据可继续加载。索引不存在时创建默认根结构并将所有未归属用户规则放入“未分类”。SYSTEM 规则不被文件夹索引接管，现有 KnowledgeRule/ExecutionRule 入口保持不变。

## Verification

必须覆盖：模型序列化、旧数据迁移、嵌套树、循环保护、删除策略、文件夹开关继承、规则自身开关保留、重启持久化、导入目标文件夹、Runtime effectiveEnabled、RuleId/AST 不变和历史 Case 隔离；完成后执行完整 `flutter test`、`flutter analyze` 与 `git diff --check`。
