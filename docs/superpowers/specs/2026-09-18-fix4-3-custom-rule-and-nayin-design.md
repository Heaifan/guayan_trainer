# GUAYAN-R5-FIX4.3：正式规则执行闭环与六爻纳音恢复

## 目标

让已保存且启用的 CUSTOM Rule 进入正式 Case 重算的规则集合，完成 `RuleRun → DerivedEvidence → Review` 闭环；同时让伏神、主卦、变卦三类纳音从 Domain 唯一事实源传递到 Review 卦盘，保留点击与备注语义，不降低卦盘可读密度。

## 现状与根因调查范围

现有 Domain 已有 `lib/domain/rules/vocabulary/nayin_catalog.dart`，负责六十甲子到三十纳音的唯一映射；Review 已有 `ReviewCaseAdapter`、`ReviewLineView`、伏神计算和纳音布局测试。现有 `CaseRecomputeService.recomputeAnalysis` 能持久化 `AnalysisRun`，但当前应用重算入口 `lib/app/app_shell.dart` 复用最近一次 `RuleRun` 的结果与证据，没有从当前 Case 的系统规则、自定义启用规则或规则包选择重新构建并执行正式规则集合，因此会出现正式审卦 `RuleRun = 0` 或 `0/0`，即测试模式执行链与正式 Case 执行链脱节。

实施时必须用回归测试验证实际调用边界；若审计发现规则集合在更早层被清空，则按证据修正根因描述，不用 Review UI 补字符串。

## 设计

### 1. 正式规则选择和执行

- 新增/复用一个位于 `services/rules/` 的纯规则集合构建边界，输入当前 Case、规则库/规则包和用户选择，输出确定性有序的 `ExecutionRule` 集合及来源摘要。
- 正式重算使用这组规则构建 `AnalysisRun`，一次调用 RuleEngine；结果经 `RuleRun.fromAnalysis` 追加到 Case，而不是复用上一条 RuleRun 的结果。
- 系统基础规则与 enabled 的自定义规则均可进入集合；若规则包是当前架构的选择边界，则 Review 显示系统规则、自定义规则和总数，并保留重新计算按钮。
- “初爻子孙临青龙测试”正式 Case 回归测试必须断言匹配规则、`RuleRun` 计数和 OBJECT Evidence（道路、初爻、自定义规则）。
- OBJECT Evidence 不创建 Relation；“有路冲家”只有真实绑定关系成立时才产生 RELATION Evidence。

### 2. Trace 与显示文案

- 通过执行层和 Review 展示层分别计数，定位重复 Trace 是双执行还是重复渲染；修复源头并加入一次重算只产生一份规则 Trace 的测试。
- Predicate Trace 的 `actual` 使用事实快照解析后的真实中文值（例如“子孙”），而不是丢失绑定后的“未知”。
- `road` 继续作为稳定 tagId 存储，只在显示映射中呈现“道路”。

### 3. 三类纳音事实与语义元素

- 主卦和变卦分别由各自真实干支调用现有 `NaYinCatalog` 派生；变卦严禁复制主卦纳音。
- 伏神使用 `FushenResult` 自己的干支派生纳音；不存在伏神时不创建纳音元素、不占位。
- 扩展 Review line 状态/adapter 传递三类纳音及稳定对象身份（伏神/主卦/变卦及爻位），使纳音可继续进入现有 Semantic Element 点击、详情和备注路径。
- 卦盘行沿用正文下方的弱化第二级文本层，纳音字号和颜色弱于六亲/干支；不为没有纳音的区域制造额外空白高度。

### 4. 持久化与兼容

- 纳音若能由 Case 的稳定干支事实确定性派生，则不新增冗余 Case 字段；Case reload 后 adapter 必须得到同样纳音。
- 既有 RuleRun JSON、旧 Case JSON 和无伏神数据保持可读。
- 纯逻辑文件遵守不超过 150 行；若修改职责过大的现有文件，拆出具体功能文件并保留必要 barrel re-export。

## 测试验收

测试先行，至少覆盖：

- 正式 CUSTOM Rule 集合包含 enabled 自定义规则并成功持久化 `RuleRun`、OBJECT Evidence。
- 正式 RELATION 只在真实条件命中时产生关系 Evidence。
- Trace 不重复、Predicate actual 为真实值、道路显示中文化且 tagId 不变。
- 六十甲子到三十纳音映射、主卦六爻、变卦按变后干支、伏神有/无、主变独立、Case reload、Review adapter、Review UI 和纳音 Semantic Element 点击/备注。
- `flutter analyze`、定向 Rules/Case/Review 测试、`flutter test`、Release APK 构建。

## 明确不做

- 不改冒烟规则 JSON、FactSnapshot 或测试 Runtime 迁就正式执行。
- 不在 Review Widget 建第二份纳音表。
- 不把 OBJECT Evidence 转成 Relation，不制造假箭头。
- 不实现十二长生；R8 继续 BLOCKED。
