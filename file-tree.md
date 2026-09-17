# GUAYAN Trainer file tree

## v2.0.6 — 2026-09-18

- Last edited: 2026-09-18 05:03:34
- `docs/superpowers/specs/2026-09-18-rule-package-import-design.md` — G2-R3 JSON RulePack import and activation design.
- `docs/superpowers/plans/2026-09-18-g2-r3-rule-package-import.md` — G2-R3 implementation plan.

## G2-R3 JSON RULE PACK IMPORT (2026-09-18)

> 用户规则包支持 JSON 预览、校验、安装、全局启用、开关持久化与导出；本轮完成定向 UI 冒烟与静态检查，暂不执行全量回归。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/packages/ | Portable RulePack 模型、校验、导入、存储与全局启用注册表 |
| lib/services/rules/rule_package_file_adapter.dart | JSON 文件选择与导出适配 |
| lib/presentation/rules/rule_package_page.dart | 用户规则包导入预览、安装、启用/禁用与导出 UI |
| lib/presentation/rules/rule_library_page.dart | 规则库到用户规则包页面的入口 |
| test/domain/rules/packages/ | 规则包校验、持久化、激活与 JSON round-trip 测试 |
| test/presentation/rules/rule_package_page_test.dart | 导入预览与安装后的 UI 冒烟测试 |
| test/fixtures/external_test_pack.json | 外部规则包导入测试 fixture |

## G2-R4 RULE FOLDER TREE (2026-09-18)

> 用户规则库支持稳定文件夹树、递归规则计数、文件夹继承启停、规则移动、JSON 目标文件夹导入与安全删除；不改变 AST、DSL、RuleId、Version 或历史 RuleRun。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/library/rule_folder.dart | 稳定文件夹模型与保留文件夹 ID |
| lib/domain/rules/library/rule_library_index.dart | 文件夹树、规则归属、递归计数与循环保护 |
| lib/domain/rules/library/rule_library_store.dart | SharedPreferences 索引持久化 |
| lib/domain/rules/library/rule_library_service.dart | 迁移、CRUD、删除策略与索引归一化 |
| lib/domain/rules/library/effective_rule_selector.dart | Rule.enabled 与祖先文件夹开关的 Runtime 有效性计算 |
| lib/presentation/rules/rule_folder_tree_page.dart | 移动端规则树、导入、开关与文件夹操作入口 |
| lib/presentation/rules/widgets/rule_folder_tree.dart | 递归文件夹/规则行与操作菜单组件 |
| test/domain/rules/library/ | 文件夹模型、迁移、持久化、Runtime 规则选择测试 |
| test/presentation/rules/rule_folder_tree_test.dart | 树状 UI 与递归计数测试 |
| test/domain/rules/packages/rule_package_folder_target_test.dart | JSON 导入目标文件夹测试 |

- Android build version: `versionName 2.0.6`, `versionCode 47`
- FIX3 Focus-only review relation overlay package prepared for device installation.
- FIX4 relation ledger now presents Chinese endpoint semantics, painted relation glyphs,
  user-facing source/rule labels, and readable position/category filters.
- R7-FIX2 Ledger glyphs now render action text above a custom-painted arrow; review
  overlay routing uses focus-scoped topology lanes and semantic cell anchors.
- R7-FIX3 relation Ledger now shares the high-contrast relation palette and shows
  Chinese action text above every painted arrow, including bidirectional glyphs.
- ROUTER2-FIX2 aligns the review table and time-card in one overlay stack, keeps
  relation/state filtering shared, and routes main/main, main/changed, changed/changed,
  and calendar/yao relations through separate geometry regions.
- `lib/presentation/relations/relation_endpoint_presenter.dart` — Domain endpoint to
  Chinese display adapter.
- `lib/presentation/relations/widgets/relation_glyph.dart` — Canvas relation glyph;
  no Unicode arrow characters in the ledger UI.
- `docs/superpowers/specs/2026-09-18-case-library-design.md` — G0 卦例档案库设计与真实调用链审计。
- `lib/domain/cases/` — 不可变 CastingSnapshot、CaseRecord 与自包含 RuleRun 模型。
- `lib/services/cases/` — 卦例 JSON repository、查询、生成记录、元数据防抖与重算服务。
- `lib/presentation/cases/cases_page.dart` — 极简卦例库、筛选、分页、回收站与批量删除。
- `lib/services/cases/json_*_store.dart` — 神煞、关系与手工关系备注的 JSON 持久化适配。
- `test/services/cases/` — G1-G6 卦例持久化、查询、恢复、备注与重算回归测试。

## G2-R2 INTERNAL CONTINUATION (2026-09-18)

> Quantifier 后继续补齐结构事实与派生事实链；当前仍未进入 APK/手机验收。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/facts/derived_fact.dart | 稳定派生事实模型与证据来源 |
| lib/domain/rules/engine/derived_fact_producer.dart | StructureFact 到 DerivedFact 的确定性投影 |
| lib/domain/rules/facts/fact_snapshot.dart | 不可变快照承载结构事实与派生事实 |
| lib/domain/rules/engine/operators/structure_operators.dart | 结构成立事实的 Runtime 消费 |
| lib/domain/rules/editor/rule_mapping_table.dart | 稳定规则值到用户取象文本的只读映射 |
| lib/domain/rules/editor/custom_shen_sha_definition.dart | USER 神煞定义模型 |
| lib/domain/rules/editor/custom_shen_sha_store.dart | USER 神煞 JSON 持久化与引用删除保护 |
| test/domain/rules/derived_fact_test.dart | 派生事实 ID、类型、值与证据回归 |
| test/domain/rules/structure_operator_test.dart | StructureFact 到 Runtime 条件闭环 |
| test/domain/rules/editor/rule_mapping_table_test.dart | 映射表稳定值与展示文本测试 |
| test/domain/rules/editor/custom_shen_sha_store_test.dart | 自定义神煞存储与删除保护测试 |

## G2-R2 EDITOR CLOSURE (2026-09-18)

| 文件/目录 | 职责 |
| --- | --- |
| lib/presentation/rules/rule_editor_page.dart | 范围/量词、结构条件、自定义神煞入口接线 |
| lib/domain/rules/editor/rule_visual_renderer.dart | QuantifiedExpr 与结构条件可视化投影 |
| test/domain/rules/editor/r2_round_trip_gate_test.dart | 新 AST 能力 Codec round-trip 门禁 |
| test/domain/rules/r2_golden_corpus_test.dart | 60 条 SYSTEM 规则 Portable JSON golden corpus |

# 妞ゅ湱娲伴弬鍥︽閺?閳?閸楋妇婧傜拋顓犵矊閸?

## P0 真机排卦修复 HOTFIX-R1 神煞引擎 (2026-09-17)

> 冻结 `shensha.standard.v1` 规则集：排卦生成时计算并写入 CalendarSnapshot，审卦页只读；含 19 项结果、Golden A/B 与审卦紧凑展示。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/shensha/shensha_models.dart | 神煞计算上下文与可序列化结果模型 |
| lib/domain/shensha/shensha_tables.dart | 已确认的天干、三合局、月支规则表 |
| lib/domain/shensha/shensha_engine.dart | 纯 Dart 神煞确定性计算引擎 |
| lib/domain/calendar_snapshot.dart | 保存神煞结果快照并支持序列化 |
| lib/services/calendar/casting_calendar_service.dart | 生成排盘时计算并回写神煞快照 |
| lib/presentation/review/review_case_adapter.dart | 将快照结果投影为审卦展示模型 |
| lib/presentation/review/widgets/review_shensha_card.dart | 固定 150dp、4×5 同屏神煞网格与点击入口 |
| lib/presentation/review/widgets/review_basic_info_card.dart | 紧凑问事、公历与农历展示，不显示规则包元信息 |
| lib/presentation/review/widgets/review_time_card.dart | 四柱与“(地支空)”旬空展示 |
| lib/domain/shensha/shensha_note_store.dart | 以 caseId + 神煞 ID 隔离的卦例备注存储 |
| lib/presentation/review/widgets/review_shensha_detail_dialog.dart | 神煞全文查看与备注编辑弹窗 |
| lib/domain/casting/fushen.dart | 伏神结构化事实模型与规则证据字段 |
| lib/domain/casting/fushen_engine.dart | 按本宫首卦计算一个或多个伏神 |
| lib/domain/casting/double_fucang.dart | 全宫双伏藏结果与逐爻隐藏宫线模型 |
| lib/domain/casting/double_fucang_engine.dart | 本宫纯卦与对宫纯卦 6+6 双伏藏引擎 |
| lib/domain/casting/hexagram_palace_profile.dart | 八宫阶段、世爻与应爻结构化分类模型 |
| lib/presentation/review/widgets/line_identity_text.dart | 主卦、变卦、伏神统一纳甲五行着色 |
| lib/presentation/review/widgets/board_column_layout.dart | 卦盘表头与六爻行共用的固定列坐标 |
| lib/presentation/review/widgets/hexagram_line_cell.dart | 主卦与变卦共用的镜像固定文本、世应与爻象槽 |
| test/domain/shensha/shensha_golden_fixture.dart | Golden A/B 输入与期望值 |
| test/domain/shensha/shensha_engine_test.dart | 引擎规则、顺序、序列化回归测试 |
| test/presentation/review/review_shensha_adapter_test.dart | 生成快照到审卦展示接线测试 |
| test/presentation/review/review_shensha_card_test.dart | 神煞固定高度与 4×5 同屏 UI 测试 |
| docs/r5/shensha-catalog-audit.md | 神煞 Catalog 确认状态与验证记录 |

> **当前应用版本：** 2.0.5+46（pubspec.yaml）
> **最后编辑时间：** 2026-09-18 03:35:27

---

## P0 真机排卦修复 HOTFIX-R2 / R3 (2026-09-17)

> 统一农历真实结果与排卦/审卦快照链；静卦不生成变卦；审卦补齐 Engine 已有纳甲干支投影。不扩展神煞、规则中心或训练模块。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/calendar/lunar_calendar.dart | 离线公历→农历确定性转换 |
| lib/domain/calendar/lunar_year_data.dart | 2019–2029 农历年度编码与春节日期 |
| lib/domain/calendar/calendar_pillars.dart | 快照年柱、时柱及纳音推导 |
| lib/domain/calendar_snapshot.dart | 保存农历日期、时辰、月建与日辰快照 |
| lib/services/calendar/casting_calendar_service.dart | 生成一次排卦共用的历法快照 |
| lib/presentation/casting/casting_page_state.dart | 排卦页农历展示适配 |
| lib/presentation/review/review_case_adapter.dart | 快照、纳甲干支与旬空事实投影 |
| lib/presentation/review/review_page_state.dart | 旬空标记展示派生 |
| lib/presentation/review/widgets/review_hexagram_line_row.dart | 六爻行、动爻符号与无箭头布局 |
| lib/presentation/shared/moving_marker.dart | 老阳○ / 老阴× 动爻符号 |
| docs/r5/shensha-catalog-audit.md | 神煞算法与来源审计、待确认 Catalog |
| test/domain/calendar/lunar_calendar_test.dart | 农历转换与时区独立性回归 |

> **当前应用版本：** 2.0.0+41（pubspec.yaml）
> **R5 开发基线：** R5-G2-D0 SYSTEM KNOWLEDGE RULE CENTER MVP
> **最后编辑时间：** 2026-09-18 00:09:14

> 请在每一次新增、重命名、删除文件后，或者发版时，更新本文件。
> 作为 AI 请记住：不要只修改内容，确保本文件的最后编辑时间也一并更新。

---

## R5-G2-C2 SYSTEM KNOWLEDGE CATALOG V1 分类治理 (2026-09-17)

> 建立 12 个用户知识一级分类，为 10 条 SYSTEM KnowledgeRule 补充唯一 Primary Category 与 Tags；JSON/Markdown 均从同一 Catalog 生成，不修改技术分类、Engine、DSL、AST 或规则语义。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/knowledge/system_knowledge_category_catalog.dart | 12 个用户知识一级分类的唯一权威定义源 |
| lib/domain/rules/knowledge/knowledge_rule.dart | KnowledgeRule 的用户层 Primary Category 与 Tags 元数据 |
| lib/domain/rules/knowledge/system_knowledge_rule_catalog.dart | 10 条 SYSTEM KnowledgeRule 的冻结分类与标签映射 |
| lib/domain/rules/knowledge/knowledge_rule_catalog_validator.dart | Primary Category 引用完整性与既有 Catalog 门禁 |
| tool/knowledge_catalog_audit_*.dart | 从领域 Catalog 同源生成分类与规则审计 JSON/Markdown |
| test/domain/rules/knowledge/system_knowledge_category_catalog_test.dart | 12 分类、10 条映射与 Tags 门禁 |
| docs/knowledge/system-knowledge-catalog-v1-audit.* | 同源机器可读与 Markdown 审计产物 |

## R5-G2-D0 SYSTEM KNOWLEDGE RULE CENTER MVP (2026-09-17)

## R5-G2-D0 SYSTEM KNOWLEDGE RULE CENTER MVP (2026-09-17)

> 规则中心首页以 KnowledgeRule 为一级对象，按真实 RuleVariant 中文名动态分组；详情页展示 N 个 Variant 与 N 条 ExecutionRule；保留 Loader、自定义规则 CRUD 与 SYSTEM 数据层不变。

| 文件/目录 | 职责 |
| --- | --- |
| lib/presentation/rules/presentation/knowledge_rule_display_model.dart | KnowledgeRule 首页展示模型与搜索文本 |
| lib/presentation/rules/presentation/knowledge_rule_presentation_mapper.dart | KnowledgeRule Catalog 到展示模型的适配与搜索 |
| lib/presentation/rules/system_rule_list_page.dart | 10 个 KnowledgeRule 首页、动态 Variant 分组与入口 |
| lib/presentation/rules/knowledge_rule_detail_page.dart | KnowledgeRule、Variant、ExecutionRule 分层详情 |
| test/presentation/rules/knowledge_rule_*_test.dart | 展示适配、动态分组、搜索与详情 Widget 测试 |

## R5-G2-D0.2 RULE LIBRARY ROUTE CLOSURE HOTFIX (2026-09-17)

> 收口规则库用户入口：SYSTEM 只进入 10 条 KnowledgeRule；旧 ExecutionRule 列表仅保留自定义规则 CRUD 能力；详情执行实例改为只读展示并移除选择控件视觉。

| 文件/目录 | 职责 |
| --- | --- |
| lib/pages/home/home_page.dart | 首页规则入口统一跳转规则库 |
| lib/presentation/rules/rule_library_page.dart | 规则库唯一用户入口与 SYSTEM/自定义分流 |
| lib/presentation/rules/system_rule_list_page.dart | KnowledgeRule 系统规则目录与自定义规则入口 |
| lib/presentation/rules/rule_center_page.dart | 仅承载自定义规则 CRUD，不再展示 SYSTEM ExecutionRule 列表 |
| lib/presentation/rules/knowledge_rule_detail_page.dart | 只读执行实例展示，移除 Radio 视觉语义 |
| test/presentation/rules/rule_library_page_test.dart | SYSTEM 唯一入口与自定义入口隔离回归测试 |
| test/presentation/rules/knowledge_rule_detail_page_test.dart | 执行实例无 Radio/Checkbox/Switch 回归测试 |

## R5-R6 VISUAL TOKEN RULE IDE V1 (2026-09-18)

> 以现有 AST 与 Runtime 为唯一事实源，把自定义规则编辑器收口为 AST 驱动的 Token 可视化编辑器；普通模式不再以多行代码输入作为状态，Token 选择通过依赖约束的 Bottom Sheet 修改 AST 并自动渲染缩进。未伪造未被 Runtime 支持的条件能力。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/editor/condition_catalog.dart | 13 个真实 Runtime operator 的唯一条件能力目录与搜索 |
| lib/domain/rules/editor/portable_rule_codec.dart | RuleDefinition Portable JSON V1 编解码 |
| lib/domain/rules/editor/rule_visual_renderer.dart | RuleDefinition AST 到只读 Token 行的纯渲染投影 |
| lib/presentation/rules/rule_editor_page.dart | 浅色 Token 编辑器、对象/属性/值选择、AST 撤销重做与 JSON 导入导出 |
| lib/domain/rules/dsl/dsl_lexer.dart | 修正“取象”多字中文 DSL 关键字识别 |
| test/domain/rules/editor/condition_catalog_test.dart | 条件目录唯一性、Runtime 能力与搜索测试 |
| test/domain/rules/editor/portable_rule_codec_test.dart | Portable JSON schema 与 round-trip 测试 |
| test/domain/rules/editor/rule_visual_renderer_test.dart | AST 逻辑节点、缩进、用户文案与技术 ID 隔离测试 |
| test/presentation/rules/rule_editor_page_test.dart | Token 编辑器主界面回归测试 |

## G2-C CONDITION RUNTIME COMPLETION (2026-09-18)

> 收敛技术 Operator 与用户条件语义：隐藏 `empty` 兼容别名、统一 `in_tomb` 为“在库”，条件添加入口从硬编码改为 Runtime-backed Catalog；补齐关系/标签条件入口、搜索，以及六亲/六神/30 项纳音值目录的中文显示。

| 文件/目录 | 模块职责 |
| --- | --- |
| lib/domain/rules/editor/condition_catalog.dart | 当前 21 个用户条件的 Runtime-backed 条件目录；不暴露 `empty` 兼容别名 |
| lib/domain/rules/editor/rule_value_catalog.dart | 六亲、六神、30 项纳音的稳定 ID 与中文显示映射 |
| lib/presentation/rules/rule_editor_page.dart | 从条件目录生成选择器，支持关系/标签条件、搜索与结构化绑定 |
| test/domain/rules/editor/rule_value_catalog_test.dart | 值目录完整性与技术 ID 隔离回归 |
| docs/superpowers/plans/2026-09-18-condition-runtime-completion.md | G2-C 分阶段实施计划 |

## G2-D FOUNDATIONAL CONDITION RUNTIME (2026-09-18)

> 保留既有 `tomb` 技术 ID，仅将用户文案与 DSL 显示统一为“库”；新增并注册天干为、地支为、五行为，以及五行克、地支冲合刑害破 Evaluator，并由 ConditionCatalog 自动暴露。

| 文件/目录 | 模块职责 |
| --- | --- |
| lib/domain/rules/engine/operators/foundational_operators.dart | 基础属性事实比较、五行克与地支冲合刑害破 Evaluator |
| lib/domain/rules/vocabulary/condition_id.dart | 新增基础属性与地支关系 canonical operator ID |
| lib/domain/rules/vocabulary/condition_registry.dart | 新增条件参数形状与值策略定义 |
| lib/domain/rules/editor/condition_catalog.dart | 将 9 个真实 Runtime 条件自动加入用户目录 |
| lib/domain/rules/dsl/dsl_vocabulary.dart | 新增属性/关系及“库”用户文案映射 |
| lib/domain/dsl/parser/dsl_pattern_matcher.dart | 新旧墓库 DSL 文案兼容解析 |
| test/domain/rules/engine/foundational_operator_test.dart | 属性与生克冲合刑害破 Evaluator 测试 |

## R5-G2-E1 TEMPLATE FOUNDATION (2026-09-18)

> 建立编辑期强类型模板、Slot、Invocation、Validation 与 Compiler Registry；现有 Rule AST、Runtime、UI、DSL 与持久化保持不变。

| 文件/目录 | 模块职责 |
| --- | --- |
| lib/domain/rules/templates/rule_slot_definition.dart | Object、Property、Value、State、Relation 强类型 Slot 定义与值对象 |
| lib/domain/rules/templates/template_definition.dart | 模板分类、句式、Slot 与投影定义 |
| lib/domain/rules/templates/template_invocation.dart | 已填充模板的编辑期调用模型 |
| lib/domain/rules/templates/template_validation.dart | Slot 完整性、类型与值目录匹配校验 |
| lib/domain/rules/templates/template_compiler.dart | Template 到现有 RuleExpr 的编译契约 |
| lib/domain/rules/templates/template_compiler_registry.dart | 四个基础模板的独立编译器注册表 |
| lib/domain/rules/templates/template_catalog.dart | property/state/wuxing relation/branch relation 四个基础模板 |
| test/domain/rules/templates/template_foundation_test.dart | 模板 Slot、非法组合、projection 与 AST 编译门禁 |

## R5-G2-E2 PICKER ROUTER (2026-09-18)

> 以 PickerRequest → PickerRouter → PickerResult 统一编辑期选择路由；值目录、状态、关系与当前固定对象均由 domain 层决定，BottomSheet 仍由现有页面负责显示。

| 文件/目录 | 模块职责 |
| --- | --- |
| lib/domain/rules/editor/pickers/picker_request.dart | Slot 类型、catalogId、当前值与允许值的选择请求 |
| lib/domain/rules/editor/pickers/picker_result.dart | 统一选择结果与显示文本 |
| lib/domain/rules/editor/pickers/picker_catalog.dart | 天干、地支、五行、六神、六亲、纳音、状态、关系、固定对象目录 |
| lib/domain/rules/editor/pickers/picker_router.dart | 按 SlotType/catalogId 路由选择目录，未知目录失败关闭 |
| lib/presentation/rules/rule_editor_page.dart | 渐进迁移对象、属性和值选择到 PickerRouter，保留现有 BottomSheet |
| test/domain/rules/editor/picker_router_test.dart | 值目录、属性联动、状态/关系目录与未知目录门禁 |

## R5-G2-E2.5 BASE RULE END-TO-END GATE (2026-09-18)

> 验证模板、Picker、编译器、现有 AST、持久化、DSL 与 Runtime 的闭环；仅做最小接通，不引入 E3 动态对象、范围或量词能力。

| 文件/目录 | 模块职责 |
| --- | --- |
| lib/presentation/rules/rule_editor_page.dart | 四个已模板化条件族通过 TemplateInvocation/CompilerRegistry 创建 AST；legacy 条件保留旧路径 |
| lib/domain/dsl/formatter/dsl_expr_formatter.dart | 基础属性 DSL 输出补充分隔，保证属性 AST round-trip |
| test/domain/rules/e2_5_base_rule_gate_test.dart | 属性、状态、五行/地支关系的编译、持久化、DSL 与 Runtime 闭环测试 |

## R5-G2-E3 DYNAMIC OBJECT FOUNDATION (2026-09-18)

> 在 Binding 层增加稳定的动态对象选择器与解析器；支持六神所临之爻、世爻、应爻、发动候选集及地支关系候选集，many 结果不隐式转为单对象。

| 文件/目录 | 模块职责 |
| --- | --- |
| lib/domain/rules/ast/binding_selector.dart | 保持 Direct/Relative 兼容并新增 DynamicBindingSelector |
| lib/domain/rules/objects/dynamic_object_definition.dart | 动态对象定义与 exactlyOne/zeroOrOne/many cardinality |
| lib/domain/rules/objects/dynamic_object_catalog.dart | 第一批动态对象稳定 ID、名称与参数定义 |
| lib/domain/rules/objects/dynamic_object_resolver.dart | 从 FactSnapshot 解析动态对象与候选集合，拒绝隐式选第一项 |
| lib/domain/rules/engine/binding_resolver.dart | 将 DynamicBindingSelector 接入既有 BindingContext |
| lib/domain/rules/editor/rule_definition_codec.dart | Dynamic Binding JSON 编解码，保留旧 Direct/Relative 格式 |
| lib/domain/rules/editor/pickers/picker_catalog.dart | 动态对象与动态参数目录 |
| lib/domain/rules/editor/pickers/picker_router.dart | 动态对象 Picker 路由 |
| lib/presentation/rules/rule_editor_page.dart | 固定/动态对象选择与 many 结果阻止提示 |
| test/domain/rules/dynamic_object_test.dart | 动态解析、候选集合、关系查询、持久化与旧格式兼容测试 |

## R5-G2-C1 SYSTEM KNOWLEDGE CATALOG AUDIT (2026-09-17)

> 从真实 SYSTEM ExecutionRule、现有 KnowledgeRule Catalog 与 RuleVariant 映射生成 60 行 Markdown/JSON 审计基线；不修改知识语义、Runtime 或 UI。

| 文件/目录 | 职责 |
| --- | --- |
| tool/knowledge_catalog_audit.dart | 开发期生成器入口，写出同源 Markdown/JSON |
| tool/knowledge_catalog_audit_model.dart | 审计 Catalog 与行模型 |
| tool/knowledge_catalog_audit_builder.dart | 从真实 Corpus/Catalog 构建审计行 |
| tool/knowledge_catalog_audit_render.dart | Markdown/JSON 渲染器 |
| docs/knowledge/system-knowledge-catalog-v1-audit.md | 60 条人工审计主表与证据 |
| docs/knowledge/system-knowledge-catalog-v1-audit.json | 机器可读 60 条 Catalog |
| test/tool/knowledge_catalog_audit_test.dart | 行数、唯一性与 Markdown/JSON 同源校验 |

## R5-G2-A/B KNOWLEDGE RULE DOMAIN MODEL (2026-09-17)

> 建立排卦知识规则、规则变体、ExecutionRule 引用与 SYSTEM 显式 Catalog；不改变 Engine、DSL、AST 与 COMMON 保存边界。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/knowledge/ | KnowledgeRule、RuleVariant、ExecutionRuleRef、分类与 SYSTEM Catalog |
| lib/domain/rules/knowledge/knowledge_rule_catalog_validator.dart | 知识规则身份、变体、引用与 SYSTEM 覆盖校验 |
| lib/domain/rules/knowledge/system_knowledge_rule_catalog.dart | 当前 60 条 SYSTEM ExecutionRule 的显式知识语义映射 |
| test/domain/rules/knowledge/ | 领域模型、Catalog、覆盖、验证器与运行时不变性测试 |

## R5-G1 RULE CENTER UI / SCHEME A (2026-09-17)

> 规则中心中文化、分类化、系统规则只读详情与自定义规则编辑入口重构；不修改 Engine、DSL、AST 与 COMMON 保存边界。

| 文件/目录 | 职责 |
| --- | --- |
| lib/presentation/rules/presentation/ | 规则展示模型、中文名称/分类/说明映射 |
| lib/presentation/rules/system_rule_list_page.dart | 系统规则搜索、分类和启用列表 |
| lib/presentation/rules/rule_detail_page.dart | 系统规则只读详情与中文 DSL 展示 |
| lib/presentation/rules/widgets/ | 搜索栏、入口卡片、分类筛选、规则卡片、DSL 预览与编辑入口卡片 |
| test/presentation/rules/ | 规则中心首页、列表、详情、编辑器与展示映射测试 |

## R5-G BASELINE RECOVERY (2026-09-17)

> 收口排卦领域模型、DSL Runtime、COMMON 保存边界与 Gate A 基线；不新增业务功能。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/paipan/ | 六十四卦身份、八卦、八宫与干支领域模型 |
| lib/domain/rules/dsl/ | 中文 DSL Lexer、Parser、Formatter 与 Runtime 规则体 |
| test/domain/paipan/ | 排卦领域模型契约测试 |
| test/domain/rules/dsl/ | DSL 解析、往返与引擎连通测试 |
| test/domain/rules/editor/custom_rule_save_boundary_test.dart | COMMON/TOPIC/未知 namespace 保存边界测试 |
| tool/gate_a/gate_a_runner.ps1 | 按环境变量或 PATH 解析 Flutter SDK，不依赖固定盘符 |







## R5-FIX-01 COMMON Custom Rule Save Boundary (2026-09-16)

> COMMON 自定义规则走正式 save 链；TOPIC 仍走 Topic 边界校验；未知 namespace 拒绝。

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/editor/custom_rule_save_boundary.dart | save 路径按 namespace 分发 COMMON / Topic 边界校验 |
| lib/domain/rules/editor/custom_rule_service.dart | 保存前调用分发器，不再无条件走 Topic 校验 |
| test/domain/rules/editor/custom_rule_save_boundary_test.dart | 必须经 CustomRuleService.save 的四条边界测试 |

## R5-G Final Correction (2026-09-16)

> App Entry & Runtime Assembly

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/engine/runtime_rule_set_assembler.dart | 正式运行环境下的规则集成枢纽 |
| lib/presentation/rules/rule_center_page_loader.dart | 隔离的异步数据加载包裹层 |

## R5-G CUSTOM Rule CRUD + VISUAL EDITOR V1 (2026-09-16)

> CUSTOM CRUD, Rule Center, Visual Editor, Formatter Preview, Runtime Integration

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/editor/ | 编辑器状态与持久化 |
| lib/presentation/rules/ | 可视化规则编辑器 UI |

## R5-F Topic Pack Mechanism (2026-09-16)

> Topic Pack Mechanism, Exam Demo, Composer

| 文件/目录 | 职责 |
| --- | --- |
| lib/domain/rules/topics/topic_pack_composer.dart | Composer |
| lib/domain/rules/topics/topic_rule_boundary_validator.dart | Boundary Validator |
| lib/domain/rules/topics/exam/exam_rule_corpus.dart | Exam rule corpus |
| test/domain/rules/topics/topic_pack_composer_smoke_test.dart | Composer test |
| test/domain/rules/topics/exam/exam_integration_smoke_test.dart | Integration test |

## R5-E Common v1 (2026-09-15)

> 记录 COMMON v1, 36 SYSTEM Rules, 6 Rule Families, Resolver Integration, Engine Integration

| 文件/目录 | 职责 |
| --- | --- |
| `lib/domain/rules/corpus/common_rule_corpus.dart` | R5-E Common v1 36 个 SYSTEM Rules 工厂 |
| `test/domain/rules/corpus/common_rule_corpus_test.dart` | Common v1 冒烟与集成测试 |

---

## R5-D Rule Governance (2026-09-15)

> SYSTEM/CUSTOM 规则治理、版本冲突处理、解析与覆写、引擎集成。

| 文件/目录 | 职责 |
| --- | --- |
| `lib/domain/rules/governance/rule_resolver.dart` | 规则系统统一解析入口 |
| `lib/domain/rules/governance/rule_override_resolver.dart` | 规则覆写(CUSTOM -> SYSTEM)和有效性过滤逻辑 |
| `lib/domain/rules/core/rule_version.dart` | 规则版本控制，严格 SemVer 比较 |
| `test/domain/rules/governance/` | 治理逻辑测试 |

---

> 瑙ｅ喅 R5-B 鏈熼棿浜х敓鐨?5+100 琛屾暟闄愬埗鎶ラ敊锛屾媶鍒嗕簡 rule_engine, stage_runner, action_executor, operators 绛夎繃澶х殑鏂囦欢銆傚悓鏃惰褰曚簡 R5-B 涓殑娌荤悊浜嬫晠锛歜ulk replace, multiple restores/checkouts, broad adds, premature commits, amend 绛夌瓑銆?

### 瑙勫垯鎵ц寮曟搸 (lib/domain/rules/engine/)

| 鏂囦欢/鐩綍 | 鑱岃矗 |
| --- | --- |
|
ule_engine.dart | 澶栬妯″紡锛岃鍒欏紩鎿庡叆鍙?|
| nalysis_stage_executor.dart | 璐熻矗閬嶅巻鍚勪釜闃舵鎵ц |
| stage_runner.dart | 璐熻矗鍗曚釜闃舵(Stage)鍐呯殑澶氭杩唬(Fixpoint convergence) |
| stage_iteration_runner.dart | 璐熻矗鎵ц涓€娆″唴閮ㄥ惊鐜殑姹傚€煎拰鍚堝苟杩囩▼ |
| ction_executor.dart | 鏍规嵁瑙勫垯鐨勭粨鏋滃垎鍙戝叿浣撳姩浣?|
| ction_output_factory.dart | 鍒嗙 Action 鐨勫垱寤哄拰鎵ц |
| operators/structural_operators.dart | barrel 瀵煎嚭 |
| operators/fact_operators.dart | 浜嬪疄绫荤畻瀛?relative, spirit, nayin) |
| operators/relation_operators.dart | 鍏崇郴绫荤畻瀛?generate, ru_mu 绛? |
| operators/state_operators.dart | 鐘舵€佺被绠楀瓙(xun_kong 绛? |
| operators/tag_operator.dart | 鏍囪绫荤畻瀛?has_tag) |
| ... | 鍏朵粬鎵ц鍣ㄧ浉鍏?|

## R5-A 璺?Rule Schema + AST + Core Domain (2026-09-14)

> 閺嬪嫬缂撻崗顓犲煝鐟欏嫬鍨鏇熸惛閻╃鍙ч惃?Canonical Domain Contract閿涘湩ule Schema閵嗕竸ST閵嗕笚actSnapshot閵嗕阜ulePack閵嗕笒vidence缁涘绱氶妴鍌涙拱鏉烆喚鍑介弫鐗堝祦婵傛垹瀹抽敍灞炬￥閹笛嗩攽瀵洘鎼哥€圭偟骞囬妴?

### 閺傛澘顤冪憴鍕灟濡€崇€风仦?(`lib/domain/rules/`)

| 閺傚洣娆?閻╊喖缍?| 閼卞矁鐭?|
| --- | --- |
| `core/rule_definition.dart` 缁?| 鐎规矮绠熼崡鏇氱鐟欏嫬鍨紒鎾寸€妴渚€妯佸▓?(RuleStage)閵嗕焦娼靛┃?(RuleOrigin) |
| `ast/rule_expr.dart` 缁?| AST 缂佹挻鐎懞鍌滃仯 (ALL/ANY/NOT/PREDICATE) 閸欏﹤鍙剧紒鎴濈暰缁崵绮?|
| `facts/fact_snapshot.dart` 缁?| 瀵桨绗夐崣顖氬綁閸樼喎顫愭禍瀣杽鐠佹澘缍嶉崣濠咁嚔娑斿鐖ｇ拠?(SemanticRef) |
| `packs/rule_pack.dart` 缁?| 缂佸嫬鎮庣憴鍕灟閻?RulePack 婵傛垹瀹抽崣?COMMON/TOPIC 娴ｆ粎鏁ら崺鐔兼閸?|
| `evidence/evidence_node.dart` 缁涘 Evidence Identity 娴犮儱寮?`TagIdentity` 閻ㄥ嫯闊╂禒钘夘殩缁?|
| `data/rules/codec/` 娑?`schema/` | RuleCodec (Canonical JSON 缁涘鐜紓鏍掗惍? 閸?Validator 閸楃姳缍呯€圭偟骞?|

---

## R4 璺?閸╄櫣顢呴崗宕囬兇瀵洘鎼搁敍?026-09-13閿涘本婀崣鎴濈閿?
> 鐠囷妇绮忔總鎴犲鐟?`lib/domain/README.md` 閻ㄥ嫨鈧4 璺?閸╄櫣顢呴崗宕囬兇瀵洘鎼搁妴宥勭閼哄倶鈧?

### 閸愯崵绮ㄦ總鎴犲閿涘牏鏁ら幋閿嬪閸戝棴绱?

```text
1. 娴滄棁顢戦惄鍝ユ晸/閻╃鍘?= 閺堫剙宕烽崗顓犲煝娑撱倓琚辩粚铚傚 C(6,2)=15 鐎电櫢绱遍崥灞肩安鐞涘奔绗夋禍褍鍤妴?
   R4 閺勵垬鈧奔绨ㄧ€圭偠澶勯張顑锯偓宥忕礉娑撳秴鍨介弬顓濈稊閻劌濮?閳ユ柡鈧?娴ｆ粎鏁ら崝娑楁唉缂佹瑥鎮楃紒?Effect / Rule 鐏炲倶鈧?
   UI 閻劎鐡柅澶婃珤閹貉冨煑閸欘垵顫嬮崗宕囬兇閿涘奔绗夊妞捐礋閸ラ箖娼扮粻鈧ú浣稿冀閸氭垼顥嗛崜?Domain 閺佺増宓侀妴?
2. 閺傛澘顤?RelationEndpoint 妫板棗鐓欑粩顖滃仯閹跺€熻杽閿涘澃ealed閿涘绱伴悥?/ 閺堝牆缂?/ 閺冦儴鏅妴?
   RelationKey 閻?source/target 韫囧懘銆忕悰銊с仛閻喎鐤勭拠顓濈疅鐎电钖勯敍?
   缁備焦顒涙稉娲姜閻栬顕挒鈥冲煑闁姾娅勯崑?position閿涘牅绗夐崘?month-1閿涘鈧?
   LineEndpoint 闂勫秶楠囨稉铏圭帛缁惧灝鐣炬担宥呯湴缁鐎烽敍灞肩瑝閸愬秵妲搁煬顐″敜閻喐绨妴?
3. HexagramCase 閹镐焦婀侀崣顖炩偓?CalendarSnapshot閿涘牊婀€瀵ょ儤鏁?+ 閺冦儴鏅獮鍙夋暜閿涘鈧?
   鐎涙ǜ鈧矁鎹ｉ崡锕€缍嬮弮鎯邦吇鐎规氨娈戠紒鎾寸亯閵嗗稄绱濇稉宥呯摠鐠侊紕鐣婚崳?閳ユ柡鈧?閺佺増宓侀崠鍛磳缁狙傜瑝瀵版顔€閸樺棗褰堕崡锔跨伐閺堝牆缂撳鍌溞╅妴?
   calendar 缂傚搫銇?閳?閺?閺冦儱鍙х化璁崇瑝娴溠冨毉 + 鐠囧﹥鏌囬幎銉ユ啞缂傚搫銇戦敍娑氼洣濮濄垼鍤滈崝銊ㄋ夌粻妞尖偓?
```

### 閺傛澘顤?

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `lib/domain/relation_endpoint.dart` | 閸忓磭閮寸粩顖滃仯妫板棗鐓欓煬顐″敜閿涘澃ealed閿涙瓛aoEndpoint / MonthEndpoint / DayEndpoint閿?|
| `lib/domain/line_scope.dart` | 閸楋缚鏅堕敍鍫熸拱閸?/ 閸欐ê宕烽敍澶嗏偓鏂衡偓?妫板棗鐓欏鍌氬悍閿涘瞼瀚粩瀣灇閺傚洣娆㈡笟娑氼伂閻愰€涚瑢缂佹鍤庣仦鍌氬彙閻?|
| `lib/domain/calendar_snapshot.dart` | 鐠у嘲宕疯ぐ鎾存閻ㄥ嫬宸诲▔鏇炴彥閻撗嶇礄閺堝牆缂撻弨?+ 閺冦儴鏅獮鍙夋暜閿?|
| `lib/domain/relation_diagnostics.dart` | 閸忓磭閮寸拋锛勭暬鐠囧﹥鏌囬敍鍧ssingInputs / warnings閿?|
| `lib/domain/relation_rules/changed_lines.dart` | 閸斻劌褰?璺?閸ョ偛銇旈悽?璺?閸ョ偛銇旈崗?|
| `lib/domain/relation_rules/branch_pairs.dart` | 閸忣厼鍟?璺?閸忣厼鎮庨敍鍫熸暭閻?`DiZhi.chong/he`閿涘苯鍨归幒澶庡殰鐢附妲х亸鍕€冮敍?|
| `lib/domain/relation_rules/wu_xing_pairs.dart` | 娴滄棁顢戦惄鍝ユ晸 璺?閻╃鍘犻敍鍫濆彋閻栬琚辨稉銈忕礉娴滃鐤勭拹锔芥拱閿?|
| `lib/domain/relation_rules/month_day.dart` | 閺堝牆缂?/ 閺冦儴鏅崺铏诡攨娴ｆ粎鏁?|
| `lib/domain/relation_rules/rule_support.dart` | 鐟欏嫬鍨崗杈╂暏閿涘澁eplay 閻楀牊婀伴崣鏍р偓?/ 閸︾増鏁憴锝嗙€?/ 缁旑垳鍋ｉ弸鍕偓鐙呯礆 |
| `test/domain/relation_engine_r4_test.dart` | 娑旀繄琚崗宕囬兇缂佸嫭鍨?+ 缁旑垳鍋ｆ稉宥呭綁闁?|
| `test/domain/relation_engine_r4_facts_test.dart` | 娴滄棁顢戞禍瀣杽閸忓磭閮?+ 閺堝牆缂?閺冦儴鏅紒鍕灇 |
| `test/domain/relation_engine_r4_inputs_test.dart` | 缂傚搫銇戞潏鎾冲弳鐠囧﹥鏌?+ 绾喖鐣鹃幀褍顨栫痪?|

### 娣囶喗鏁?

- `lib/domain/relation_calculator.dart`閿涙碍鏁兼稉?R4 缂傛牗甯撻敍鍫濇磽缁槒顫夐崚娆忔値楠炶翰鈧恭anonical 缁嬪啿鐣鹃幒鎺戠碍閵?
  闁插秴顦?key 鐠€锕€鎲￠妴浣哄繁婢惰精绶崗銉ㄧ槚閺傤叏绱氶敍灞借嫙娣囨繄鏆€ `calculateRelations()` 閸忕厧顔愰崗銉ュ經
- `lib/domain/relation_type.dart`閿涙碍鏌婃晶?`sys.month_branch` / `sys.day_branch` 鐟欏嫬鍨?id
- `lib/domain/line_state.dart`閿涙碍鏌婃晶鐐插讲闁?`changedBranch`閿涘牆褰夐悥璇叉勾閺€顖ょ礉閸ョ偛銇旈悽?閸忓绻€闂団偓閿?
- `lib/domain/hexagram_case.dart`閿涙碍鏌婃晶鐐插讲闁?`calendar`閿涘牆宸诲▔鏇炴彥閻撗嶇礆+ JSON round-trip
- `lib/domain/line_endpoint.dart`閿涙岸妾风痪褌璐熺紒妯煎殠鐎规矮缍呴柨顕嗙礉`LineScope` 缁夎鍙?`line_scope.dart`
- `lib/presentation/review/review_case_adapter.dart`閵嗕梗review_page_state.dart`閿?
  缁旑垳鍋ｉ弨閫涜礋 `RelationEndpoint`閿涘牊婀€/閺冦儳顏悙閫涚瑝閺勵垳鍩㈤敍宀€鍋ｉ悥璁崇瑝閸涙垝鑵戦敍? 閺嶅洨顒烽弨顖涘瘮閵嗗本婀€瀵?/ 閺冦儴鏅妴?

### 妤犲矁鐦?

```text
flutter test                 278 / 278 PASS閿涘湩4 閺傛澘顤?19 妞ょ櫢绱?
flutter analyze lib/domain test/domain   No issues found
lib/domain 閺傚洣娆?> 150 鐞?     0
Gate A verify                PASS閿涘潛ate-a 6 娴犺姤鏋冨?SHA256 6/6 IDENTICAL閿涘本婀崣妤€濂栭崫宥忕礆
```

> 閳跨媴绗?閺堫剝鐤?*閺佸懏鍓?*閺€鐟板綁娴滃棙妫﹂張澶嬬ゴ鐠囨洘婀￠張娑崇礄闂堢偛澧涘鎲嬬礆閿?
> 缁旑垳鍋?canonical 閻?`original-3` 閸欐ü璐?`yao:original:3`閿涘牆顨栫痪?2閿涘绱?
> 濠曟梻銇氶崡锔跨伐閸忓磭閮撮弫鎵暠 2 閸欐ü璐?16閿涘牆濮╅崣?1 + 閸忣厼鍟?1 + 娴滄棁顢?14閿涘苯顨栫痪?1閿涘鈧?
> 閺?JSON 娴犲秴褰茬憴锝嗙€介敍鍧凴elationEndpoint.fromJson` 閸忕厧顔愰弮?`kind` 閻ㄥ嫭妫粩顖滃仯缂佹挻鐎敍澶堚偓?

---

## POST-R3-GOV-01 閳?濞岃崵鎮婇弨璺哄經閿?026-09-12閿涘本婀崣鎴濈閿?

> 娑撳秴褰傞悧鍫涒偓浣风瑝閺€閫涢獓閸濅椒鍞惍渚婄窗`lib/` `test/` `assets/` diff = 0閵?
> 閸欘亜浠涙稉銈勬娴滃绱伴幎?`tool/gate_a/` 閺€璺哄煂 **閻╊喖缍嶉惄瀛樺复閺傚洣娆?閳?5閵嗕笍art 閺傚洣娆?閳?100 鐞?*閿?
> 娴犮儱寮?*閸忓牅鎱ㄥΛ鈧弻銉ユ珤**閳ユ柡鈧梹婀版潪顔煎絺閻滈绨?5 婢跺嫨鈧本顥呴弻銉ユ珤缂佹瑥浜ｇ紒鎾诡啈閵嗗秶娈戦梾鎰亝閵?

### S0 娴滃鐤勯弽鎼佺崣閿涙碍顥呴弻銉ユ珤閺堫剝闊╂稉宥呭讲娣?

閻劎顑囨禍宀€顫掗崣顏囶嚢閺傜懓绱￠敍鍦werShell 闁劗楠囬弸姘閿涘瀚粩瀣槻閺嶇鎮楃涵顔款吇閿?

| # | 缂傛椽娅?| 娴滃鐤?| 閸氬孩鐏?|
| --- | --- | --- | --- |
| 1 | `gov_selfcheck` 鐟欏嫬鍨?2 閺佷即鏁?| 閻?`listSync(recursive: true)` 閺?*閸氬簼鍞弬鍥︽**閿涙稒鐗撮惄顔肩秿閸欘亝鏆熼弬鍥︽閵嗕焦绱￠幒澶婂弿闁?7 娑擃亜鐡欓惄顔肩秿 | `cases/` 鐞氼偅濮ら幋鎰┾偓? 娑擃亝鏋冩禒韬测偓宥冣偓涔eports/` 閺佹澘鐡ч崘娆愬灇 9閿涙稖鈧瞼濮搁幀浣规瀮娴犳湹绗岄幓鎰唉 1541660 闁棄鍟撻惈鈧妴宀冾潐閸?2 PASS閵嗗秮鈧柡鈧?*閸?PASS** |
| 2 | `gate_a_runner.ps1` 8 娑擃亝膩瀵繘鍣?4 娑擃亣鐭惧鍕亼閺?| 閻╊喖缍嶉幖顒冪讣閿?541660閿涘鎮楅張顏勬倱濮濄儻绱癭closeout`/`residual`/`enumerate`/`solve` 閸忋劍瀵氶崥鎴滅瑝鐎涙ê婀惃鍕瀮娴?| `closeout` 閺嶈婀扮捄鎴滅瑝鐠ч攱娼甸敍灞烩偓瀹憀oseout PASS閵嗗秷绻栫猾鏄忕槈閹诡喕绗夐崣顖濆厴鐠囨艾鐤勬禍褍鍤?|
| 3 | `check_imports.dart` 閻╄尙鍋?| 閸欘亝顥呴弻銉や簰 `.` 瀵偓婢跺娈?import閿涘畭import 'status/x.dart'`閿涘牊绱￠崘?`../`閿涘顫?*闂堟瑩绮捄瀹犵箖** | 濡偓閺屻儱娅掗幎?OK閿涘瞼鏁撻幋鎰珤闂呭繐鎮楃紓鏍槯婢惰精瑙?|
| 4 | 閻㈢喐鍨氶崳銊ャ亼鐠愩儲妞?SHA 濮ｆ柨顕弮鐘冲壈娑?| 閻㈢喐鍨氶崳銊︾梾閹存劕濮?閳?閺冄勬瀮濡楋絼绮涢崷銊ф磸娑?閳?SHA 閺勫墽銇氶妴瀛獽閵?| 缁涘鐜幀褑鐦夐幑?*缁岀儤绀?*閸楀婀呮导濂糕偓姘崇箖 |
| 5 | 姒涘嫰鍣捐箛顐ゅ弾鐎电顢戠亸鐐櫛閹?| `core.autocrlf=true` 娑撴梹妫?`.gitattributes`閿涙瓭heckout 閹?LF 鏉╂ê甯幋?CRLF | 閸愬懎顔愭稉鈧€涙婀弨鐧哥礉鐟欏嫬鍨?3 閸楁潙绻€閻?*閸?FAIL** |

### 娣囶喖顦?

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `tool/gate_a/tools/gov/dir_scan.dart` | 鐟欏嫬鍨?2閿?*閻╁瓨甯撮弬鍥︽**鐠佲剝鏆熼敍鍫ユ姜闁帒缍婇敍? 鐠囦焦宓佺悰?|
| `tool/gate_a/tools/gov/line_scan.dart` | 鐟欏嫬鍨?1閿涙art 閺傚洣娆㈢悰灞炬殶娑撳﹪妾?|
| `tool/gate_a/tools/gov/doc_scan.dart` | 鐟欏嫬鍨?3閿涙氨鏁撻幋鎰瀮濡?SHA256 vs 姒涘嫰鍣捐箛顐ゅ弾閿涘牏宸辫箛顐ゅ弾娑撳秴绶辫ぐ?PASS閿?|
| `tool/gate_a/tools/gov/rules_regression.dart` | **鐟欏嫬鍨?0**閿涙矮澶嶉弮璺恒仚閸忕柉鍤滅拠浣碘偓灞炬殶閻ㄥ嫭妲搁惄瀛樺复閺傚洣娆㈤妴宥忕礉閸忓牐鍤滅拠浣稿晙閺屻儰绮ㄦ惔?|
| `tool/gate_a/tools/gov/gov_rules.dart` | 鐟欏嫬鍨紓鏍ㄥ笓 + 闁劗娲拌ぐ鏇＄槈閹诡喗澧﹂崡?|
| `tool/gate_a/tools/checks/gov_selfcheck.dart` | 閺€閫涜礋閽栧嫬鍙嗛崣锝忕礄鐟欏嫬鍨€圭偟骞囬崗銊╁劥缁夎鍙?`tools/gov/`閿?|
| `tool/gate_a/gate_a_runner.ps1` | 濡€崇础鐠侯垰绶為梿鍡曡厬閹?`$Scripts` 鐞涖劊鈧胶宸遍弬鍥︽閸楀啿銇戠拹銉幢閺傛澘顤?`verify` 闁炬拝绱?*閸?preflight 濡偓閺屻儱鍙忛柈?9 娑擃亝膩瀵繑妲搁崥锕傚厴閼冲€熜掗弸?*閿涘苯鍟€ imports 閳?generate 閳?gov 閳?selftest 閳?cross閿涙稓鏁撻幋鎰珤婢惰精瑙﹂崡宕囩矒濮濄垹鑻熸竟鐗堟 SHA 閺冪姵鍓版稊澶涚礆 |
| `tool/gate_a/tools/checks/check_imports.dart` | 閸欘亣鐑︽潻?`package:` / `dart:`閿涙稒鏁為柌濠傚敶缁€杞扮伐娑撳秴鍟€鐠囶垱濮?|
| `.gitattributes`閿涘牊鏌婃晶鐑囩礆 | `gate-a/*.md text eol=lf` 閳ユ柡鈧?閻㈢喐鍨氶弬鍥ㄣ€傞柨?LF閿涘矂绮嶉柌鎴濇彥閻撗冩躬娴犺缍嶉張鍝勬珤娑撳﹪鍏橀幋鎰彌 |

### tool/gate_a/ 閻╊喖缍嶉弽鎴礄濞岃崵鎮婇崥搴礉63 娑?Dart 閺傚洣娆㈤敍灞藉弿闁?閳?100 鐞涘矉绱?

```text
gate_a_context.dart 37        gate_a_main.dart 44        gate_a_runner.ps1
astro/      cross_source 61 璺?cross_source_rows 72 璺?diag_oracle 83
            sun_longitude 69 璺?sun_terms 89
cases/      derive 72
  data/     boundary_cases 94 璺?classic_cases 60 璺?normal_cases_a 79 璺?normal_cases_b 70
  logic/    case_facts 81 璺?case_model 100
commands/   digest 74 璺?generate_reports 73
core/       audit/      hexagram_audit 54 璺?najia_audit 26 璺?palace_audit 47
            formatting/ format 43
            pillars/    case_pillars 36 璺?pillar_tables 38 璺?pillars 64
            time/       pack_loader 38 璺?time_input 60
data/       hko_source 70 璺?naoj_source 98 璺?fixtures/hko 璺?fixtures/naoj
reports/    day_report 68
  cases/    case_columns_table 49 璺?case_line_table 51 璺?case_report 52 璺?master_table 66
  readme/   readme_checklist 78 璺?readme_header 47 璺?readme_instructions 17
            readme_sources 46
  solar_term/ boundary_section 64 璺?term_fields 48 璺?term_reference 87
              term_render 74 璺?term_resolve 46
  status/   gate_criteria 86 璺?gate_status 71 璺?gate_truth_items 84
tools/      selftest 36閿涘牆鍙嗛崣锝忕礉鐠侯垰绶炴稉宥呭綁閿?
  checks/   check_imports 63 璺?enumerate_hexagrams 90 璺?gov_selfcheck 31
            sha256 87 璺?solve_cases 52
  diag/     oracle_residual 89 璺?precision_closeout 80 璺?residual_anchors 32
  gov/      dir_scan 81 璺?doc_scan 33 璺?gov_rules 98 璺?line_scan 31
            rules_regression 100
  selftest/ checks_astro 93 璺?checks_liuchong 89 璺?checks_pillars 70
            checks_tables 61 璺?suite 62
```

### 濮ｅ繋閲滅搾鍛存閺傚洣娆㈤惃鍕箵閸?

| 閸樼喐鏋冩禒璁圭礄鐞涘本鏆熼敍?| 閹峰棗鍨庢稉?|
| --- | --- |
| `cases/derive.dart` 139 | `logic/case_facts.dart`閿涘牊膩閸ㄥ绱? `derive.dart`閿涘牊甯圭€?/ 濡楀牅绶ラ梿鍡楁値閿?|
| `core/audit/hexagram_audit.dart` 110 | `najia_audit` + `palace_audit` + `hexagram_audit`閿涘牆鍨界€规熬绱?|
| `core/pillars/pillars.dart` 120 | `pillar_tables` + `pillars`閿涘牏鍑介崙鑺ユ殶閿? `case_pillars`閿涘牊澧跨仦鏇礆 |
| `reports/solar_term_report.dart` 221 | `solar_term/`閿涙瓪term_reference` + `term_resolve` + `term_fields` + `term_render` |
| `reports/boundary_report.dart` 125 | `solar_term/boundary_section.dart` + `status/gate_criteria.dart` |
| `reports/readme_header.dart` 137 | `readme/readme_header` + `readme_sources` + `readme_checklist` |
| `reports/case_report.dart` 110 | `cases/case_report`閿涘牏绱幒鎺炵礆+ `case_columns_table` + `case_line_table` |
| `tools/diag/oracle_residual.dart` 113 | `diag/residual_anchors.dart` + `oracle_residual.dart` |
| `tools/selftest.dart` 344 | `tools/selftest/`閿涙瓪suite` + `checks_astro` + `checks_pillars` + `checks_liuchong` + `checks_tables`閿涘牆鍙嗛崣锝堢熅瀵板嫪绗夐崣姗堢礆 |

### 閸掔娀娅?

```text
tool/gate_a/reports/boundary_report.dart
tool/gate_a/reports/case_report.dart
tool/gate_a/reports/master_table.dart        閳?reports/cases/master_table.dart
tool/gate_a/reports/readme_header.dart
tool/gate_a/reports/readme_instructions.dart 閳?reports/readme/readme_instructions.dart
tool/gate_a/reports/solar_term_report.dart
```

### 妤犲矁鐦夐敍鍫濆弿闁?PASS閿?

```text
dart files > 100 lines        = 0        閿?3 娑?Dart 閺傚洣娆㈤敍?
directories > 5 direct files  = 0        閿?5 娑擃亞娲拌ぐ鏇礉MAX = 5閿?
gov_selfcheck                 PASS       閿涘牐顫夐崚?0 閼奉亣鐦?+ 鐟欏嫬鍨?1/2/3閿?
independent filesystem audit  PASS       閿涘牏顑囨禍宀€娣惔锔肩窗PowerShell 闁劗楠囬弸姘閿?
Gate docs SHA256              6/6 IDENTICAL閿涘牓绮嶉柌鎴濇彥閻撗嶇礆
gate_a_runner verify          PASS       閿涘潟mports + generate + gov + selftest + cross閿?
gate_a_runner closeout        PASS
gate_a_runner cross           24 / 24
flutter test                  259 / 259 PASS
flutter analyze lib/domain test/domain   No issues found
dart analyze tool/gate_a      No issues found閿涘牓銆庨幍瀣閹?7 閺夆剝鏁奸崝銊ュ閺冦垹鐡?warning閿?
lib/ test/ assets/ diff       0
```

> `dart analyze` 娑?`flutter test` 闁€燁洣 spawn 鐢?stdio 閻ㄥ嫬鐡欐潻娑氣柤
> 閿涘潊nalysis_server / frontend_server閿涘鈧倸婀崣妤呮閺傚洣娆㈠▽娆戭唸娑撳绻栫猾?spawn 鐞氼偆娲块幒銉﹀珕缂?
> 閿涘潉CreateFile failed 5`閿涘绱漙flutter test` 閺囩繝绱?*闂嗘儼绶崙鍝勬勾闂堟瑩绮稉宥呭З** 閳ユ柡鈧?
> 閸愬秹浜ｉ崚鐗堟閸忓牏鈥樼拋銈嗙煓缁犺鲸膩瀵骏绱濇稉宥堫洣鐠囶垰鍨介幋鎰┾偓宀€绱拠鎴炲弮閵嗗秲鈧?

> 濞夘煉绱癭tool/gate_a` 閺嶅湱娲拌ぐ鏇熸Ц閵? 娑擃亝鏋冩禒?+ 7 娑擃亜鐡欓惄顔肩秿閵嗗秲鈧倽顫夐崚?2 閻ㄥ嫬鍠曠紒鎾冲經瀵板嫪璐?
> **閻╁瓨甯撮弬鍥︽ 閳?5**閿涙稑鐡欓惄顔肩秿**娑?*鐠佲€冲弳閻栧墎娲拌ぐ鏇㈩暕缁?閳ユ柡鈧?閸氾箑鍨?7 娑擃亣顕㈡稊澶嬆侀崸妤冩窗瑜?
> 濮樻瓕绻欓弮鐘崇《濠娐ゅ喕閿涘奔绗栨稉搴涒偓宀€顩﹀顫礋閸戞垶鏆熺涵顒€鎮庨獮鎯颁捍鐠愶絻鈧秷鍤滈惄鍝ョ厱閻╀勘鈧?

---

## Gate A 閺€璺哄經 閳?GATE-A-FINAL-CLOSEOUT閿?026-09-12閿涘本婀崣鎴濈閿?

> 閺堫剝鐤嗘稉宥呯磻閸欐垵濮涢懗鏂ょ礉閸欘亜浠涙禍瀣杽閺€璺哄經閵嗗倷楠囬崫浣峰敩閻?diff = 0閵嗕礁宸诲▔鏇熸殶閹?diff = 0閵?

### Gate 鐎规矮绠熷锝呯础閹峰棗鍨?

```text
Gate A-Truth   CORE DIVINATION TRUTH                閳ユ柡鈧?R3 閻?blocker
Gate A-Compat  PROFESSIONAL SOFTWARE COMPATIBILITY  閳ユ柡鈧?娑撳秹妯嗘繅?R3
```

**閻炲棛鏁?*閿涙艾甯?Gate A 閹跺鈧本鐓囨稉鎾茬瑹鏉烆垯娆㈡禍鍝勪紣婵夘偄鍟撶紒鎾寸亯閵嗗秷顔曟稉鍝勬暜娑撯偓閻喎鈧吋娼靛┃鎰剁礉
閹跺﹣绔存禒鑸垫拱鐠愩劋绗傞弰顖樷偓灞藉悑鐎硅鈧嗩潎鐎电喆鈧秶娈戞禍瀣綁閹存劒绨?R3 blocker閵?
閺嶇绺鹃惇鐔封偓鍏兼暭閻㈠崬褰叉径宥嗙壋閻ㄥ嫮瀚粩瀣槈閹诡喗澹欓幏鍜冪礄閻欘剛鐝涚憴鍕灟閺嶆悂鐛?+ 鐎规ɑ鏌熼崢鍡樼《閸欏本绨?+
缁夋帞楠囬惇鐔封偓?+ 鏉堝湱鏅?Golden Test + 259/259 閼奉亜濮╁ù瀣槸閿涘绱?
娑撴挷绗熸潪顖欐娑斿妫块惃鍕ウ濞叉儳妯婂鍌︾礄23:00 / 00:00 閺冦儳鏅妴浣规珓鐎涙劖妞?/ 閺冣晛鐡欓弮韬测偓浣稿従娴犳牠鍘ょ純顕嗙礆
鐠侀璐?*閸忕厧顔愰幀?/ 闁板秶鐤嗗顔肩磽**閿涘奔绗夐懛顏勫З鐟欏棔璐熼弽绋跨妇缁犳纭堕柨娆掝嚖閵?

### 閺傛澘顤?
| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `tool/gate_a/gate_a_gate_status.dart` | 閸?Gate 鐎规矮绠?+ Gate A-Truth 闁劙銆嶇悰?+ R3 閺堚偓缂佸牏濮搁幀浣告健閿涘牆宕熸稉鈧惇鐔哥爱閿?|

### 娣囶喗鏁?
- `tool/gate_a/gate_a_main.dart`閿涙瓓EADME 婢跺瓨鏁奸崣?Gate 缂佹挻鐎敍?
  閹槒銆冮幏鍡楀毉 `Truth Result` / `Compatibility Result` 娑撱倕鍨敍?
  娴ｈ法鏁ょ拠瀛樻閺€閫涜礋 Gate A-Compat 娑撴挾鏁ら敍娑欑閻炲棙鐣悾娆愭＋閺嶅洭顣?
- `tool/gate_a/gate_a_cross_source.dart`閿涙碍鏁為柌濠傜秺鐏炵偞鏁兼稉?Gate A-Truth
- `tool/gate_a/gate_a_solar_term_report.dart`閿涙碍鏁為柌濠冩暭娑?PARTIALLY SECOND-LEVEL VERIFIED
- `gate-a/*.md`閿涙艾鍙忛柈銊╁櫢閺傛壆鏁撻幋鎰剁礄閺€?generator 閻喐绨敍宀勬姜閹靛鏁兼禍褏澧块敍?

### 閺堚偓缂佸牏濮搁幀?
```text
R3-A                        PASS
R3-B                        PASS
R3-B-DATA-PRECISION-FIX     PASS
GATE A-TRUTH                PASS
GATE A-COMPAT               NOT EXECUTED / DEFERRED 閳?NON-BLOCKING
R3                          FINAL ACCEPTED
```

### 閺冦儳鏅?
```text
DAY BOUNDARY ENGINE      PASS
PRODUCT DEFAULT POLICY   OPEN閿涘牅绗夐梼璇差敚 R3 Domain Foundation閿?
```

### 閺堫亜浠?
R4 閺堫亣绻橀崗銉幢娑撴挷绗熸潪顖欐娴滃搫浼愮€靛湱鍙庨張顏呭⒔鐞涘矉绱橤ate A-Compat閿涘奔绗夐梼璇差敚閿涘鈧?

---

## 閼哄倹鐨甸弫鐗堝祦缁儳瀹虫稉鎾汇€嶆穱顔碱槻 閳?R3-B-DATA-PRECISION-FIX閿?026-09-12閿涘本婀崣鎴濈閿?

> **閺嶇懓娲?*閿涙艾鍨庨柦鐔洪獓鐎规ɑ鏌熼弰鍓с仛閸婅壈顫︽穱婵嗙摠娑?`:00` 缁?Instant閿涘矁鈧矁顕氶崚鍡涙寭閸愬懎鐡ㄩ崷?
> 閸欘垶鐛欑拠浣烘畱閻喎鐤勭粔鎺旈獓娴溿倛濡弮璺哄煝 閳ユ柡鈧?**閸掑棝鎸撶痪褎鏆熼幑顔荤瑝鐡掑厖浜掔悰銊ㄦ彧鐠囥儳顫楃痪褑绔熼悾?*閵?
> 娑撳秵妲搁妴瀛扠O 闁挎瑤绨￠妴宥忕窗鐎规ɑ鏌熼崣灞剧爱 HKO / NAOJ 24 / 24 閸掑棝鎸撶痪褌绔撮懛娣偓?

### 婵傛垹瀹抽崣妯绘纯閿涙碍鏆熼幑顔煎瘶閺€顖涘瘮**濞ｅ嘲鎮庣划鎯у**閿涘澃chemaVersion 2閿涘苯鎮滈崥搴″悑鐎?v1閿?
- `TermPrecision`閿涙瓪minute`閿涘牏宸遍惇渚婄礆/ `second`閿?
- 閸愯崵绮ㄧ拠顓濈疅閿涙瓪minute` 閺?`instantUtc` 缁夋帊缍呴幁鎺嶈礋 `:00`閿?
  閸欘亣銆冪粈鎭掆偓?*鐠囥儱鍨庨柦鐔峰敶**娴溿倛濡妴宥忕礉**娑?*鐞涖劎銇氶妴灞句紗閸︺劎顑?0 缁夋帊姘﹂懞鍌樷偓宥忕幢
- 闁劘濡鏂垮讲闁?`sourceOverride`閿涘潉name` + `reference`閿涘绱濇稉宥堫洬閻╂牗妞傚▽璺ㄦ暏楠炴潙瀹?`source`閿?
- 閺堫亞鐓?`precision`閵嗕焦鐣紓?`sourceOverride` 娑撯偓瀵板瀚嗙紒婵嗩嚤閸忋儯鈧?
- 閸樼喎鍨敍?*閺佺増宓侀崠鍛讲娴犮儲璐╅崥鍫㈢翱鎼达讣绱濇担鍡樼槨閺夆剝鏆熼幑顔肩箑妞ゆ槒顕╁〒鍛翱鎼达缚绗岄弶銉︾爱**閵?
  娴犮儱鎮楅柅鎰嬀鐞涖儲娲挎妯肩翱鎼达箒濡鏂垮涧闂団偓閺囨寧宕茬€电懓绨?term閿涘奔绗夎箛鍛腹缂堣鍕炬惔锕€瀵橀妴?

### 閺佺増宓侀崣妯绘纯閿涘牅寮楅弽鍏兼付鐏忓骏绱?
- `assets/calendar/2026.calendar.json`閿涙瓪schemaVersion 1閳?`閵嗕梗revision 1閳?`閿?
  缁斿妲?`2026-02-03T20:02:00Z` 閳?`2026-02-03T20:02:08Z`閿?
  闂?`precision: second` 娑撳孩娼靛┃鎰洬閻╂牭绱欐稉顓炴禇缁夋垵顒熼梽銏紶闁叉垵鍖楁径鈺傛瀮閸欐壆顫栭弲顕€鍎撮敍澶堚偓?
- 閸忔湹缍?23 閺壜ゅΝ濮樻柣鈧礁鍙炬担?9 娑擃亜鍕炬禒钘夊瘶閿?*閺堫亝鏁奸崝?*閵?
  閺堫亜褰囧妤€褰叉穱锛勵潡缁狙呮埂閸婅偐娈戦懞鍌涚毜娑撳秷藟缁夋帇鈧椒绗夐幓鎺戔偓绗衡偓浣风瑝娴兼壆鐣婚妴?

### 閺傛澘顤?
| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `lib/domain/calendar/import/calendar_data_pack_term_source.dart` | 闁劘濡鏃€娼靛┃鎰洬閻╂牗鐗庢?|
| `test/domain/calendar/solar_term_second_boundary_test.dart` | 缁斿妲粔鎺旈獓鏉堝湱鏅?Golden Test |
| `test/domain/calendar/calendar_terms_precision_test.dart` | 缁儳瀹?/ 閺夈儲绨崗鍐╂殶閹诡喗鐗庢?|
| `test/domain/calendar/solar_term_precision_revision_test.dart` | 缁儳瀹虫穱顔款吂鐎电厧鍙嗛崶鐐茬秺 |
| `tool/gate_a/gate_a_precision_closeout.dart` | 妤犲本鏁归弬顓♀枅閿涘牐铔嬮惇鐔风杽娴溠冩惂闁炬崘鐭鹃敍?|
| `tool/gate_a/gate_a_hko_source.dart` | HKO 鐎规ɑ鏌?XML 鐟欙絾鐎介敍鍫滄唉閸欏鐗虫宀€鏁ら崢鐔奉潗閸欐垵绔锋禒璁圭礆 |
| `tool/gate_a/hko/24SolarTerms_2026.xml` | HKO 鐎规ɑ鏌?XML 婢剁懓鍙块敍鍫㈩瀲缁惧灝褰查柌宥咁槻閿?|

### 娣囶喗鏁?
- `solar_term/solar_term.dart`閿涙艾顤冮崝?`precision` / `sourceName` / `sourceReference`
- `import/calendar_data_pack.dart`閿涙艾顤冮崝?`TermPrecision` 娑撳酣鈧劘濡鏂垮讲闁鐡у▓?
- `import/calendar_data_pack_parser.dart`閿涙俺袙閺?`precision` / `sourceOverride`
- `import/calendar_data_pack_terms.dart`閿涙氨绨挎惔锔界墡妤?
- `import/calendar_data_pack_validator.dart`閿涙碍鏁幐?`schemaVersion 1..2`
- `test/domain/calendar/calendar_engine_test.dart`閿涙艾甯弬顓♀枅閵?4:02:00 閸楀啿鐦忛張鍫涒偓?
  瀹告煡娈㈤弫鐗堝祦娣囶喗顒滈弴瀛樻煀閿涘牐顕氶弬顓♀枅閸樼喐婀伴幎濠勫繁闂勭兘鏀ｉ幋鎰啊閵嗗本顒滅涵顔款攽娑撴亽鈧稄绱?

### NOT changed閿涘牆鍠曠紒鎾瑰瘱閸?diff = 0閿?
`MonthBranchResolver` / `CalendarEngine` / `GanzhiDay` / `XunKong` /
`CastingEngine` / 閸忣偄顔?/ 缁惧磭鏁?/ 閸忣厺缈?/ 娑撴牕绨?/ 閸忣厾顨?/ UI閿?
閼奉亜缂?Meeus 鐏忓搫鐡欐穱婵囧瘮 `DIAGNOSTIC ONLY / REJECTED AS GATE ORACLE`閵?

### 妤犲本鏁归弬顓♀枅
```text
04:01:00 閳?娑?  04:02:00 閳?娑撴埊绱欐穱顔碱槻閻愮櫢绱?  04:02:07 閳?娑?
04:02:08 閳?鐎靛拑绱欐禍銈堝Ν閻剟妫块敍灞芥儓閿?  04:02:09 閳?鐎?  04:03:00 閳?鐎?
```

### 妤犲矁鐦?
`flutter test` 259 / 259閿涙硞coped analyze 0 issue閿?
閸忋劋绮?analyze 27 = 閸╄櫣鍤庨敍鍧w 0 / removed 0閿涘鈧?

---

## Gate A 娑撴挷绗熼幒鎺旀磸娴滃搫浼愮€靛湱鍙庢灞炬暪 閳?GUAYAN-2.0-GATE-A閿?026-09-11閿涘本婀崣鎴濈閿?

> 閺堫剝鐤?*娑撳秴鍟撴禍褍鎼ч崝鐔诲厴**閿涘苯褰ч崑?R3-A + R3-B 閻ㄥ嫪绗熼崝锛勬埂閸婂ジ鐛欓弨璁圭窗
> 閹跺鈧矁鎹ｉ崡锔芥闂?+ 閸楋箒钖勬潏鎾冲弳閵嗗秳姘︾紒娆庣瑩娑撴碍甯撻惄妯胯拫娴犲爼鈧劙銆嶇€靛湱鍙庨敍?
> 绾喛顓婚張鍫濈紦 / 閺冦儴鏅?/ 閺冾剛鈹?/ 閸忣厾顨?/ 閺堫剙宕?/ 閸欐ê宕?/ 缁惧磭鏁?/ 娴滄棁顢?/ 閸忣厺缈?/ 娑撴牕绨?
> 娑撳簼绗撴稉姘宠拫娴犳湹绔撮懛娣偓?*娴滃搫浼愮€靛湱鍙庨弰顖氭暜娑撯偓閻喎鈧吋娼靛┃鎰剁礉Agent 娑撳秴浠涢懛顏勫З閸掋倕鐣鹃妴?*

### 閺傛澘顤冮敍鍧眔ol/gate_a/ 閳?妤犲本鏁瑰鍫滅伐閻㈢喐鍨氶崳顭掔礉娑撳秴寮稉?App 鏉╂劘顢戦弮璁圭礆
- `gate_a_main.dart` 閳?閸忋儱褰涢敍姘愁棅鏉炵晫婀＄€圭偞鏆熼幑顔煎瘶 閳?缂佹挻鐎懛顏咁梾 閳?閻㈢喐鍨?6 娴犱粙鐛欓弨鎯般€冮崡?
- `gate_a_context.dart` 閳?娑撳簼楠囬崫浣哥暚閸忋劌鎮撶捄顖氱窞閻ㄥ嫬绱╅幙搴ゎ棅闁板稄绱橨SON閳帗鐗庢灞稿晪鐎电厧鍙嗛埆鎺嶇波閸屻劉鍟婸rovider閳墮ngine閿?
- `gate_a_cases.dart` 閳?濡楀牅绶ラ惌鈺呮█閿涙碍娅橀柅?13 娓?/ 缂佸繐鍚€ 6 娓?/ 閼哄倹鐨?12 閼哄倸鍙忛柌?/ 閺冦儳鏅?3 閺?
- `gate_a_hexagram_facts.dart` 閳?閸楋缚绶ユ禍瀣杽鐠侊紕鐣?+ **濡楀牅绶ラ柨浣哥暰**閿涘牊婀伴崡?閸欐ê宕锋稉搴★紣閺勫簼绗夌粭锕€宓嗛幎銉╂晩閿?
- `gate_a_case_report.dart` 閳?閸楋缚绶ョ€靛湱鍙庣悰銊﹁閺屾搫绱欓柅鎰煝鐎靛湱鍙?+ 娑撴挷绗熸潪顖欐婵夘偄鍟撴担宥忕礆
- `gate_a_solar_term_report.dart` 閳?閼哄倹鐨?*瀹割喖绱撶粣妤€褰?*濞村鍣烘稉搴㈠赴濞村鐓╅梼纰夌礄缁愭褰涚挧椋庡仯 鍗?s閿?
- `gate_a_day_report.dart` 閳?閺冦儳鏅捄銊ョ摍閺冩儼绻涚紒顓熸闂傜閰?鑴?娑撱倗顫掔憴鍕灟
- `gate_a_hexagram_audit.dart` 閳?閸忣偄顔傜悰銊ョ暚閺佸瓨鈧?/ 缁惧磭鏁崇紒鍕棅妞ゅ搫绨?閻欘剛鐝涙径宥嗙壋
- `gate_a_pillars.dart` 閳?閸ユ稒鐓撮弮浣界槈閿涘牆鍕鹃弻鍙樹簰缁斿妲幑銏犲嬀 / 娴滄棁妾搁柆?/ 娴滄棃绱堕柆渚婄礆
- `gate_a_sun_longitude.dart` 閳?閼奉亜缂撴径鈺傛瀮鐏忓搫鐡欓敍鍦eus 婢额亪妲肩憴鍡涚矋缂佸骏绱氶埆?**瀹歌尪鐦夋导顏庣礉闂勫秳璐?diagnostic**
- `gate_a_naoj_source.dart` 閳?NAOJ閵嗗本娈剧憰渚€鐖￠妴宄塰ift_JIS 鐎涙濡痪褑袙閺嬫劧绱?*鐎规ɑ鏌熺粭顑跨癌閻喎鈧吋绨?*閿?
- `gate_a_cross_source.dart` 閳?HKO vs NAOJ 閸欏本绨禍銈呭级閺嶆悂鐛欓敍?4 妞ゅ綊鈧劖娼敍?
- `gate_a_oracle_residual.dart` 閳?閼奉亜缂撶亸鍝勭摍閻?*閺冨爼妫垮▓瀣▕**鐠囧嫪鍙婇敍鍫濐嚠鐎规ɑ鏌熼崣鎴濈閺冭泛鍩㈤敍?
- `gate_a_diag_rate.dart` / `gate_a_diag_sun.dart` 閳?鐏忓搫鐡欓弽鐟版礈鐎规矮缍呴敍鍫濆綁閻?+ 娑擃參妫块柌蹇ョ礆
- `gate_a_solve.dart` 閳?閸楋箑鎮?閳?娴ｅ秳瑕?閳?閸斻劎鍩㈡担宥忕礄闂冨弶澧滈崘娆庣秴娑撴彃鍤柨娆欑礆
- `gate_a_format.dart` / `gate_a_selftest.dart` / `gate_a_enumerate.dart`
- `naoj/rekiyou262.2026.html` 閳?NAOJ 2026 妞ょ敻娼扮€涙濡径鐟板徔閿涘牏顬囩痪鍨讲闁插秴顦查敍?
- `gate_a_runner.ps1` 閳?閺堫剚婧€ PATH 閸栧懓顥婇敍?*缁?ASCII**閿涙瓍owerShell 5.1 鐎佃妫?BOM 閻?.ps1 閹?ANSI 鐟欙絾鐎介敍?
  娑擃厽鏋冨▔銊╁櫞娴兼艾褰夐幋鎰嚔濞夋洟鏁婄拠顖ょ幢娑擃厽鏋冮弬鍥ㄣ€傛稉鈧瀣杹閸?Dart 濠ф劙鍣烽敍?

### GATE-A-PREP-FIX1閿涘牆鎮撻弮銉ㄋ夊锝忕礉娴犲懏鏁兼灞炬暪閻晠妯€閿涘本婀崝銊ら獓閸濅椒鍞惍渚婄礆
- 閸?GA-3 閻?`-1min / -30s` 娴ｆ嚎鈧苯鍨庨柦鐔虹翱鎼达附妲搁崥锕佸喕婢剁喆鈧秶娈戦崚銈嗗祦 閳ユ柡鈧?**鐠囥儱鍨介幑顔芥￥閺?*閿?
  鐎瑰啴娈ｉ崥顐海鐠佷勘鈧本鏆熼幑顔煎瘶閸掑棝鎸撻崐?= 閻喎鐤勬禍銈堝Ν閸ユ稖鍨楁禍鏂垮弳閸掓澘鍨庨柦鐕傜礄鐠囶垰妯?閳?30 缁夋帪绱氶妴宥忕礉
  閼板苯缍嬮弮鍓佹暏閼奉亜缂撴径鈺傛瀮鐏忕儤绁村妤€宕勬禍灞烩偓宀冨Ν閵嗗秴妯婂鍌滅崶閸?16s 閿?729s閵?
- 閺€閫涜礋閸︺劊鈧苯妯婂鍌滅崶閸欙綀鎹ｉ悙骞库偓宥嗘杹濞村鐦悙骞库偓?
- 閳跨媴绗?**鐠囥儴鐤嗙紒鎾诡啈瀹歌尪顫?FIX2 閹恒劎鐐?*閿涘牐顫嗘稉瀣剁礆閿涙艾妯婂鍌滅崶閸欙絾婀伴煬顐ｆЦ閺堫亪鐛欑拠浣告槀鐎涙劗娈戞禍褏澧块妴?

### GATE-A-PREP-FIX2閿涘牆鎮撻弮銉ょ癌濞喡に夊锝忕礉娴犲懏鏁兼灞炬暪瀹搞儱鍙挎稉搴㈡瀮濡楋綇绱濋張顏勫З娴溠冩惂娴狅絿鐖滈敍?
- **閹俱倕娲?FIX1 閻ㄥ嫮绮ㄧ拋?*閿涙俺鍤滃鍝勬槀鐎?`gate_a_sun_longitude.dart` 鐞氼偉鐦夋导顏庣礉娑撳秴绶辨担?Gate 閻喎鈧鈧?
  - 鐠囦焦宓侀敍姘嚠鐎规ɑ鏌熼崣鎴濈閺冭泛鍩㈤惃鍕闂傚瓨鐣顔芥付婢堆呭 **729 缁?*閿涘牏鐝涙径蹇ョ礆閿?
    鐎?2026 缁斿妲粔鎺旈獓閸忣剙绱戦崐鍏肩暙瀹割喚瀹?**閳?43 缁?*閵?
  - 閺嶇懓娲滈敍鍫濆嚒鐎规矮缍呴敍澶涚窗鐟欏棝绮嶇紒?*閺冦儱褰夐悳鍥劀绾?*閿?.0187 vs 鐎规ɑ鏌?1.0187 鎺?閺冦儻绱氶敍?
    娴ｅ棗婀€规ɑ鏌熸禍銈堝Ν閻剟妫块張顒€鏄傜€涙劕鍑＄搾濠呯箖閻╊喗鐖ｇ憴?9閿?0 鐟欐帞顫楅敍灞肩瑬閸嬪繐妯婇梾蹇擃劀閼哄倸褰夐崠鏍电礄娑撳簼鑵戣箛鍐ㄦ▕ C 閸氬瞼娴夐敍?
    閳ユ柡鈧?鐏?*缂佹繂顕い鐟颁焊瀹?*閿涙稏鈧本鐪伴弽鐟板冀娴?= 0.000000鎺抽妴宥囨畱閼奉亝鍞囬幀褌绗夐懗鍊熺槈閺勫海绮风€佃顒滅涵顔衡偓?
  - 婢跺嫮鐤嗛敍姝歊EJECTED AS GATE ORACLE`閿涘矂妾锋稉?diagnostic tool閿涘奔绗夐悽銊ょ艾瀵よ櫣鐛ラ妴浣风瑝娴ｆ粎婀￠崐绗衡偓?
  - 閺冄嗗殰濡偓 `<0.01鎺砢 闂勫秶楠囨稉?coarse sanity check閿?.01鎺?閳?14.6 閸掑棝鎸撻弮鍫曟？閿?
    闁俺绻冪€瑰啩绗夌搾鍏呬簰鐠囦焦妲戦崚鍡涙寭缁?缁夋帞楠囩划鎯у閿涘鈧?
- **閺傛澘顤冪€规ɑ鏌熼崣灞剧爱閻喎鈧?*閿涙KO閿涘湚KT閿涘】s NAOJ閵嗗本娈剧憰渚€鐖￠妴宥忕礄JST閳墲KT 閸?1 鐏忓繑妞傞敍澶涚礉
  2026 楠?**24 / 24 閺冦儲婀℃稉鈧懛娣偓浣稿瀻闁界喍绔撮懛?* 閳?鐎规ɑ鏌熼崚鍡涙寭缁狙呮埂閸婂吋鍨氱粩瀣ㄢ偓?
- **GA-3 闁插秴缂?*閿涙碍绁寸拠鏇犲仯閸欘亙浜掔€规ɑ鏌熼崣鎴濈閸婇棿璐熼崙?閳ユ柡鈧?
  閸忋劑鍎撮崡浣风癌閵嗗矁濡妴宥囩舶 `鏉堝湱鏅?閳?min / 鏉堝湱鏅?/ 鏉堝湱鏅?+1min`閿?
  閺堝褰叉潻鑺ュ嚱缁夋帞楠囬崗顒€绱戦崐鑹扳偓鍜冪礄瑜版挸澧犳禒鍛彌閺?2026閿涙氨浼犻柌鎴濆寳婢垛晜鏋冮崣鎵潠閺咁噣鍎?04:02:08 +08:00閿?
  鏉╄棄濮?`exact 閳?s / exact / exact +1s`閵?
  **瀹告彃鍨归梽?*閹碘偓閺堝鏁遍張顏堢崣鐠囦礁鏄傜€涙劖甯圭€佃偐娈戝顔肩磽缁愭褰涘ù瀣槸閻愬箍鈧?
  閺夈儲绨弮鐘崇《绾喛顓婚惃?`04:01:51` 娑撳秳绨ｉ弨璺虹秿閵?
- **Gate A2 閻樿埖鈧?*閿涙艾缍嬮弮鏈佃礋 `UNRESOLVED 閳?ASTRONOMICAL ORACLE NOT YET VALIDATED`閿?
  閺冾澀绗?PASS 娑旂喍绗?FAIL 閺佺増宓佸┃鎰┾偓浣风瑝瀵版宓佸銈呭磳缁?CalendarDataPack閵?
  > 閳跨媴绗?**鐠囥儳濮搁幀浣稿嚒鐞氼偄鎮撻弮銉ユ倵缂侇厾娈?R3-B-DATA-PRECISION-FIX 閸欐牔鍞?*閿?
  > 缁斿妲崣鏍х繁閸欘垯淇婄粔鎺旈獓閻喎鈧厧鑻熼崘娆忓弳閺佺増宓侀崠鍜冪礉Gate A2 閻滈璐?`PARTIALLY VERIFIED`閵?
  > 閺堫剝濡穱婵堟殌娑撳搫宸婚崣鍙夋殌鐠侇叏绱欐稉宥呯繁閸掔娀娅庨敍澶堚偓?

### 閺傛澘顤冮敍鍧揳te-a/ 閳?閻㈢喐鍨氶惃鍕崣閺€鎯般€冮崡鏇礉瀵板懐鏁ら幋宄版礀婵夘偓绱?
- `README.md` / `01-normal-cases.md` / `02-classic-cases.md` /
  `03-solar-term-boundaries.md` / `04-day-boundary.md` / `05-master-table.md`

### 缂佹挻鐎稉搴ｆ埂閸婅壈鍤滃Λ鈧紒鎾诡啈
- 閸忣偄顔傜悰顭掔窗64 缂佸嫬鎮庢稉鈧稉鈧€电懓绨查妴浣圭槨鐎?8 閸楋负鈧椒绗樻惔鏃傛祲闂呮柧绗佹担?閳?PASS閿?
- 濡楀牅绶ラ柨浣哥暰閿?9 娓氬婀伴崡?閸欐ê宕锋稉搴★紣閺勫簼绔撮懛娣偓浣烘捈閻㈣尙绮嶇憗鍛淬€庢惔蹇旑劀绾?閳?PASS閿?
- 鐎规ɑ鏌熼崣灞剧爱閿涙KO vs NAOJ 2026 楠?24 / 24 閺冦儲婀℃稉鈧懛娣偓浣稿瀻闁界喍绔撮懛?閳?PASS閿?
- 閺冦儲鐓撮柨姘卞仯 1949-10-01 = 閻㈡彃鐡欓敍鍫濐樆闁劑绮嶉崢鍡樼爱閺嶉潻绱氶敍?026-02-04 = 瀹搁亶鍘滈敍鍫ｆ硶 76 楠炲瀚粩瀣爱閺嶉潻绱氶敍?
- 閼奉亝顥呭鍙夊礋閼惧嘲鑻熸穱顔筋劀閻ㄥ嫰鏁婄拠顖ょ窗閸斻劎鍩㈡稉瀣垼 0/1 閸╃儤璐╅悽銊ｂ偓浣藉Ν濮樻棁顕ら崣鏍祲闁鍕炬禒濮愨偓?
  閸忣厼鍟?閸忣厼鎮?閹靛鍔呴崚鍡欒閿涘牊鎸夐崷鐗堢槷娑撳骸婀存搴″磳閸у洭娼崗顓炲暱閿涘鈧礁鍙氶悥璁崇秴娑撴彃鍟撻柨?6 婢跺嫨鈧焦澧滅粻妤佹）閺?3 婢跺嫨鈧?
  閼奉亜缂撶亸鍝勭摍 JD閳摯nix 缁绢亜鍘撴径姘 0.5 婢垛晪绱欓崗銊ょ秼閸嬪繒些 12 鐏忓繑妞傞敍澶夌瑢缁旂姴濮╃紓娲€嶉妴?

### 閺堫亜浠?
娴溠冩惂娴狅絿鐖滈張顏呮暭閸旑煉绱檂lib/`閵嗕梗test/` diff = 0閿涘绱盙ate A 閺?PASS閿?
閺冦儳鏅妯款吇閸婂吋婀崘鑽ょ波閿?*閼哄倹鐨甸弫鐗堝祦濠ф劒绗夐崡鍥╅獓**閿涘湙ate A2 閺堫亜鐣剧拋鐚寸礆閵?

---

## 缁傝崵鍤庨崢鍡樼《閸╄櫣顢呯仦?閳?GUAYAN-2.0-R3-B-CALENDAR閿?026-09-11閿涘本婀崣鎴濈閿?

> **鐠侯垳鍤庨崣妯绘纯**閿涙矮绗夐崘宥嗗Ω 1900閳?100 閻?4824 閺壜ゅΝ濮樻梻鈥栫紓鏍垳鏉╂稒绨惍渚婄礉
> 閺€閫涜礋 **楠炴潙瀹抽弫鐗堝祦閸?+ 閺堫剙婀存禒鎾冲亶 + 鐎瑰苯鍙忕粋鑽ゅ殠鐠侊紕鐣?*閵?
> 瀹告彃顕遍崗銉ュ嬀娴犵晫顬囩痪鎸庡笓閻╂﹫绱遍張顏勵嚤閸忋儱鍕炬禒?*閺勫海鈥橀幏鎺旂卜**閿涘瞼绮锋稉宥堢箮娴艰壈藟缁犳ぜ鈧?
> 缁?Dart閿涘矂娴?Flutter / 闂嗘儼绻嶇悰灞炬缂冩垹绮?/ 闂嗚泛銇夐弬鍥х氨 / 闂嗘儼绻庢导?fallback閵?

### 閺傛澘顤冮敍鍧檌b/domain/calendar/閿?
- 閺嶇櫢绱癭calendar_engine.dart`閿涘牐浠涢崥鍫礆/ `calendar_request.dart` / `calendar_context.dart` /
  `calendar_error.dart`閿涘牏琚崹瀣婢惰精瑙﹂敍? `day_boundary_rule.dart`閿涘牅琚辩粔宥堫潐閸掓瑱绱濋弮鐘荤帛鐠併倕鈧》绱?
- `day/`閿涙瓪ganzhi_day.dart`閿涘湞DN 閳?閸忣厼宕勯悽鎻掔摍閿? `xun_kong.dart`閿涘牊妫崇粚铏规暠閺冾剟顩婚幒銊ヮ嚤閿?
- `solar_term/`閿涙瓪solar_term_id.dart` / `solar_term.dart` / `solar_term_provider.dart` /
  `calendar_year_data.dart` / `month_branch_resolver.dart`閿涘牆宕勬禍灞烩偓宀冨Ν閵嗗秴鍨忛張鍫濈紦閿?
- `import/`閿涙瓪calendar_data_pack.dart` / `calendar_data_pack_parser.dart` /
  `calendar_data_pack_terms.dart` / `calendar_data_pack_validator.dart` /
  `calendar_data_pack_importer.dart`閿涘牐袙閺嬫劏鍟嬮弽锟犵崣閳帊鎱ㄧ拋鈶╁晪**閸樼喎鐡欓幓鎰唉**閿?
- `store/`閿涙瓪calendar_data_store.dart`閿涘牅绮ㄩ崒銊ㄧ珶閻?+ 閸愬懎鐡ㄧ€圭偟骞囬敍?
  `stored_solar_term_provider.dart`閿涘牅绮ㄩ崒銊㈠晪Provider閿涘矁顥婃潪钘夋彥閻撗冩倵瀵洘鎼告穱婵囧瘮閸氬本顒為敍?

### 閺傛澘顤冮敍鍫熸殶閹诡喕绗屽銉ュ徔閿?
- `assets/calendar/2019..2028.calendar.json` 閳?缁夊秴鐡欓弫鐗堝祦閸?10 楠炶揪绱?
  娑撳海鏁ら幋宄邦嚤閸?*閸氬奔绔寸粔宥嗙壐瀵?*閿涘牅绗夌€涙ê婀妴灞藉敶缂冾喛铔?Dart 鐢悂鍣洪妴宥囨畱缁楊兛绨╂總妞剧秼缁紮绱?
- `tool/calendar_pack_gen/generate_calendar_packs.dart` 閳?瀵偓閸欐垿妯佸▓鐢垫晸閹存劕娅掗敍?
  **娑撳秴寮稉?App 鏉╂劘顢戦弮?*閿涙稒娼堟繛浣圭爱缂傛挸鐡?`.cache/` 瀹?gitignore

### 閺佺増宓侀弶銉︾爱閿涘牆褰叉径宥嗙壋閿?
- 妫ｆ瑦鑵愭径鈺傛瀮閸?HKO閵嗗奔绨╅崡浣告磽缁♀偓濮橈絿娈戦弮銉︽埂閸欏﹥妾梺鎾圭。閺傛瑣鈧稄绱盚KO 濞夈劍妲戦崗璺恒亯閺傚洦鏆熼幑顔芥降閼?
  閼诲崬娴?HM Nautical Almanac Office 娑撳海绶ㄩ崶?United States Naval Observatory閿?
- 閸樼喎顫愰崺鍝勫櫙 HKT閿涘湶TC+8閿涘鍟?缂佺喍绔撮幎妯肩暬 UTC閿?
- **閺夈儲绨稉鍝勫瀻闁界喓楠囬敍宀€顫楁担宥嗕航娑?`:00`**閿涘牆顩х€圭偠顔囪ぐ鏇礉娑撳秷娅勯弸鍕潡缁狙呯翱鎼达讣绱氶敍?
- 鐟曞棛娲?2019閳?028閿涘湚KO 閸忣剙绱戦懠鍐ㄦ纯閿涘绱辨稉?NAOJ 閸︺劑鍣搁崣鐘插嬀娴犱粙鈧劙銆嶆稉鈧懛娣偓?

### 閸忔娊鏁總鎴犲
- 閺堝牆缂撴潏鍦櫕閿涙瓪instant < 娴溿倛濡?閳?閺冄勬箑瀵ょ閿涘畭instant >= 娴溿倛濡?閳?閺傜増婀€瀵ょ閿涘牅绗侀幀浣规焽鐟封偓閿涘绱?
- 缂傚搫鍕炬禒鑺ュ `CalendarDataMissing`閿涙稑顕遍崗銉ュ斧鐎涙劖鈧嶇礄閺嶏繝鐛欓柅姘崇箖閸撳秳绗夐崘娆庣波閸岊煉绱氶敍?
- 娣囶喛顓归崶娑欌偓?NEW / UPDATE / SAME / DOWNGRADE閿涘矂妾风痪褎瀚嗙紒婵呯瑬閺冄勬殶閹诡喕绗夐崣姗堢幢
- 閺冦儳鏅敍姘波鎼存挻妫﹂張澶夊敩閻焦婀崘鑽ょ波鐟欏嫬鍨?閳?閺嶇绺剧仦鍌氱杽閻滈琚辩粔宥呰嫙鐟曚焦鐪伴弰鎯х础娴肩姴鍙嗛妴?

### 濞村鐦敍?103閿涘苯鍙?232/232 闁俺绻冮敍娌榥alyze 0 issue閿?
`test/domain/calendar/`閿涙anzhi_day / xun_kong / day_boundary /
month_branch_resolver / calendar_data_pack_parser / calendar_data_pack_validator /
calendar_pack_import / calendar_engine / offline_gate閿? 婢剁懓鍙?fixtures閿?

### 閺堫亜浠?
閸樺棙纭剁粻锛勬倞 UI閵嗕礁顕遍崗銉﹀瘻闁筋喓鈧焦鏋冩禒鍫曗偓澶嬪閸ｃ劊鈧浇顩惄鏍€樼拋銈呰剨缁愭绱辩€瑰本鏆ｆ径鈺傛瀮缁犳纭堕敍?
閺冮缚鈥?/ 閺堝牏鐗?/ 閺冦儱鍟?/ 缁佺偟鍘?/ 閸ユ稒鐓寸€瑰本鏆ｇ化鑽ょ埠閵?

---

## 閹烘帞娲忓鏇熸惛 R3 閸楋缚缍嬬仦?閳?GUAYAN-2.0-R3-ENGINE-A閿?026-09-11閿涘本婀崣鎴濈閿?

> **閹烘帞娲忔禒搴㈢川缁€鐑樸€傚鍫濆綁閹存劗婀＄€圭偠顓哥粻妞尖偓?* 缁?Dart 妫板棗鐓欑仦鍌︾礉闂?Flutter 娓氭繆绂嗛敍?
> Widget 娑撯偓瀵板绗夊妤勫殰鐞涘本甯撻崡锔肩礄閹槒顓搁崚?鎼?0閿涘鈧倹婀版潪顔款洬閻?R3 濞撳懎宕?12 妞ら€涜厬閻?9 妞ゅ箍鈧?

### 閺傛澘顤冮敍鍧檌b/domain/ 閳?閸╄櫣顢呴崸鎰垼閿?
- `wu_xing.dart` 閳?娴滄棁顢?+ 閻㈢喎鍘犻敍娌梤elationTo(self)` 閺勵垰鍙氭禍鎻掑灲鐎规艾鏁稉鈧崗銉ュ經
- `di_zhi.dart` 閳?閸椾椒绨╅崷鐗堟暜閿涙矮绨茬悰?/ 闂冩挳妲?/ 閸忣厼鍟?/ 閸忣厼鎮?
- `tian_gan.dart` 閳?閸椾礁銇夐獮璇х窗娴滄棁顢?/ 闂冩挳妲?/ 閸忣厼宕勯悽鎻掔摍閸欐牕鍏?

### 閺傛澘顤冮敍鍧檌b/domain/casting/ 閳?閹烘帞娲忓鏇熸惛閿?
- `bagua.dart` 閳?閸忣偄宕烽敍鍫滅瑏閻栨槒鍤滄稉瀣偓灞肩瑐閿? 閸楋妇顑?+ 娴滄棁顢?+ 閸忓牆銇夋惔?
- `najia.dart` 閳?缁惧磭鏁崇悰顭掔礄楠炲弶鏁敍澶涚窗娑斿墽鎾奸悽鎻掞紝閵嗕礁娼崇痪鍏呯閻ч潻绱遍崘鍛樆閸楋箑鍨庨崚顐ヮ棅閸?
- `palace.dart` 閳?娴滎剚鍩ч崗顐㈩唫閸楋箑绨?+ 娑撴牕绨查敍鍫㈢暬濞夋洜鏁撻幋鎰剁礉闂堢偟鈥栫紓鏍垳 64 閺夆槄绱?
- `hexagram_names.dart` 閳?閸忣厼宕勯崶娑樺捶閸氬秷銆冮敍鍫滅瑐閸?鑴?娑撳宕烽敍?
- `hexagram64.dart` 閳?閸忣厾鍩㈤梼鎾Ъ 閳?閸楋箑鎮?/ 鐎诡偂缍?/ 娑撴牕绨?
- `six_relative.dart` 閳?閸忣厺缈伴敍鍫滀簰鐎诡偂缍呮禍鏃囶攽娑撴亽鈧本鍨滈妴宥忕礆
- `six_spirit.dart` 閳?閸忣厾顨ｉ敍鍫熷瘻閺冦儱鍏辩挧铚傜伐閿涘矁鍤滈崚婵堝煝閸氭垳绗傛い鐑樺笓閿?
- `cast_chart.dart` 閳?閹烘帞娲忕紒鎾寸亯濡€崇€烽敍鍦昦stLine / CastChart閿?
- `casting_engine.dart` 閳?瀵洘鎼哥紒鍕棅閿涙碍婀伴崡?/ 閸欐ê宕?/ 閸斻劌褰?/ 缁惧磭鏁?/ 娑撴牕绨?/ 閸忣厺缈?/ 閸忣厾顨?

### 閸忔娊鏁總鎴犲
- 娑撴牕绨查悽渚库偓灞炬拱鐎诡偄宕烽柅鎰煝缂堟槒娴?閳?濞撴悂鐡婇崶鐐电倳閸ユ稓鍩?閳?瑜版帡鐡婃潻妯哄斧閸愬懎宕烽妴宥嗗腹鐎电》绱?
  娑撴牜鍩㈡惔蹇撳灙閹帊璐?6/1/2/3/4/5/4/3閿涘奔绗夌紒瀛樺Б 64 閺夛紕鈥栫紓鏍垳鐞涱煉绱?
- **閸欐ê宕烽崗顓濈堪娴犲秴褰囬張顒€宕锋稊瀣唫**娑撴亽鈧本鍨滈妴宥忕礄娴肩姷绮洪崶鍝勭暰鐟欏嫬鍨敍澶涚幢
- 闂堟瑥宕锋稉宥囨晸閹存劕褰夐崡锔肩幢閺冪姵妫╅獮鍙夋閸忣厾顨ｆ稉?null閿涙盯娼▔鏇＄翻閸忋儲濮忓鍌氱埗閵?

### 濞村鐦敍?23閿涘苯鍙?129/129 闁俺绻冮敍娌榥alyze 0 issue閿?
- `test/domain/casting/hexagram_tables_test.dart` 閳?鐞涖劌鐣弫瀛樷偓褌绗岀憴鍕灟濞村鐦?
- `test/domain/casting/casting_engine_test.dart` 閳?缂佸繐鍚€閹烘帞娲忕€靛湱鍙?
  閿涘牅鍜曟稉鍝勩亯 / 閸с倓璐熼崷?/ 濞夎棄鍖楅崪?閸忋劎鍩㈢痪宕囨暢璺崗顓濈堪璺稉鏍х安閿?

### 閺堫亜浠涢敍鍦?-B閿?
- 閸ユ稒鐓?/ 閺堝牆缂?/ 閺冦儴鏅?/ 閺冾剛鈹栭敍鍫ユ付楠炲弶鏁崢鍡樼《 + 閼哄倹鐨甸幒銊х暬閿涘绱?
- 瀵洘鎼搁幒銉ュ弳鐎光€冲捶妞ょ绱濋弴鎸庡床 `ReviewTraditionalProfile` 閸楃姳缍呯€涙顔岄妴?

---

## 閸╄櫣鍤庨弨璺哄經 閳?GUAYAN-2.0-R5-BASELINE-CLOSEOUT閿?026-09-10閿涘本婀崣鎴濈閿?

> 閺€璺哄經 `3c00187` 闁鏆€閸╄櫣鍤庨敍姘笓閸?lines 妞ゅ搫绨?Bug 閻欘剛鐝涢拃钘夌氨閿涘潉7266332`閿涘绱?
> 鐎光€冲捶 4 娑擃亞瀛╁ù瀣偓鎰般€嶆總鎴犲鐎孤ゎ吀閿? 妞?TEST STALE閵? 妞よ璐╅崥鍫礆閿涘本浠径宥呭弿闁插繑绁寸拠鏇犺雹閼瑰眰鈧?

- `lib/services/draft/casting_draft.dart` 閳?demo().lines 閺€鐟板磳鎼村骏绱濋柨浣诡劥
  `index = position - 1` 婵傛垹瀹抽敍娌梒asting_page_test.dart` 鐞涖儵鈧劗鍩㈡担宥呮礀瑜?
- `lib/presentation/review/widgets/review_hexagram_line_row.dart` 閳?
  娑?閸欐ê宕烽弬鍥ㄦ拱閸掓顔旂亸渚€銆婇敍?4/88 鐠佹崘顓?px閿涘苯鍨紓妯款梿閸擃亙绗夐崢瀣煝濡叉枻绱氶敍?
  缁粯鏋冨锝咁嚠姒绘劕鐤勯梽鍛唨缁?18/24/34 娑?FittedBox(contain)
- `lib/presentation/review/widgets/review_shensha_card.dart` 閳?缁粯鏋冨锝嗘暭娑?
  閵嗗本鏆熼幑顕€鈹嶉崝銊ユ祼鐎?4 閸掓绱欓幐澶婄杽闂勫懏鏆熼幑顔借閺屾搫绱濋弮鐘插繁閸掑墎鈹栭崡鐘辩秴閿涘鈧稄绱辩粔濠氭珟閺堫亙濞囬悽?import
- `test/presentation/review/review_page_test.dart` 閳?F1 閸╄櫣鍤庨敍鍫濆彋鐞涘苯鍙℃禍顐㈢唨缁?+
  閹?3 閺夆€崇唨缁惧灝鐢敍灞肩瑝缂佹垹绮风€电懓娼楅弽鍥风礆/ F2 缁佺偟鍘奸敍鍫熷瘻閺佺増宓佸〒鍙夌厠閺冪姴宕版担宥忕礆/ F3 閸╃儤婀版穱鈩冧紖
  閿涘牆鎮庨獮鎯邦攽娣団剝浼呴崷銊ユ簚閿? F4 鐡掑懘鏆辩痪鎶界叾閿涘牏缂夐弨鐐￥閸忓啿鍨總鎴犲 + 娑撹褰夐崡锕€寮绘笟褌绗夐崢瀣煝濡叉枻绱?
  閸ユ稒绁撮柌宥呭晸
- 妤犲矁鐦夐敍姝爈utter test 106/106 闁俺绻冮敍娌榥alyze 閺堫剝鐤嗛弬鍥︽ 0 issue閿涙稒妫ゆ笟婵婄濞搭喖濮╅妴?

---

## 鐎光€冲捶妫ｆ牕鐫?R4 璺?Baseline Alignment 鐎规氨顭?閳?GUAYAN-2.0-REVIEW-BASELINE-R4閿?026-08-31閿涘本婀崣鎴濈閿?

> 閸欘亜濮╂稉銈勯嚋缂佸嫪娆㈤敍鍫濆彋閻栬宕烽惄?+ 缁佺偟鍘奸敍澶涚礉閸忔湹缍戝鎻掔暰缁?UI 娑撯偓瀵板绗夐崝銊ｂ偓?
> 閻╊喗鐖ｉ敍姘辨埂濮濓絽缂撶粩?鐞涘苯鐔€缁?娑?閸掓ぞ鑵戣箛鍐殠"閿涘本绉烽悘顓☆潒鐟欏寮顔衡偓?

### 閸忣厾鍩㈤崡锔炬磸閿涘澁eview_hexagram_line_row.dart 闁插秴鍟撻敍?
- **Primary Baseline = RowTop + 19**閿涙艾鍙氱粊?/ 娴煎繒顨? / 娴煎繒顨? / 娑撹宕峰锝嗘瀮 /
  娑撹宕锋稉鏍х安 / 閸欐ê宕峰锝嗘瀮 / 閸欐ê宕锋稉鏍х安 閸忋劑鍎撮悽?Flutter `Baseline` 閺佹澘顒熼柨浣哥暰閸氬奔绔撮弶鈥崇唨缁惧尅绱?
- **NaYin Baseline = RowTop + 35**閿涙矮瀵岄崡?閸欐ê宕风痪鎶界叾閸氬嫯鍤滅仦鍛厬娴滃孩顒滈弬鍥у灙閿?
- 鐞涘矂鐝?48閿涙稑鍨稉顓炵妇閸愯崵绮ㄩ敍鍫濆彋缁?2 娴煎繒顨?璺?2 娴煎繒顨?璺?00 娑撹宕峰锝嗘瀮174 娑撹宕烽悥?22
  娑撴牕绨?50 閸斻劎鍩?68 缁狀厼銇?80 閸欐ê宕峰锝嗘瀮318 閸欐ê宕烽悥?58 閸欐ê宕锋稉鏍х安388閿涘绱?
- 鐎涙褰跨仦鍌滈獓閹稿鐣剧粙鍖＄窗閸忣厾顨?9.4 鐢瓕顫?/ 娴煎繒顨?9 鐢瓕顫?/ 娑撴牕绨?8.8 鐢瓕顫?/
  濮濓絾鏋?10.5 閸旂姷鐭栭敍鍧檌nePrimary #314D59閿? 缁炬娊鐓?9 鐢瓕顫夐敍?
- 閺佺顢?400 鐠佹崘顓搁崸鎰垼缁屾椽妫?+ FittedBox(scaleDown) 閼奉亪鈧倸绨查敍鍫ｎ攽閸愬懏妫ゆ潏瑙勵攱閿?
  閸掑棗澹婄痪璺ㄦ暠鐞涖劍鐗哥仦鍌滃缁斿绮崚璁圭礉娣囨繆鐦?FittedBox 閻栧爼鐝幁?48閵嗕椒绗夐崑姘辨棻閸氭垹缂夐弨鎾呯礆閿?
- 閻栫粯蝎 24鑴? / 閸斻劎鍩?12鑴?2 / 缁狀厼銇?6 閸ュ搫鐣鹃敍灞炬瀮閺堫兛绗夋笟闈涘窗閵?

### 缁佺偟鍘奸敍鍧甧view_shensha_card.dart閿?
- **FIXED 4鑴? Grid**閿涙碍鐗哥€?89閵嗕焦鐗告?18閵嗕礁鍨捄?6閵嗕浇顢戠捄?4閿涘牊鏆熼幑顕€鈹嶉崝顭掔礉
  <16 妞ゅ湱鏆€缁屽搫宕版担宥勭箽閹?4鑴?閿?16 閹靛秴濮炵粭?5 鐞涘矉绱氶敍娑氼洣濮濄垼鍤滈悽?Wrap閿?
- 鐎涙褰?9.4 / w600 / #5C7078閿涙稓顑?4 鐞涘本妗堟潻婊冩躬 Card 閸愬懌鈧?

### 鐞涖劌銇?
- guaTitle 13 / guaName 10.8閿涘澁eview_hexagram_result_table.dart閿?

### Token
- 閺傛澘顤?`linePrimary #314D59`閵嗕梗shenShaItem #5C7078`

### 濞村鐦敍?3閿?
- R4 閸╄櫣鍤庨弫鏉款劅闁夸礁鐣鹃敍姘愁攽閸愬懎鍙忛柈?Baseline 閳?{19, 35}閿涘奔瀵岄崺铏瑰殠 6 閺?/ 缁炬娊鐓?2 閺夆槄绱?
- R4 缁佺偟鍘奸崶鍝勭暰 4鑴?閿?6 閺嶅吋妫ゅ┃銏犲毉閵嗕礁鎮撻崚妤€顕鎰┾偓浣侯儑 4 鐞涘苯婀崡鈥冲敶閿?
- R4 缁佺偟鍘?<16 妞ょ櫢绱?2 缁岃桨缍呴崡鐘辩秴娴犲秳绻氶幐?4鑴?閵?
- 妤犲矁鐦夐敍姝爈utter test 106/106 闁俺绻冮敍娌榥alyze 閺堫剝鐤嗛弬鍥︽ 0 issue閿涙矟ebug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 鐎光€冲捶妫ｆ牕鐫?R3 閼告帡鈧倻鎻ｉ崙鎴犲 閳?GUAYAN-2.0-REVIEW-ONSCREEN-R3閿?026-08-31閿涘本婀崣鎴濈閿?

> 閻╊喗鐖ｉ敍?*閸忣厾鍩㈤崗顓☆攽韫囧懘銆忛崷銊ヮ吀閸楋箓顩荤仦蹇撶暚閺佹挳婀堕崙?*閿涘牏鈥栭梻銊ь洣閿涘奔绗夐幒銉ュ綀娑撳绮﹂幍宥堝厴閻鍩岄張閬嶆硻/閸掓繄鍩㈤敍澶堚偓?

### 閺堫剝鐤嗙敮鍐ㄧ湰鐟欏嫬鍨敍鍦? 閹?SVG閿?
- **閸楋箑鎮?Header 66 閳?54 DIP**閿涙矮瀵岄崡?閸欐ê宕烽弽鍥暯 + 閸楋箑鎮曢崥鍕鐞涘矉绱檋2 12 / gua 10閿?
- **娴煎繒顨ｉ弨?3 鐎涙鐓弽鐓庣础**閿涙艾鍙氭禍鑼暆缁?+ 閸︾増鏁?+ 娴滄棁顢戦敍鍧勭拹銏犵槒閺?/ 閻栬埖婀崷鐒嬮敍澶涚礉
  閺囨寧宕茬悮顐㈩啍鎼达箒顥嗛崚鍥╂畱 `鐠愵澀绗濋垾?/ 閻栨湹绔甸垾顩嗛敍娑欑川缁€鐑樻殶閹?12 妞ょ懓鍙忛柈銊ㄦ祮閹?
- **閸忣厾鍩㈢悰宀勭彯 56 閳?48 DIP**閿涙矮瀵?閸欐ê宕峰锝嗘瀮娴犲秳琚辩悰灞界暚閺佸瓨妯夌粈鐚寸礄閸忣厺缈伴崷鐗堟暜 10px +
  缁炬娊鐓?8.8px閿涘绱?*閺冪姷娓烽悾銉ュ娇**閿涙稑鍨€逛粙鍣哥粻妤嬬礄閸忣厾顨?24 / 娴煎繒顨?28 / 娑撴牕绨?12 / 閸斻劎鍩?12 /
  缁狀厼銇?6 / 閻栫粯蝎 24閿涘绱?60 DIP 娑撳秵铆閸氭垶瀛╅崙?
- 缁毖冨櫨閸栨牭绱伴崶娑欑叴 44閳?0閵嗕胶顨ｉ悡?chip 24閳?9閿涘澁x9.5閵嗕礁鐡ч崣?8.8閿涘鈧竻asicInfo 84閿涘潝2 12閿涘鈧?
  妞ょ敻娼伴梻纾嬬獩 8閳?
- 鐞涖劌鐔弬鍥攳閿涙瓪閻愮懓鍤禒璁崇閻栫粯鐓￠惇瀣彠缁眹鈧浇顫夐崚娆庣贩閹诡喕绗岄崗宕囬兇婢跺洦鏁瀈

### 閺傚洣娆?
- `review_demo_data.dart` 閳?娴煎繒顨?3 鐎涙鐓弽鐓庣础閿涘牐鍌ㄧ€靛懏婀?閻栬埖婀崷?鐎涙瑥鐡欏?閸忓嫰鍘滈柌鎴斺偓锔肩礆
- `review_hexagram_line_row.dart` 閳?鐞涘矂鐝?48閵嗕礁鍨€逛粙鍣哥粻妞尖偓浣哥摟閸欓攱瀵?R3 SVG
- `review_hexagram_result_table.dart` 閳?Header 54閵嗕浇銆冪亸鐐瀮濡?
- `review_basic_info_card.dart` / `review_four_pillars_strip.dart` /
  `review_shensha_card.dart` / `review_page.dart` 閳?缁毖冨櫨閸?
- `test/presentation/review/review_page_test.dart` 閳?閺傛澘顤冪涵顒勬，缁備焦绁寸拠鏇窗
  430鑴?32 娑撳鍙氶悥璇插彋鐞?+ 鐞涖劌鐔崷銊ヮ嚤閼割亜灏稊瀣╃瑐鐎瑰本鏆ｉ崣顖濐潌閿涙稐绱＄粊鐐存焽鐟封偓閺囧瓨鏌?
- 妤犲矁鐦夐敍姝爈utter test 103/103 闁俺绻冮敍娌榥alyze 閺堫剝鐤嗛弬鍥︽ 0 issue閿涙矟ebug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 鐎光€冲捶娑撯偓鐏炲繒澧楅弨璺哄經 閳?GUAYAN-2.0-REVIEW-ONSCREEN閿?026-08-31閿涘本婀崣鎴濈閿?

> 閺佺繝缍嬮弨璺哄經閿涙矮绔寸仦蹇撳帥閻鐣弫鏉戠唨閺堫兛淇婇幁?+ 缁佺偟鍘?+ 閸ユ稒鐓?+ 鐎瑰本鏆ｉ崡锔炬磸閿?
> 閻愯鐓囨稉鈧悥璇叉倵閸愬秴鑴婇崗宕囬兇閻掞妇鍋ｉ敍鍦攐ttom Sheet閿涘鈧倸浜ゆ惔鏇⌒掗崘?娑撳搫顢ｉ崗宕囬兇閻掞妇鍋ｉ幎濠傚捶閻╂ɑ灏嬬亸?閵?

### 鐎光€冲捶妞?
- `review_page.dart` 閳?娑撯偓鐏炲繐绔风仦鈧敍娆皃pBar 閳?BasicInfo 閳?閸ユ稒鐓?閳?缁佺偟鍘?4鑴? 閳?鐎瑰本鏆ｉ崡锔炬磸閿?
  閵嗗苯鍙х化鑽ゅ妽閻愬箍鈧秳绗夐崘宥呯埗妞逛紮绱欓崚鐘绘珟 RelationFocusCard閿涘绱遍悙鍦煝妤傛ü瀵?+ 瀵懓鐪伴敍?
  閺傛澘顤?`onOpenRelations` 閸ョ偠鐨熼敍鍦損p Shell 閸掑洤鍩岄崗宕囬兇 Tab閿?
- `widgets/review_basic_info_card.dart` 閳?缁毖冨櫨閸楁洖宕遍敍姘舵６娴?+ 閺傜懓绱?chip + 閸忣剙宸?閸愭粌宸绘稉銈嗙埉 +
  meta閿涘牐顫夐崚娆忓瘶 v1 璺?閹靛濮╃挧宄板捶 璺?閹烘帞娲忓鑼晸閹存劧绱?
- `widgets/review_four_pillars_strip.dart` 閳?soft 鎼?44 妤傛﹫绱漷eal/warm 閸欏矁澹婇敍灞炬３缁屽搫褰哥€靛綊缍?
- `widgets/review_shensha_card.dart` 閳?chip 20 妤傛ǜ鈧線妫跨捄?4 閻ㄥ嫮鎻ｉ崙?4鑴? 缂冩垶鐗?
- `widgets/review_hexagram_result_table.dart` 閳?鐞涖劌銇?66 妤傛﹫绱欓妴鎰瘜閸楋负鈧?閵嗘劕褰夐崡锔衡偓鎴礆+ 鐞涘瞼鍋ｉ崙濠氣偓蹇庣炊 +
  鐞涖劌鐔妴灞界暚閺佸瓨甯撻惄?璺?閻愮懓鍤禒璁崇閻栫粯鐓￠惇瀣彠缁绗岀憴鍕灟娓氭繃宓侀妴?
- `widgets/review_hexagram_line_row.dart` 閳?**瑜拌绨抽崣鏍ㄧХ閻胶鏆愰崣?*閿涙艾鍙氭禍鎻掓勾閺€顖欑瑢缁炬娊鐓堕幏鍡曠瑐娑撳琚辩悰宀嬬幢
  11 閸掓娴愮€规碍蝎娴ｅ稄绱濋弬鍥ㄦ拱娑撳秳闀滈崡鐘靛煝濡?娑撴牕绨插Σ鏂ょ幢鐞涘苯褰查悙鐧哥礄妤傛ü瀵掗敍?
- `widgets/review_line_detail_sheet.dart`閿涘牊鏌婃晶鐑囩礆閳?閻愬湱鍩?Bottom Sheet閿涙艾缍嬮崜宥囧煝娣団剝浼?+
  閸忓磭閮撮崚妤勩€冮敍鍫熸降閼?RelationInstance閿? 閺屻儳婀呯憴鍕灟娓氭繃宓?+ 閸忓磭閮存径鍥ㄦ暈閿涘湙AP閿? 鏉╂稑鍙嗛崗宕囬兇妞?
- 閸掔娀娅?`review_relation_focus_card.dart`
- `review_page_state.dart` / `review_case_adapter.dart` 閳?閺傛澘顤?`allRelations` +
  `relationsInvolving(position)` + `relationLabel`閿涘牏鍋ｉ悥璇茶剨鐏炲倹瀵滈悥鏄忕箖濠娿倧绱濇禒宥嗘降閼?Domain閿?
- `review_demo_data.dart` 閳?濠曟梻銇氶弫鐗堝祦鐎靛綊缍堟稉鈧仦蹇曞 SVG閿涘牓妫舵禍?閸忣剙宸?09:30/閸愭粌宸?娑撳啯婀€閸椾礁鍙?璺?瀹歌櫕妞?
  閺冾剛鈹?閻㈡娊鍘滅粚鐚寸礆

### 閹烘帒宕锋い?
- `line_editor_sheet.dart` 閳?閻栨槒钖勯柅澶愩€嶉崡鈥虫祼鐎?`mainAxisExtent: 58`閿涘牃澧?8 DIP 绾剟妫粋渚婄礆閿?
  閸愬懎顔愰崹鍌滄纯鐏炲懍鑵戦敍灞兼崲娴ｆ洖鐫嗛獮?RenderFlex 濠с垹鍤?= 0閿涘牅鎱ㄦ径?BOTTOM OVERFLOWED 1.2px閿?

### 閸忓彉闊?/ Token
- `casting_tokens.dart` 閳?gua #927848閵嗕垢illarTeal #4F8685閵嗕焦鏌婃晶?pillarWarm #A8605C
- `shared/yao_glyph.dart` / `shared/moving_marker.dart` 閳?閹诲繗绔熺€硅棄瀹抽幐澶夌鐏炲繒澧?SVG 瀵邦喛鐨?
  閿涘牏鈹栨禍?1.4 / 閳煎瑓?1.6閿?

### 濞村鐦?
- `review_page_test.dart` 閳?娑撯偓鐏炲繒澧楅柅鍌炲帳 + 閻愬湱鍩㈠鐟扮湴閿涘牆鍙х化璇插灙鐞?鏉╂稑鍙嗛崗宕囬兇妞ら潧娲栫拫鍐跨礆+
  缁愬嫬鐫?360 閺冪姵瀛╅崙鐚寸幢UI-04~08 娣囨繄鏆€
- `casting_page_test.dart` 閳?閺傛澘顤冮妴宀€鍩㈢挒鈥宠剨鐏炲倻鐛庣仦?360鑴?40 閺?RenderFlex 濠с垹鍤妴宥嗙ゴ鐠?
- `foundation_test.dart` 閳?鐎光€冲捶閸掑棙鏁弬顓♀枅閺€閫涜礋 缁佺偟鍘?
- 妤犲矁鐦夐敍姝爈utter test 102/102 闁俺绻冮敍娌榥alyze 閺堫剝鐤嗛弬鍥︽ 0 issue閿涙矟ebug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 閹烘帒宕锋い?+ 鐎光€冲捶妞ら潧顤冮柌蹇庢叏濮?閳?GUAYAN-2.0-UI-CORRECTION-R2閿?026-08-30閿涘本婀崣鎴濈閿?

> 閸?R1 瀹告彃鐣剧粙鍨唨绾偓娑撳﹤浠涙晶鐐哄櫤娣囶喗顒滈敍宀€顩﹀銏ゅ櫢閺傛媽顔曠拋掳鈧倹婀版潪顔煎枙缂佹搫绱扮紒鐔剁閻栫粯蝎 24鑴?
> 閿涘牓妲?闂?缁岃桨楠告禒鍛敶闁劌锝為崗鍛瑝閸氬矉绱氶妴浣稿З閻栫粯鐖ｇ拋?12鑴?2閵嗕焦鏋冮張顑跨瑝瀵版甯囬悥姹団偓?

### 閺傛澘顤冮敍鍧檌b/presentation/shared/ 閳?閹烘帒宕?鐎光€冲捶瀵搫鍩楁径宥囨暏閿?
- `yao_glyph.dart` 閳?缂佺喍绔撮悥缁樞紒鍕閿涙瓛aoGlyph閿?4鑴?閿涘瘔ang/yin/voidYao閿? YaoKind閿?
  `YaoGlyph.fromMovement` 娓氭寧宓庡銉ュ范閿涙稓鈹栨禍锛勫煝缁屽搫绺鹃幓蹇氱珶 rx1 #7E9098 w1.5
- `moving_marker.dart` 閳?閸斻劎鍩㈤弽鍥唶缂佸嫪娆㈤敍姝乷vingMarker閿?2鑴?2閿涘矁鈧線妲?閳?#A17F45 /
  閼颁線妲?鑴?#567866閿? `MovingMarker.of` 娓氭寧宓庡銉ュ范

### 閹烘帒宕锋い鍏告叏濮?
- `casting_page.dart` 閳?閸掔娀娅庢い鍫曞劥 CastingDraftContext閿涘煪?.1閿涘绱卞锝嗘瀮妞ゅ搫绨敍?
  AppBar 閳?鐠у嘲宕烽弮鍫曟？ 閳?闂傤喕绨ㄦ穱鈩冧紖 閳?閸忣厾鍩㈣ぐ鏇炲弳 閳?鐟欏嫬鍨崠?閳?閻㈢喐鍨氶幒鎺旀磸
- `casting_time_row.dart` 閳?闁插秴鍟撴稉?88 妤傛ê宕遍悧鍥风窗閺嶅洭顣?+ 閸欏厖绗傞妴灞藉嚒鐎瑰本鍨?瀵板懎鐣崰鍕┾偓宄渉ip +
  閸忣剙宸?+ 閸愭粌宸婚敍鍩? SVG閿涙稑鍟橀崢鍡曡礋 lunarPlaceholder presentation mock閿涘瓘AP 閺嶅洦鏁為敍?
- `casting_page_state.dart` 閳?閺傛澘顤?`lunarPlaceholder(DateTime)`閿涘湙AP閿涙氨婀＄€圭偛鍟橀崢鍡樺床缁犳绶熼幒銉ュ弳閿?
- `six_yao_input_row.dart` 閳?閺咁噣鈧俺顢?= 缂傛牞绶悰?= 52 DIP閿涘煪?閿涙氨绱潏鎴炩偓浣稿涧閸欐鍎楅弲?鏉堣顢?鐎涙鍣?瀵拌姤鐖ｉ敍澶涚幢
  閻栨槒钖勬潻浣盒╅崗鍙橀煩 YaoGlyph
- `line_editor_sheet.dart` 閳?鏉╀胶些閸忓彉闊?YaoGlyph + 閸斻劎鍩㈢悰?MovingMarker
- 閸掔娀娅?`casting_draft_context.dart`閵嗕焦妫?`casting/widgets/yao_glyph.dart`

### 鐎光€冲捶妞ゅ吀鎱ㄥ?
- `review_page_state.dart` 閳?ReviewLineView閿涙iddenSpirit 閹峰棔璐?hiddenSpirit1/2閿涘牅绱＄粊鐐拌⒈閸掓绱氶敍?
  閺傛澘顤?isVoid閿涘牅瀵岄崡?閸欐ê宕烽敍瀛禝 鐞涖劎骞囨稉鎾舵暏閿涘idget 娑撳秷顓哥粻妤佹３缁岀尨绱氶敍娑氭捈闂婅櫕瀚崣閿嬫暭閸楀﹨顫?`(缁炬娊鐓?`
- `review_case_adapter.dart` / `review_demo_data.dart` 閳?娴煎繒顨ｆ稉銈呭灙 + isVoid 闁繋绱堕敍?
  濠曟梻銇氶弫鐗堝祦閹?R2 SVG #12閿涙矮绨查悥璁崇闁板鈧椒绗侀悥璁崇瑵閻㈠磭鈹栨禍鈽呯礄閺冾剛鈹栭悽鎶藉帨閿?
- `review_shensha_card.dart` 閳?缁佺偟鍘奸崶鍝勭暰 4 閸?鑴?N 鐞涘本鏆熼幑顕€鈹嶉崝銊х秹閺嶇》绱欐悅5 SVG 402鑴?78閿?
  >16 妞ゅ湱鎴风紒顓炲鐞涘矉绱?
- `review_hexagram_result_table.dart` 閳?閺堚偓缂佸牆宕烽惄妯肩矋娴犺绱欐悅6/鎼?2 SVG 402鑴?04閿涘绱?
  閸愬懎绁甸妴鎰瘜閸楋负鈧?閵嗘劕褰夐崡锔衡偓鎴炵垼妫版﹫绱欏ù鍛俺 #F8FBF9閿? 閸忣叀顢戦幒鎺旀磸 + 鐞涖劌鐔拠瀛樻
- `review_hexagram_line_row.dart` 閳?11 閸掓鍠曠紒鎿勭窗閸忣厾顨?| 娴煎繒顨? | 娴煎繒顨? | 娑撹宕烽弬鍥х摟 |
  娑撹宕烽悥缁樞?24鑴?) | 娑撹宕锋稉?鎼?| 閸斻劎鍩?12鑴?2) | 缁狀厼銇?| 閸欐ê宕烽弬鍥х摟 | 閸欐ê宕烽悥缁樞?| 閸欐ê宕锋稉?鎼存棑绱?
  閺傚洤鐡ч崚?Ellipsis 鐟佷礁澹€閿涘瞼鍩㈠Σ?娑撴牕绨插Σ钘夋祼鐎规矮绗夌悮顐￠暅閸楃媴绱欐悅11 绾剟妫粋渚婄礆
- `review_page.dart` 閳?缁夊娅?HexagramResultHeader閿涘牐銆冮崘鍛嚒閸氼偅鐖ｆ０姗堢礉闁灝鍘ら柌宥咁槻閿?
- 閸掔娀娅?`review_hexagram_result_header.dart`

### 濞村鐦?
- `test/presentation/casting/casting_page_test.dart` 閳?UI-01閿涘牊妫?DraftContext閿?
  UI-02閿涘牆鍙曢崢?閸愭粌宸婚敍? UI-03閿涘牊娅橀柅姘愁攽妤?=缂傛牞绶悰宀勭彯==52閿?
- `test/presentation/review/review_page_test.dart` 閳?UI-04閿涘牏顨ｉ悡鐐侯浕鐏?4 閸掓绱?
  UI-05閿涘牏鍩㈠Σ鐣岀埠娑撯偓 24鑴?閿? UI-06閿涘牆濮╅悥?12鑴?2閿? UI-07閿涘牐绉撮梹鎸庢瀮閺堫兛绗夐崢瀣煝閿?
  UI-08閿涘牆褰夐崡锔惧煝濡?閸欐ê宕锋稉鏍х安閸氬本妯夐敍? R1 濞村鐦柅鍌炲帳閿涘湻aoGlyph.kind閵嗕府ovingMarker閿?
- `test/presentation/shared/yao_glyph_test.dart`閿涘牊鏌婃晶鐑囩礆閳?閸忓彉闊╃紒鍕鐏忓搫顕崘鑽ょ波濞村鐦?
- `test/foundation_test.dart` 閳?鐎光€冲捶閸掑棙鏁弬顓♀枅閺€閫涜礋閵嗘劒瀵岄崡锔衡偓?

### 鐠囧瓨妲?
- 濠曟梻銇?pos2閿涘牐鈧線妲奸敍澶夊瘜閸楋附瀵滅拠顓濈疅濞撳弶鐓嬮梼铏?+ X閿涙奔VG #12 閻㈣缍旈梼?X閿涘苯鐫橀張澶嬪壈娣囶喗顒?
  閿涘牅绻氶幐渚€妲鹃梼瀹狀嚔娑斿绔撮懛杈剧礉瀹稿弶鏁為柌濠咁唶瑜版洩绱氶妴?
- 妤犲矁鐦夐敍姝爈utter test 100/100 闁俺绻冮敍娌榥alyze 閺堫剝鐤嗛弬鍥︽ 0 issue閿涙矟ebug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 鐎光€冲捶妞?XYUI 瀹搞儰缍旈崣?閳?GUAYAN-2.0-REVIEW-UI-R1閿?026-08-30閿涘本婀崣鎴濈閿?

> 閻╊喗鐖ｉ敍姘Ω閵嗗苯顓搁崡锔衡偓宥呭窗娴ｅ秹銆夌€圭偟骞囨稉杞版眽瀹搞儱鐣剧粙璺ㄦ畱 XYUI 闂€鍧椼€夐幒鎺旀磸瀹搞儰缍旈崣鑸偓?
> 鐟欏棜顫庢禒銉ゆ崲閸斺€插姛閹?SVG 娑撶儤娓舵妯圭喘閸忓牏楠囬敍娑楃炊缂佺喐甯撻惄妯虹摟濞堢绱欓崗顓狀殻/娴煎繒顨?閸忣厺缈?缁佺偟鍘?閸ユ稒鐓?閸楋箑鎮曢敍?
> 閻㈣鲸绱ㄧ粈鐑樸€傚鍫熷絹娓氭冻绱濋惇鐔风杽鐠侊紕鐣荤仦鐐叉倵缂侇厽甯撻惄妯虹穿閹垮函绱橰3閿涘鈧柡鈧?閺堫剝鐤嗘稉宥呬粵閸嬪洤鍙氶悥鑽ょ暬濞夋洏鈧?

### 閺傛澘顤冮敍鍧檌b/presentation/review/閿?
- `review_page.dart`閿涘牓鍣搁崘娆忓窗娴ｅ秹銆夐敍澶嗏偓?鐎光€冲捶瀹搞儰缍旈崣甯窗SafeArea 閳?ReviewAppBar 閳?Expanded
  SingleChildScrollView閿涘湐asicInfo 閳?ShenSha 閳?FourPillars 閳?HexagramHeader 閳?
  HexagramTable 閳?RelationFocus閿涘绱盡ainTabBar 閸ュ搫鐣鹃崷?App Shell
- `review_page_state.dart` 閳?缁?Dart 閻樿埖鈧焦膩閸ㄥ绱癛eviewPageState閿涘煪? 閸忋劑鍎寸€涙顔岄敍?
  ReviewLineView / ReviewChangedLine / ReviewShenShaItem + formatSolar
- `review_case_adapter.dart` 閳?HexagramCase + ReviewTraditionalProfile 閳?ReviewPageState閿?
  閻掞妇鍋ｉ崗宕囬兇娑撯偓瀵板娼甸懛?calculateRelations閿涘湯table Relation Identity閿涘绱濈粋浣诡剾 UI 闁插秶鐣?
- `review_demo_data.dart` 閳?鐟欏棜顫庣€规氨顭堝鏃傘仛閺佺増宓侀敍鍦玍G 闁劙銆嶆潪顒€缍嶉敍姘景鐏炲崬鎹€閳帗杈板鏉戞炊閵?6 缁佺偟鍘奸妴?
  娑撴瑥宕嶉獮缈犵瑵閻㈣櫕婀€娑撴瑥鐡欓弮銉ょ闁板妞傞妴浣稿彋缁?娴煎繒顨?閸忣厺缈?缁炬娊鐓?娑撴牕绨查妴浣疯⒈閸斻劎鍩㈤敍?
- `widgets/review_app_bar.dart` 閳?妞よ埖鐖敍鍫ｇ箲閸?chevron + 鐎光€冲捶 + 閹烘帞娲忕紒鎾寸亯閿涘眲?閿?
- `widgets/review_basic_info_card.dart` 閳?閺傜懓绱?娴滃銆?闂冨啿宸?闂冩潙宸?+ 瀹歌尙鏁撻幋?chip閿涘煪?閿?
- `widgets/review_shensha_card.dart` 閳?缁佺偟鍘奸悪顒傜彌閸楋紕澧?+ 閼奉亪鈧倸绨?Wrap 閺嶅洨顒风純鎴炵壐閿涘煪?/鎼?閿?
- `widgets/review_four_pillars_strip.dart` 閳?楠?閺?閺?閺?閺冾剛鈹?濡亜鎮滅槐褍鍣?Strip閿涘煪?閿?
- `widgets/review_hexagram_result_header.dart` 閳?閹烘帞娲忕紒鎾寸亯 + 娑?閸欐ê宕烽弽鍥暯閿涘煪?閿?
- `widgets/review_hexagram_result_table.dart` 閳?閸忣厾鍩㈤幒鎺旀磸娑撹缍嬬悰顭掔礄鎼?閿涘奔绗傞悥璇叉躬娑撳﹤鍨甸悥璇叉躬娑撳绱?
- `widgets/review_hexagram_line_row.dart` 閳?閸楁洝顢戦敍姘彋缁?| 娑撹宕烽敍鍫濇儓娴煎繒顨ｉ敍澧?閸欐ê宕烽敍?
  閻栨槒钖勬径宥囨暏 YaoGlyph 閻垽鍣虹紒妯哄煑閿涘奔绗樻惔?閸斻劎鍩㈢粻顓炪仈閻垽鍣?
- `widgets/review_relation_focus_card.dart` 閳?閸忓磭閮撮悞锔惧仯閸椻槄绱欐悅7閿涙矮绗樻惔?閻㈢喎鍘?閸ョ偛銇旈悽鐔锋礀婢舵潙鍘?
  閸忋儱褰?+ 閺屻儳婀呯憴鍕灟娓氭繃宓?閳?鐠哄疇娴嗙憴鍕灟鎼存搫绱?

### 娣囶喗鏁?
- `lib/presentation/casting/casting_tokens.dart` 閳?鐞涖儱鍘?鎼? Token閿涙elationRed 缁?/
  relationBlue 缁?/ traditionalGold / pillarTeal閿涘潰ovingCircle 閸掝偄鎮曢崚?traditionalGold閿?
- `lib/presentation/casting/casting_page.dart` 閳?閺傛澘顤冮崣顖炩偓?`onGenerated` 閸ョ偠鐨熼敍鍫㈡晸閹存劕鎮楅柅姘辩叀 Shell閿?
- `lib/app/app_shell.dart` 閳?鐎光€冲捶妞ら潧鎮撻弽鐑芥閽樺繐鍙忕仦鈧?AppBar閿涘牐鍤滅敮?XYUI TopBar閿涘绱?
  `_latestCase` 濡椼儲甯撮幒鎺戝捶閻㈢喐鍨氱紒鎾寸亯 閳?鐎光€冲捶妞ょ绱橳12 閺佺増宓侀幒銉ュ弳閿?
- `test/foundation_test.dart` 閳?鐎光€冲捶閸掑棙鏁弬顓♀枅閺€閫涜礋閺冪姴鍙忕仦鈧?AppBar + 鐎瑰本鏆ｉ幒鎺旀磸/閸忓磭閮撮悞锔惧仯
- `test/presentation/review/review_page_test.dart`閿涘牊鏌婃晶鐑囩礆閳?鎼?2 Test A閳ユ弻 + 闁倿鍘ら崳銊ュ礋濞?

### 閺佺増宓侀幒銉ュ弳閿涘湵12/T13閿?
- 閹烘帒宕锋い鐢垫晸閹存劕鎮楃紒?`onGenerated` 閹?HexagramCase 娴溿倗绮?App Shell閿涘苯顓搁崡锕傘€夊〒鍙夌厠閻喎鐤勯崡锔跨伐閿?
  閸忣厾鍩?閸︾増鏁?閺冨爼妫?鐟欏嫬鍨悧鍫熸拱閺夈儴鍤?Domain閿涘苯鍙х化鑽ゅ妽閻愬湱鏁?calculateRelations 鐠侊紕鐣婚敍?
  閸忣厾顨?娴煎繒顨?閸忣厺缈?缁佺偟鍘?閸ユ稒鐓?閸楋箑鎮曠粵澶夌炊缂佺喎鐡у▓鐢垫埂鐎圭偛宕锋笟瀣╃瑓閺勬儳绱＄純顔锯敄閿涘湙AP閿涙碍甯撻惄妯虹穿閹?R3閿涘鈧?
- 閺堫亞鏁撻幋鎰箖閸楋缚绶ラ弮璺侯吀閸楋箓銆夊〒鍙夌厠鐟欏棜顫庣€规氨顭堝鏃傘仛閹烘帞娲忛敍鍫濇儓鐎瑰本鏆ｆ导鐘电埠濡楋絾顢嶉敍澶涚礉娓氭稐姹夊銉潒鐟欏鐛欓弨韬测偓?

### 鐠囧瓨妲?
- 濠曟梻銇氶悥璇茬碍娑?Domain 婵傛垹瀹虫稉鈧懛杈剧礄1 閸掓繄鍩?.. 6 娑撳﹦鍩㈤崡鍥х碍閿涘绱遍崝銊у煝閺嶅洩顔囬柆闈涙儕 鎼?2 D/E 鐠囶厺绠?
  閿涘牐鈧線妲?闂冨磭鍩㈢€圭偟鍤?+ X閿涘绱濇稉?SVG 娑擃亜鍩嗛悥鑽ゅ殠閻㈢粯纭剁€涙ê婀稉鈧径鍕箒閹板繋鎱ㄥ锝忕礄Row5閿涘绱濆鑼额唶瑜版洏鈧?
- 妤犲矁鐦夐敍姝爈utter test 84/84 闁俺绻冮敍娌榥alyze 閺堫剝鐤嗛弬鍥︽ 0 issue閿?1 閺夆剝妫禒锝囩垳閸涘﹨顒熼張顏勫З閿涘绱?
  debug APK 閺嬪嫬缂撻柅姘崇箖閵?

---

## 閸楋妇婧?2.0 Foundation 閳?feat/guayan-2.0

> 閸掑棙鏁敍姝歠eat/guayan-2.0`閿涘牏鎴烽幍?GitHub 閸樺棗褰堕敍?.0 App 閺嬭埖鐎柌宥嗘煀瀵偓閸欐埊绱濋弮褍濮涢懗鑺ユ弓閺夈儲鏁圭紓鏍箻閵嗗矁顔勭紒鍐︹偓宥呭弳閸欙綇绱?

### 閺傛澘顤?2.0 妤犮劍鐏?
- **閸忋儱褰涢弸浣虹暆閸?*閿涙瓪lib/main.dart` 閸欘亜浠?`runApp(const GuayanApp())`閿涘奔绗夐崘宥堢儲閺?HomePage閵嗕椒绗夐崘宥呭灥婵瀵查弮?MistakeStore閵?
- **`lib/app/`**閿?.0 鎼存梻鏁ゆ竟?
  - `app.dart` 閳?`GuayanApp`閿涙瓉aterialApp 缂佸嫯顥?+ 閸忋劌鐪稉濠氼暯閿涘牊绁懝灞傗偓浣烘彛閸戞埊绱?
  - `app_shell.dart` 閳?`AppShell`閿涙ndexedStack 閻樿埖鈧椒绻氶幐?+ GuayanMainTabBar 娴滄柧瀵岀€佃壈鍩呴敍鍦禮UI閿涘绱漙selectedIndex` 閸楁洑绔撮弶鍐ㄢ枆閺夈儲绨敍宀勭帛鐠?Index 0閿涘牊甯撻崡锔肩礆閿涙稒甯撻崡锕傘€夐懛顏勭敨 XYUI TopBar閿涘牊妫ら崗銊ョ湰 AppBar閿?
  - `navigation/main_tabs.dart` 閳?濮濓絽绱℃禍褍鎼?IA閿涙碍甯撻崡?鐎光€冲捶/閸忓磭閮?閸楋缚绶?鐠侇厾绮岄敍鍫ャ€庢惔蹇撴祼鐎规熬绱氶敍姹砤inTab 閸?title / iconBuilder / builder
  - `navigation/guayan_main_tab_bar.dart` 閳?XYUI 閸栨牕绨抽柈銊ヮ嚤閼割亷绱欐禒璇插娑?鎼?5閿涘绱板ú璇插З鎼存洝澹?+ 閻垽鍣洪崶鐐垼閿涘湙uayanTabIcons閿? 閺嶅洨顒?
  - `more_menu.dart` 閳?閵嗗本娲挎径姘モ偓宥堝綅閸楁洩绱扮憴鍕灟鎼?/ 鐠佸墽鐤?/ 閸忓厖绨敍鍫熸暜閹镐浇鍤滅€规矮绠?icon閿涘本甯撻崡锕傘€夐悽銊ょ瑏閻愯鐗卞蹇ョ礆
- **`lib/core/constants/app_info.dart`**閿涙艾绨查悽銊ユ倳閵嗗苯宕烽惇绗衡偓宥冣偓浣稿敶闁劎澧楅張顑锯偓浣峰瘜妫版顫掔€涙劘澹婄敮鎼佸櫤
- **`lib/domain/`閿涘牓顣╅悾娆欑礆**閿涙UAYAN-2.0-DOMAIN 闂冭埖顔岄崷銊︻劃瀵よ櫣鐝?HexagramCase / LineState / RelationInstance / RelationNote 缁?
- **`lib/application/`閿涘牓顣╅悾娆欑礆**閿涙艾鎮楃紒顓犳暏娓氬鐪伴敍姹undation 闂冭埖顔屾禒?AppShell 閻?StatefulWidget閿涘奔绗夊鏇炲弳閻樿埖鈧胶顓搁悶鍡橆攱閺?
- **`lib/presentation/`**閿涙矮绨叉稉顏冨瘜妞ょ敻娼?+ 鐟欏嫬鍨惔?鐠佸墽鐤?閸忓厖绨?
  - `casting/casting_page.dart` 閳?閹烘帒宕锋い纰夌窗XYUI 閹烘帒宕峰銉ょ稊閸欏府绱橰1 鐎规氨顭堢敮鍐ㄧ湰閿涙俺鎹ｉ崡锔芥闂?閳?闂傤喕绨ㄦ穱鈩冧紖 閳?閸忣厾鍩㈣ぐ鏇炲弳 閳?鐟欏嫬鍨崠?閳?閻㈢喐鍨氶幒鎺旀磸閿?
  - `casting/casting_tokens.dart` 閳?XYUI 鐟欏棜顫?Token閿涘牅鎹㈤崝鈥插姛 鎼? 鐎规氨顭堥崐纭风礉閹烘帒宕锋い?+ 鎼存洟鍎寸€佃壈鍩呴崗杈╂暏閿?
  - `casting/casting_page_state.dart` 閳?GenerationState / DraftState / CastingPageState閿涘煪? 閸忋劑鍎寸€涙顔岄敍?
  - `casting/widgets/` 閳?casting_app_bar / draft_context / time_row / question_row / six_yao_input_panel / six_yao_input_row / yao_glyph / rule_pack_row / generate_row / chip / 閸ユ稐閲滅紓鏍帆瀵懓鐪伴敍鍧檌ne/time/question/rule_pack sheet閿?
  - `review/review_page.dart` 閳?鐎光€冲捶瀹搞儰缍旈崣?
  - `relations/relations_page.dart` 閳?閸忓磭閮村銉ょ稊閸?
  - `cases/cases_page.dart` 閳?閸楋缚绶ュ銉ょ稊閸?
  - `training/training_page.dart` 閳?鐠侇厾绮岄敍鍫熸＋閸旂喕鍏橀張顏呮降缂佺喍绔撮弨鍓佺椽閿涘本婀伴梼鑸殿唽娴?Skeleton閿?
  - `rules/rule_library_page.dart` 閳?鐟欏嫬鍨惔?Skeleton閿涘牐鍤滅€规矮绠熺憴鍕灟/鐟欏嫬鍨崠?缁崵绮虹憴鍕灟閿涘本妫?CRUD閿?
  - `settings/settings_page.dart`閵嗕梗about/about_page.dart` 閳?閸楃姳缍呮い?
  - `shared/module_placeholder.dart` 閳?濡€虫健閸楃姳缍呴崗杈╂暏缂佸嫪娆?
- **`lib/services/draft/`**閿涙俺宕忕粙鑳殰閸斻劋绻氱€涙绔熼悾宀嬬礄鎼?5閿?
  - `casting_draft.dart` 閳?閼藉顭堝Ο鈥崇€烽敍鍫濇儓鐟欏棜顫庣€规氨顭堝鏃傘仛閼藉顭?CastingDraft.demo閿?
  - `draft_repository.dart` 閳?DraftRepository 閹恒儱褰?+ 閸愬懎鐡ㄧ€圭偟骞囬敍鍫濇倵缂侇厼褰查幑銏℃拱閸︽澘鐡ㄩ崒顭掔礆
- **`test/foundation_test.dart`**閿涙pp Shell 娴滄柨顕遍懜?/ 閼诡喖宕烽崶鐐垼 / 閻樿埖鈧椒绻氶幐?/ 閺囨潙顦块懣婊冨礋妤犲本鏁?
- **`test/presentation/casting/casting_page_test.dart`**閿涙碍甯撻崡锕€浼愭担婊冨酱濞村鐦敍鍦眅st A閳ユ弴 / 鐞涘矂銆庢惔?/ 閼藉顭堟禒鎾崇氨 / 缁绢垶鈧槒绶敍?

### 娣囶喗鏁?
- `android/app/src/main/AndroidManifest.xml` 閳?Activity 婢х偛濮?`android:screenOrientation="portrait"` 闁夸礁鐣剧粩鏍х潌閿涙泊abel 绾喛顓婚妴灞藉捶閻鈧?
- `lib/main.dart` 閳?閺囨寧宕叉稉?2.0 閺嬩胶鐣濋崗銉ュ經
- `file-tree.md` 閳?鐠佹澘缍?2.0 妤犮劍鐏?

### 鐠囧瓨妲?
- 閺冄嗩唲缂佸啳绁禍褝绱檂lib/pages/`閵嗕梗lib/data/`閵嗕梗lib/services/`閵嗕梗lib/models/`閵嗕梗lib/widgets/effects/`閵嗕梗娴滄棁顢戦惄绋垮帬閻楄鏅?`閵嗕梗娴滄棁顢戦惄鍝ユ晸閻楄鏅?` 缁涘绱氭稉鈧瀣╃箽閻ｆ瑦婀潻浣盒╅敍灞芥倵缂侇叀绻橀崗銉ｂ偓宀冾唲缂佸啨鈧秹妯佸▓鐢电埠娑撯偓婢跺嫮鎮婇妴?
- 閺?`lib/app.dart`閿涘潉GuayanTrainerApp`閿涘绻氶悾娆庣返閺冄勭ゴ鐠囨洖绱╅悽顭掔礉娑?`lib/app/` 閻╊喖缍嶉崗鍗炵摠閵?
- 閸掑棙鏁崚娑樼紦閸撳秴鍑＄亸鍡樻弓閸欐垵绔?hotfix 閹绘劒姘﹂懛?master閿涘潉610e81f`閿涘鑻熼崥鍫濊嫙鏉╂粎顏€涳缚绡勫Ο鈥虫健閹绘劒姘﹂敍鍧?c4bdb6`閿涘鈧?

---

## 閹存劖鐏夎ぐ鎺撱€傞幓鎰唉 閳?2026-08-27閿涘牊婀崣鎴濈閿?

> 閼冲本娅欓敍姘磻閸欐垶婧€閸愬懎鐡ㄩ懓妤€鏁栧畷鈺傜皾闁插秴鎯庨敍鍦檙adle 閹绘劒姘﹂崘鍛摠 errno 1455閿涘绱濋崚銈呯暰閺堫剚婧€閺嗗倷绗夐崗宄邦槵缂佈呯敾瀵偓閸欐垶娼禒璁圭礉閸忋劑鍎村銉ょ稊閹存劖鐏夋稉鈧▎鈩冣偓褍缍婂锝嗗絹娴溿倕鑻熼幒銊┾偓?GitHub閿涘潉feat/guayan-2.0`閿涘绱濋梼鍙夘剾閹存劖鐏夋稉銏犮亼閵嗗倽顕涚憴?`CHANGELOG.md`閵?

### 閺傛澘顤?
- `AGENTS.md` 閳?妞ゅ湱娲版禒锝囩垳鐟欏嫬鍨敍鍫熸瀮娴犲墎绮嶇紒?/ 閺嬭埖鐎崚鍡楃湴 / 閸涜棄鎮曠憴鍕瘱 / 閺傚洦銆傜痪顏勭伐 / 閻楀牊婀版稉搴㈢€鐚寸礆閿涘瓑I 閼奉亜濮╅柆闈涚暓
- `lib/data/training_question.dart` 閳?2.0 鐠侇厾绮岄弫鐗堝祦濡€崇€烽敍姝歍rainingModule` / `RelationType` / `TrainingQuestion`
- `lib/data/wuxing_questions.dart` 閳?娴滄棁顢戦悽鐔峰帬妫版ê绨遍敍姘辨祲閻?5 妫?+ 閻╃鍘?5 妫版﹫绱?0 妫版﹫绱?
- `uploads/` 閳?閸欏倽鈧啳绁弬娆欑窗`XYUI1ComponentDocumentView.axaml`閵嗕梗閸楋妇婧?2.0 閹绱戦崣鎴ｎ吀閸?md`
- `娴滄棁顢戦惄绋垮帬閻楄鏅?` 閳?5 娑擃亞娴夐崗?HTML 閸斻劎鏁鹃崢鐔风€烽敍鍫ュ櫨閸忓婀?閺堛劌鍘犻崷?閸︾喎鍘犲?濮樻潙鍘犻悘?閻忣偄鍘犻柌鎴礆
- `娴滄棁顢戦惄鍝ユ晸閻楄鏅?` 閳?5 娑擃亞娴夐悽?HTML 閸斻劎鏁鹃崢鐔风€烽敍鍫ュ櫨閻㈢喐鎸?濮樺鏁撻張?閺堛劎鏁撻悘?閻忣偆鏁撻崷?閸︾喓鏁撻柌鎴礆
- `CHANGELOG.md` 閳?閺傚洣娆㈢€孤ゎ吀娑撳骸褰夐弴瀛樻）韫?

### 娣囶喗鏁?
- `android/gradle.properties` 閳?娴ｅ骸鍞寸€涙ê绱戦崣鎴炴簚缁撅附娼敍娆絍M 閸?1G閵嗕甫otlin daemon 256m閵嗕梗org.gradle.workers.max=1`閿涘矂浼╅崗宥嗙€鐑樺絹娴溿倕鍞寸€涙鈧鏁?
- `file-tree.md` 閳?鐠佹澘缍嶈ぐ鎺撱€傞幓鎰唉閵嗕焦鏌婃晶鐐存瀮娴犳湹绗岄張鈧崥搴ｇ椽鏉堟垶妞傞梻?

---

## GUAYAN-2.0-DOMAIN 閳?Stable Relation Identity閿?026-08-30閿涘本婀崣鎴濈閿?

> 闂冭埖顔岄惄顔界垼閿?*RelationInstance 閸欘垯浜掗柌宥呯紦閿涘elationNote 娑撳秷鍏樻径鍗炵箓閵?*
> 閸欘亜浠涢崶娑楅嚋閺嶇绺?Domain + 缁嬪啿鐣鹃崗宕囬兇闊偂鍞ら敍灞肩瑝閹碘晞瀵栭崶杈剧幢鐎瑰本鏆ｇ拋鎹愵吀鐟?`lib/domain/README.md`閵?

### 閺傛澘顤冮敍鍧檌b/domain/ 閳?缁?Dart 妫板棗鐓欑仦鍌︾礉闂?Flutter/婢舵牠鍎存笟婵婄閿?
- `hexagram_case.dart` 閳?閸楋缚绶ラ幐浣风畽閸栨牗鐗寸€电钖勯敍鍫熸付鐏忓繘顎囬弸璁圭礆
- `line_state.dart` 閳?娑撯偓閻栬崵濮搁幀渚婄窗缁嬪啿鐣鹃悥璁崇秴 + 閸斻劑娼?+ 閹碘偓閸婄厧婀撮弨?
- `line_endpoint.dart` 閳?閸忓磭閮寸粩顖滃仯缁嬪啿鐣鹃煬顐″敜閿涘牆宕锋笟?+ 閻栬缍呴敍?
- `relation_type.dart` 閳?閸忓磭閮寸猾璇茬€烽弸姘 + 缁崵绮虹憴鍕灟 RuleId 鐢悂鍣?
- `relation_key.dart` 閳?**Stable Relation Identity 閺嶇绺?*閿涘牆宕熸稉鈧弸鍕偓鐘插弳閸欙綇绱?
- `relation_instance.dart` 閳?娑撯偓閺夆€冲徔娴ｆ挸鍙х化浼欑礄闁插秶鐣婚崣顖炲櫢瀵ょ尨绱?
- `relation_calculator.dart` 閳?閺堚偓鐏忓繒鈥樼€规碍鈧冨彠缁槒顓哥粻妤嬬礄閸斻劌褰?閸忣厼鍟?閸忣厼鎮庨敍?
- `relation_note.dart` 閳?閸忓磭閮寸粭鏃囶唶閿涘潏aseId + RelationKey 闁插秵鏌婄紒鎴濈暰閿?
- `relation_note_store.dart` 閳?缁楁棁顔囩紒鎴濈暰鐎涙ê鍋嶉敍鍫㈠嚱閸愬懎鐡?+ JSON 鐎电厧鍙嗙€电厧鍤敍?

### 閺傛澘顤冮敍鍧眅st/domain/閿?
- `domain_test_utils.dart` 閳?閸忓彉闊╁鏃傘仛閸楋缚绶ラ敍鍫濆З閸?+ 閸忣厼鍟块敍?
- `relation_key_test.dart` 閳?Test A 绾喖鐣鹃幀?/ Test B 瀹割喖绱撻幀?/ 閺傜懓鎮滄径鍕倞
- `relation_key_serialization_test.dart` 閳?RelationKey JSON round-trip 娑撳骸鐫嶇粈鍝勬倳鐟欙綀鈧?
- `relation_rebinding_test.dart` 閳?Test C 闁插秶鐣婚幁銏狀槻缁楁棁顔?/ Test D 娑撳秳瑕嗙粭鏃囶唶 / Test E 妞ゅ搫绨弮鐘插彠
- `relation_serialization_test.dart` 閳?T8 鎼村繐鍨崠?閳?閸欏秴绨崚妤€瀵?閳?闁插秶鐣?閳?闁插秵鏌婄紒鎴濈暰閸忋劑鎽?

### 閺傛澘顤冮敍鍧癱ripts/閿?
- `flutter.ps1` 閳?瀹告彃鍨归梽銈忕窗閺堫剚婧€ Flutter 閸栧懓顥婇懘姘拱缁夎鍤悧鍫熸拱閹貉冨煑閿涘湚ARDENING T4閿涘鈧?
  閺堫剚婧€瀹搞儰缍旈崠杞扮箽閻?`scripts/flutter.local.ps1`閿涘牆鎯堥張鍝勬珤鐠侯垰绶炴稉搴濆敩閻炲棛顏崣锝忕礉瀹?.gitignore閿涘奔绗夐崗銉ョ氨閿?

### 娣囶喗鏁?
- `lib/domain/README.md` 閳?閸楃姳缍呯拠瀛樻閺囨寧宕叉稉?Stable Relation Identity 鐠佹崘顓搁弬鍥ㄣ€?
- `test/domain/`閿涘牊鏌婂铏规窗瑜版洩绱氶妴涔cripts/`閿涘牊鏌婂铏规窗瑜版洩绱?
- `file-tree.md` 閳?鐠佹澘缍?DOMAIN 闂冭埖顔岄弬鏉款杻娑撳氦浜寸拹?

### 鐠囧瓨妲?
- RelationKey = 鐠囶厺绠熼崸鎰垼閿涘牏琚崹瀣簚閸ｃ劌鎮?+ RuleId + RuleVersion + subtype + 缁旑垳鍋ｉ敍澶涚礉
  娑撳氦绻嶇悰灞炬鐎电钖?/ UI 妞ゅ搫绨?/ 閺佺増宓佹惔?row id 鐟欙綀鈧讣绱遍弬鐟版倻閺勬儳绱℃径鍕倞閿涘牊婀侀崥鎴滅箽鎼村繈鈧礁顕粔鐗堝笓鎼村骏绱氶妴?

---

## GUAYAN-2.0-DOMAIN-HARDENING 閳?闊偂鍞ら弨璺哄經閿?026-08-30閿涘本婀崣鎴濈閿?

> 娴滃搫浼愰弽鎼佺崣閸氬骸鐨濆?4 娑擃亝鏆熼幑顔煎悑鐎瑰綊妫舵０姗堢幢娑撳秹鍣搁弸鍕┾偓浣风瑝鏉╂稑鍙?R3閵?
> 妤犲本鏁归崣銉窗RelationInstance 閸欘垶鍣稿鐚寸幢RelationNote 娑撳秴銇戣箛鍡幢
> RuleVersion 閸欐ê瀵叉稉宥堝厴鐠佲晛宸婚崣鎻掑捶娓氬銇戣箛鍡幢娴犵粯鍓伴崥鍫熺《 RuleId/Subtype 娑撳秷鍏橀崚鍫曗偓鐘洪煩娴犵晫顫幘鐑囩幢
> 閸?Case 閺佺増宓佹稉宥堝厴閸掑爼鈧娀鍣告径宥堥煩娴犲鈧?

### 閺傛澘顤?
- `lib/domain/rule_execution_context.dart` 閳?鐟欏嫬鍨悧鍫熸拱 replay 娑撳﹣绗呴弬鍥风礄RuleVersionRef / RuleExecutionContext閿?
- `test/domain/relation_key_collision_test.dart` 閳?T1 canonical 閺冪姵顒犳稊澶嬧偓褝绱欓崥?`|`/`->`/`<->`/`\` 绾扮増鎸掗崶鐐茬秺閿?
- `test/domain/rule_version_replay_test.dart` 閳?T2 閺冄冨捶娓?v1 閳?閸楀洨楠?v2 閳?reload 閳?replay v1 閳?缁楁棁顔囬幁銏狀槻
- `test/domain/domain_invariants_test.dart` 閳?T3 閻栬缍?閸忣厾鍩㈡稉宥呭綁闁?+ 閸?JSON 閹锋帞绮?

### 娣囶喗鏁?
- `lib/domain/relation_key.dart` 閳?canonical 閺冪姵顒犳稊澶婂閿涙艾鐡х粭锔胯鐎涙顔岀粙鍐茬暰鏉烆兛绠熼敍鍧刓`閳妶\\`閿涘畭|`閳妶\|`閿涘绱濋崡鏇炵殸缂傛牜鐖?
- `lib/domain/hexagram_case.dart` 閳?閺傛澘顤?`ruleContext` 鐎涙顔岄敍娉乽ntime 閺嶏繝鐛欓幁鏉裤偨 6 閻栨眹鈧垢osition 閹璐?1..6閵嗕焦妫ら柌宥咁槻
- `lib/domain/line_endpoint.dart` / `line_state.dart` 閳?閺嬪嫰鈧姳绗?JSON 閸欏秴绨崚妤€瀵?runtime 閺嶏繝鐛欓悥璁崇秴閿?..6閿?
- `lib/domain/relation_calculator.dart` 閳?鐟欏嫬鍨悧鍫熸拱娴兼ê鍘涢崣?`case.ruleContext.versionForOrDefault(ruleId)`閿涘本妫ょ拋鏉跨秿閸ョ偤鈧偓 v1
- `.gitignore` 閳?`scripts/flutter.local.ps1` 娑撳秴鍙嗘惔鎿勭幢`*.apk` 韫囩晫鏆?
- `lib/domain/README.md` 閳?鐞涖儱鍘?escaping / replay 婵傛垹瀹?/ runtime 娑撳秴褰夐柌蹇氼啎鐠?
- `scripts/flutter.ps1` 閳?閸掔娀娅庨敍鍫⑿╅崙铏瑰閺堫剚甯堕崚璁圭礆

### 妤犲矁鐦?
- `flutter test` 53/53 闁俺绻冮敍鍫濆斧 Test A閳ユ張 + T8 閺冪姴娲栬ぐ鎺炵幢閺傛澘顤?23 妞ょ櫢绱?
- `flutter analyze` 閺堫剝鐤嗛弬鍥︽ 0 issue閿涙睔ndroid debug 閺嬪嫬缂撻幋鎰閿涙稒婀崥顖氬З濡剝瀚欓崳?

---

## 閹烘帒宕锋い?XYUI 閺€褰掆偓?閳?Vertical Casting Workflow閿?026-08-30閿涘本婀崣鎴濈閿?

> 閺傝顢?2 璺?缁鹃潧鎮滈幒鎺戝捶濞翠胶鈻兼潪顭掔窗鐠у嘲宕烽弮鍫曟？ 閳?闂傤喕绨ㄦ穱鈩冧紖 閳?閸忣厾鍩㈡潏鎾冲弳 閳?鐟欏嫬鍨崠?閳?閻㈢喐鍨氶幒鎺旀磸閵?
> 鐟欏棜顫庢禒銉ゆ崲閸斺€插姛 SVG 娑撳搫鏁稉鈧崺鍝勫櫙閿涙稒婀版潪顔昏礋鐟欏棜顫庨梼鑸殿唽閿涘本顒炴銈嗘喅鐟曚椒璐熷鏃傘仛閸楃姳缍呴崐纭风礉
> 鐎瑰本鏆ｇ悰銊ュ礋娑撳孩甯撻惄妯肩暬濞夋洖鐫橀崥搴ｇ敾闂冭埖顔岄妴?

### 閺傛澘顤冮敍鍧檌b/presentation/casting/閿?
- `casting_tokens.dart` 閳?XYUI 鐟欏棜顫?Token 闂嗗棔鑵戦敍鍫ャ€夐棃?闂堛垺婢?鏉堣顢?閺傚洤鐡?鐠€锔俱仛/瀵拌姤鐖?閻㈢喐鍨氬銉╊€冮敍?
- `casting_page_state.dart` 閳?`CastingStepState`閿涘潏urrent/pending/completed/warning/locked閿? `CastingStepData` + `CastingFlowState`
- `widgets/casting_top_bar.dart` 閳?XYUI 妞よ埖鐖敍鍫熺垼妫?閸擃垱鐖ｆ０?娑撳鍋ｉ弴鏉戭樋閿?
- `widgets/casting_flow_header.dart` 閳?CASTING FLOW 婢舵挳鍎撮敍鍫濈秼閸撳秵顒炴?x/5閿?
- `widgets/casting_workflow.dart` 閳?濞翠胶鈻兼潪銊х矋鐟佸拑绱檙ail + 濮濄儵顎冪悰宀嬬礆
- `widgets/casting_flow_rail.dart` 閳?缁鹃潧鎮滅粩鏍殠
- `widgets/casting_step_node.dart` 閳?閼哄倻鍋ｉ悩鑸碘偓浣稿弿闂嗗棴绱欓弫鏉跨摟/鐎电懓瀣€/!/闁夸緤绱濋惌銏ゅ櫤缂佹ê鍩楅敍?
- `widgets/casting_step_card.dart` 閳?濮濄儵顎冮崡鈽呯礄current/pending/completed/warning閿?
- `widgets/casting_step_status.dart` 閳?閻樿埖鈧礁绐橀弽?+ chevron
- `widgets/casting_generate_step.dart` 閳?閻㈢喐鍨氬銉╊€冮敍鍧檕cked/ready/completed/warning閿?
- `widgets/casting_context_strip.dart` 閳?濞翠胶鈻兼稉濠佺瑓閺傚洦娼敍鍫ｎ潐閸掓瑥瀵?閹恒垽鎷?瀹告彃鐣幋?x/5閿?

### 閺傛澘顤?/ 娣囶喗鏁?
- `lib/app/navigation/guayan_main_tab_bar.dart`閿涘牊鏌婃晶鐑囩礆閳?XYUI 鎼存洟鍎寸€佃壈鍩?+ 娴滄柨娴橀弽?CustomPainter
- `lib/app/navigation/main_tabs.dart` 閳?MainTab 婢х偛濮?iconBuilder閿涘湺YUI 閸ョ偓鐖ｉ敍?
- `lib/app/app_shell.dart` 閳?NavigationBar 閳?GuayanMainTabBar閿涙稒甯撻崡锕傘€夐弮鐘插弿鐏炩偓 AppBar
- `lib/app/more_menu.dart` 閳?閺€顖涘瘮閼奉亜鐣炬稊?icon
- `lib/presentation/casting/casting_page.dart` 閳?闁插秴鍟撴稉鐑樼ウ缁嬪寤烘い鐢告桨閿涘牏濮搁幀浣规簚閿涙碍甯规潻?閻㈢喐鍨?闂団偓闁插秵鏌婇悽鐔稿灇/閹恒垽鎷￠敍?
- `test/foundation_test.dart` 閳?闁倿鍘ら弬?UI閿涘湺YUI 鐎佃壈鍩?閹烘帒宕峰ù浣衡柤鏉?閹恒垽鎷?Key/娑撳鍋ｉ弴鏉戭樋閿?
- `test/presentation/casting/casting_page_test.dart`閿涘牊鏌婃晶鐑囩礆閳?瀹搞儰缍斿ù浣哄Ц閹焦绁寸拠?

### 鐠囧瓨妲?
- 閻樿埖鈧浇绻橀崗銉ф埂鐎?State閿涘湑astingStepState閿涘绱濇稉宥勭矤妫版粏澹婇崣宥嗗腹閿涙稑鍑＄€瑰本鍨氬銉╊€冮崣顖炲櫢閺傛媽绻橀崗銉礉
  閻㈢喐鍨氶崥搴濇叏閺€鐟板彠闁款喗鏆熼幑?閳?閻㈢喐鍨氬銉╊€冮弽鍥唶閵嗗矂娓堕柌宥嗘煀閻㈢喐鍨氶妴宥忕礄娑撳秵绔荤粚鍝勫嚒婵夘偄鍞寸€圭櫢绱氶妴?
- 閸樼喆鈧瞼濮搁幀浣瑰赴闁藉牞绱?閵嗗秴顒濈粩瀣瀮閺堫剛些闂勩倧绱濋幒銏ゆ嫛鐠囶厺绠熸穱婵堟殌閸?Context Strip閿涘牆褰查悙鐟板毊闁帒顤冮敍澶堚偓?
- 妤犲矁鐦夐敍姝爈utter test 63/63 闁俺绻冮敍娌榥alyze 閺堫剝鐤嗛弬鍥︽ 0 issue閿涙矟ebug 閺嬪嫬缂撻柅姘崇箖閵?

---

## 閺堫亜褰傜敮鍐ㄥ綁閺?閳?2026-05-26

### 娣囶喖顦?
- **闁挎瑩顣介崶鐐靛€濋崚婵嗩潗閸?*閿涙瓪MistakeStore` 閺傛澘顤冮弰鎯х础 `init()`閿涘苯绨查悽銊ユ儙閸斻劍妞傞惇鐔割劀缁涘绶?SharedPreferences 閺佺増宓侀崝鐘烘祰閿涘矂浼╅崗宥夘浕妞?缂佸啩绡?閸ョ偟鍊濇＃鏍偧鐠囪褰囬柨娆擃暯閺佷即鍣烘稉铏光敄閵?
- **鏉╃偠绻涢惇瀣€娲晩鐠?*閿涙矮鎱ㄦ径?`LinkMatchGamePage` HUD 娑擃厼濮╅幀渚€鏁婄拠顖涙殶娴ｈ法鏁?`const TextStyle` 鐎佃壈鍤ч惃鍕椽鐠囨垵銇戠拹銉ｂ偓?

### 娣囶喗鏁奸弬鍥︽
- `lib/main.dart` 閳?閸氼垰濮╅弮鎯扮殶閻?`MistakeStore.instance.init()`閵?
- `lib/services/mistake_store.dart` 閳?閺嗘挳婀堕崚婵嗩潗閸栨牕鍙嗛崣锝忕礉娣囨繄鏆€閸氬本顒?`all` 鐠囪褰囩紓鎾崇摠閵?
- `lib/pages/practice/games/link_match_game_page.dart` 閳?娣囶喖顦查崝銊︹偓?HUD 閺嶅嘲绱￠惃?const 娴ｈ法鏁ら妴?
- `file-tree.md` 閳?閺囧瓨鏌婇張鈧崥搴ｇ椽鏉堟垶妞傞梻娣偓浣规弓閸欐垵绔烽崣妯绘纯閸滃瞼娴夐崗瀹犱捍鐠愶綀顕╅弰搴涒偓?

---

## 閺堫亜褰傜敮鍐╂纯閺傜増妫╄箛妤嬬礄鏉╂粎顏崥鍫濊嫙閿?

### 閺傛澘顤?
- **娴滄棁顢戦幇蹇氳杽鐎涳缚绡勬い?*閿涙瓪WuxingImageryPage` 閳?娴滄棁顢戦惌銉ㄧ槕閹宕?+ 妫版粏澹婇妴浣风安閸涚偨鈧浇鍓伴懙鎴欌偓浣规煙娴ｅ秲鈧礁鎼х拹銊ｂ偓浣规殶鐎涙ぜ鈧礁娲撶€涳絻鈧礁婀撮弨顖欑安鐞涘苯鍨庨弶鍨健閹板繗钖?
- **閸忣偄宕风€涳缚绡勬い?*閿涙瓪BaguaStudyPage` 閳?閸忣偄宕锋禍褏鏁撻妴浣圭摃鐠団偓閵嗕胶鐓＄拠鍡樷偓璇插幢閵嗕礁鍙撻崡锕€鍨庨崡掳鈧胶姊剧挒鈩冨閸欑姳绗岄弬鍥╁竾閸楋缚濞囬悽銊﹀絹缁€?

### 娣囶喗鏁?
- **鐎涳缚绡勯崗銉ュ經閸涜棄鎮?*閿涙瓪娴滄棁顢戦悽鐔峰帬` 閺€閫涜礋 `娴滄棁顢戝Ο鈥虫健`
- **鐎涳缚绡勯崗銉ュ經閹碘晛鐫?*閿涙碍鏌婃晶?`閸忣偄宕峰Ο鈥虫健`閿涘奔缍呮禍搴濈安鐞涘本膩閸фぞ绠ｉ崥搴涒偓浣稿磩娴滃苯婀撮弨顖欑閸?
- **娴滄棁顢戝Ο鈥虫健閻╊喖缍?*閿涙碍濯堕崚?`娴滄棁顢戞０婊嗗` 娑?`娴滄棁顢戦幇蹇氳杽`閿涘苯鎮楃紒顓犳祲閻㈢喆鈧胶娴夐崗瀣ㄢ偓浣蜂簰閹存垳璐熸稉顓炵妇妞ゅ搫娆?
- **娴滄棁顢戞０婊嗗妞?*閿涙矮绗呮稉鈧銉ㄧ儲鏉烆剚鏁兼稉楦跨箻閸?`娴滄棁顢戦幇蹇氳杽`

---

## 瑜版挸澧犻悧鍫熸拱閺囧瓨鏌婇弮銉ョ箶 閳?v0.1.10

> 閸欐垵绔烽弮銉︽埂閿?026-05-22 璺?[GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.10)

### 閺傛澘顤?
- **閸忓磭閮存潻鐐剁箾閻鐖堕幋?*閿涙瓪LinkMatchGamePage` 閳?25 缂佸嫰鍘ょ€?/ 50 瀵姴宕遍悧灞剧Х闂勩倖膩閺?
- **`PracticeMode.linkMatch`**閿涙氨顑囨稉澶岊潚缂佸啩绡勫Ο鈥崇础
- **`HitEffectKind` / `FallingRuleKind`** 閺嬫矮濡囬敍姘礋閸氬海鐢婚崷鐗堟暜閸?閸愭煡顣╅悾?

### 濞撳憡鍨欑憴鍕灟
- 娑撳﹥鏌熷┃鎰 25 瀵?+ 娑撳鏌熼惄顔界垼閻?25 瀵媴绱濋崥鍕殰閹垫挷璐?
- 閻愮懓鍤┃鎰 閳?妤傛ü瀵?閳?閻愮懓鍤惄顔界垼閻楀苯鐣幋鎰板帳鐎?
- 濮濓絿鈥橀敍姘ｆ匠閿?閳?閸欏秹顩?+ 娑撱倕绱堕悧灞剧Х闂勩倖绉锋径?+ 閸旂姴鍨庢潻鐐插毊
- 闁挎瑨顕ら敍姘⒏閸?+ 閺勫墽銇氬锝団€樼粵鏃€顢?+ 閸愭瑥鍙嗛崶鐐靛€?
- 姒涙顓?5 閺夆€虫嚒閿涘苯鍙忛柈銊╁帳鐎瑰本鍨ㄩ崨鐣屾暏鐎?閳?缂佹挻鐏夋い?

### 閺傛澘顤冮弬鍥︽
- `lib/pages/practice/games/link_match_game_page.dart` 閳?鏉╃偠绻涢惇瀣埗閹村繋瀵屾い鐢告桨

### 娣囶喗鏁奸弬鍥︽
- `lib/models/practice/practice_enums.dart` 閳?PracticeMode.linkMatch + HitEffectKind + FallingRuleKind
- `lib/pages/practice/practice_setup_page.dart` 閳?閺傛澘顤冩潻鐐剁箾閻膩瀵繘鈧瀚ㄦ稉搴ょ儲鏉?
- `lib/pages/practice/practice_result_page.dart` 閳?閺傛澘顤?matchedCount/totalPairs 閸欏倹鏆?
- `lib/pages/practice/practice_page.dart` 閳?鐡掞絽鎳楀〒鍛婂灆閸栧搫顤冮崝鐘虹箾鏉╃偟婀呴崗銉ュ經
- `lib/utils/practice_labels.dart` 閳?PracticeStage 婢х偛濮?linkMatch
- `lib/theme/wuxing_colors.dart` 閳?闁叉垿顤侀懝韫喘閸?

---

## 閸撳秶澧楅弴瀛樻煀閺冦儱绻?閳?v0.1.9

> 閸欐垵绔烽弮銉︽埂閿?026-05-22 璺?[GitHub Release](https://github.com/Heaifan/guayan_trainer/releases/tag/v0.1.9)

### 閺傛澘顤?
- **閺傜懓娼￠柅鐔虹摕濞撳憡鍨?*閿涙岸鈧氨鏁ら崡鏇熸煙閸фぞ绗呴拃鑺ツ侀弶?`FallingBlockGamePage`
- **`PracticeMode.fallingBlock`**閿涙碍顒滃蹇撴儙閻劍鏌熼崸妤呪偓鐔虹摕濡€崇础
- **`PracticeSetupPage` 濡€崇础闁瀚?*閿涙碍娅橀柅姘辩矊娑?/ 閺傜懓娼￠柅鐔虹摕 娴滃矂鈧绔撮崚鍥ㄥ床
- **`PracticeResultPage` 濞撳憡鍨欑紒鐔活吀**閿涙碍鏌婃晶?`score` / `maxCombo` / `remainingLives` 閸欘垶鈧妯夌粈?
- **闁挎瑩顣介崘娆忓弳**閿涙氨鐡熼柨?濠曞繑甯€缂佺喍绔寸挧?`MistakeStore.addOrUpdateMistake`閿涘本绱￠幒澶嬫▔缁€?閺堫亙缍旂粵?

### 濞撳憡鍨欑憴鍕灟
- 妫版娲伴弬鐟版健娴犲簼绗傚鈧稉瀣竴閿涘瞼鍋ｉ崙璇茬俺闁劍顒滅涵顔剧摕濡?
- 缁涙柨顕敍姘繁閸?+10+鏉╃偛鍤敍宀冪箾閸戝鈧帒顤?
- 缁涙棃鏁婇敍姘辨晸閸?-1閿涘矁绻涢崙缁樼闂嗚绱濋崘娆忓弳閸ョ偟鍊?
- 濠曞繑甯€閿涙氨鏁撻崨?-1閿涘本鐖ｇ拋鎷岀Т閺冭绱濋崘娆忓弳閸ョ偟鍊?
- 閸╄櫣顢呮稉瀣儰 4500ms閿涘本鐦?5 鏉╃偛鍤崝鐘烩偓?250ms閿涘本娓舵担?2200ms
- 妫版娲伴悽銊ョ暚閹存牜鏁撻崨钘夌秺闂?閳?缂佹挻鐏夋い?

### 閺傛澘顤冮弬鍥︽
- `lib/pages/practice/games/falling_block_game_page.dart` 閳?閹垫挻鏌熼崸妤佺埗閹村繋瀵屾い鐢告桨

### 娣囶喗鏁奸弬鍥︽
- `lib/models/practice/practice_enums.dart` 閳?PracticeMode 婢х偛濮?fallingBlock
- `lib/pages/practice/practice_setup_page.dart` 閳?婢х偛濮炲Ο鈥崇础闁瀚ㄦ稉搴ょ儲鏉?
- `lib/pages/practice/practice_result_page.dart` 閳?婢х偛濮炲〒鍛婂灆缂佺喕顓哥€涙顔?

---

**閸楋妇婧傜拋顓犵矊閸?* 閺勵垱鏌囬崡锕€鐔€閺堫剙濮涚拋顓犵矊 App閿涘瞼鏁ゆ禍搴ゎ唲缂佸啩绨茬悰宀€鏁撻崗瀣ㄢ偓浣告勾閺€顖樷偓浣稿彋閸愭彃鍙氶崥鍫㈢搼閸╄櫣顢呴惌銉ㄧ槕閵?

瑜版挸澧犻幎鈧張顖涚垽閿?

| 缁鐎?| 閹垛偓閺?|
| --- | --- |
| 閸撳秶顏鍡樼仸 | Flutter 3.x |
| 鐠囶叀鈻?| Dart 3.x |
| 閻╊喗鐖ｉ獮鍐插酱 | Android |

閺嶇绺剧拋顓犵矊闂傤厾骞嗛敍姘劅娑?閳?缂佸啩绡?閳?閸戞椽鏁?鏉╃喓鏋?閳?閸ョ偟鍊?閳?閸愬秶绮屾稊鐘偓?

---

## 2. 妞よ泛鐪伴惄顔肩秿缂佹挻鐎?

```text
guayan_trainer/
閳规壕鏀㈤埞鈧?.claude/                # AI 閸楀繋缍旂憴鍕灟
閳规壕鏀㈤埞鈧?android/                # Android 閸樼喓鏁撴竟?
閳规壕鏀㈤埞鈧?assets/                 # 闂呭繐瀵樼挧鍕爱閿涘潊ssets/calendar/ = 楠炴潙瀹抽崢鍡樼《閺佺増宓侀崠鍜冪礆
閳规壕鏀㈤埞鈧?lib/                    # 娑撹崵鈻兼惔蹇旂爱閻?
閳规壕鏀㈤埞鈧?memory/                 # 鐠佹澘绻傛稉搴″冀妫ｅ牐顔囪ぐ?
閳规壕鏀㈤埞鈧?scripts/                # 瀵偓閸欐垼绶熼崝鈺勫壖閺堫剨绱欓張顒佹簚 flutter 閸栧懓顥婇敍?
閳规壕鏀㈤埞鈧?test/                   # 濞村鐦?
閳规壕鏀㈤埞鈧?tool/                   # 瀵偓閸欐垿妯佸▓闈涗紣閸忓嚖绱欐稉宥呭棘娑?App 鏉╂劘顢戦弮璁圭礆
閳规壕鏀㈤埞鈧?uploads/                # 閸欏倽鈧啳绁弬娆欑礄瀵偓閸欐垼顓搁崚鎺嬧偓浣虹矋娴犺埖鏋冨锝忕礆
閳规壕鏀㈤埞鈧?娴滄棁顢戦惄绋垮帬閻楄鏅?            # 閻╃鍘?HTML 閸斻劎鏁鹃崢鐔风€烽敍? 娑擃亷绱?
閳规壕鏀㈤埞鈧?娴滄棁顢戦惄鍝ユ晸閻楄鏅?            # 閻╁摜鏁?HTML 閸斻劎鏁鹃崢鐔风€烽敍? 娑擃亷绱?
閳规壕鏀㈤埞鈧?AGENTS.md               # 妞ゅ湱娲版禒锝囩垳鐟欏嫬鍨敍鍦揑 閼奉亜濮╅柆闈涚暓閿?
閳规壕鏀㈤埞鈧?CHANGELOG.md            # 閺傚洣娆㈢€孤ゎ吀娑撳骸褰夐弴瀛樻）韫?
閳规壕鏀㈤埞鈧?file-tree.md            # 妞ゅ湱娲扮紒鎾寸€拠瀛樻閺傚洦銆?
閳规柡鏀㈤埞鈧?pubspec.yaml            # Flutter 娓氭繆绂嗛柊宥囩枂
```

---

## 3. lib 閻╊喖缍嶇紒鎾寸€?

```text
lib/
閳规壕鏀㈤埞鈧?main.dart               # 鎼存梻鏁ら崗銉ュ經
閳规壕鏀㈤埞鈧?app.dart                # MaterialApp 娑撳顣介柊宥囩枂
閳规壕鏀㈤埞鈧?app/                    # 2.0 鎼存梻鏁ゆ竟绛圭礄GuayanApp / AppShell / 鐎佃壈鍩呴敍?
閳规壕鏀㈤埞鈧?core/                   # 2.0 鐢悂鍣?
閳规壕鏀㈤埞鈧?domain/                 # 2.0 妫板棗鐓欑仦鍌︾礄DOMAIN + R3 閹烘帞娲忓鏇熸惛 + R3-B 閸樺棙纭剁仦鍌︾礆
閳规壕鏀㈤埞鈧?application/            # 2.0 閻劋绶ョ仦鍌︾礄妫板嫮鏆€閿?
閳规壕鏀㈤埞鈧?presentation/           # 2.0 娴滄柧閲滄稉濠氥€夐棃?+ 鐟欏嫬鍨惔?鐠佸墽鐤?閸忓厖绨?
閳规壕鏀㈤埞鈧?shell/                  # 閺冄冾嚤閼割亜锛撻敍?.0 闁鏆€閿?
閳规壕鏀㈤埞鈧?theme/                  # 妫版粏澹婄化鑽ょ埠
閳规壕鏀㈤埞鈧?data/                   # 閺佺増宓佺仦鍌︾窗缁绢垱鏆熼幑顔芥Ё鐏忓嫪绗岀敮鎼佸櫤
閳规壕鏀㈤埞鈧?models/                 # 濡€崇€风仦鍌︾窗缁鐎风€规矮绠?
閳规壕鏀㈤埞鈧?services/               # 閺堝秴濮熺仦鍌︾窗娑撴艾濮熼柅鏄忕帆
閳规壕鏀㈤埞鈧?pages/                  # 妞ょ敻娼扮仦鍌︾窗閹稿濮涢懗钘夊瀻鐎涙劗娲拌ぐ鏇礄1.0 闁鏆€閿?
閳规柡鏀㈤埞鈧?widgets/                # 缂佸嫪娆㈢仦鍌︾窗閸欘垰顦查悽銊х矋娴犺绱?.0 闁鏆€閿?
```

---

## 4. 濡€虫健閼卞矁鐭楃拠瀛樻

| 濡€虫健 | 閼卞矁鐭?| 閺勵垰鎯佹笟婵婄 Flutter/Widget |
| --- | --- | --- |
| `theme/` | 娴滄棁顢戞０婊嗗缁崵绮洪妴浣峰瘜妫版澹婄敮鎼佸櫤 | 閺勵垽绱機olor閿?|
| `shell/` | 鎼存洟鍎寸€佃壈鍩呮竟鐐解偓渚€銆夐棃銏犲瀼閹?| 閺?|
| `data/` | 閺佺増宓佺悰銊ｂ偓浣哥埗闁插繈鈧胶鍑介弰鐘茬殸閿涘牅绨茬悰?閸︾増鏁?閸愭彃鎮庨敍?| 閸?|
| `models/` | 缁鐎风€规矮绠熼妴浣规殶閹诡喚绮ㄩ弸?| 閸?|
| `services/` | 閸戞椽顣藉鏇熸惛閵嗕線鏁婃０妯虹摠閸?| 閸?|
| `pages/` | 妞ょ敻娼扮紒鍕娑撳海鏁ら幋铚傛唉娴?| 閺?|
| `widgets/` | 閸欘垰顦查悽?UI 缂佸嫪娆?| 閺?|

---

## 5. 閸忔娊鏁弬鍥︽閼卞矁鐭?

### 5.1 閺嶅湱娲拌ぐ?

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `pubspec.yaml` | 妞ゅ湱娲伴崗鍐т繆閹垬鈧椒绶风挧鏍э紣閺勫簼绗?flutter 闁板秶鐤?|
| `file-tree.md` | 妞ゅ湱娲伴弬鍥︽閺嶆垳绗屽Ο鈥虫健鐠囧瓨妲戦弬鍥ㄣ€?|

### 5.2 .claude/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `CLAUDE.md` | AI 閸楀繋缍旂憴鍕灟閿涙碍鏋冩禒鍓佺矋缂佸洢鈧焦鐏﹂弸鍕瀻鐏炲倶鈧礁鎳￠崥宥堫潐閼煎啨鈧焦鏋冨锝囬偗瀵?|

### 5.3 lib/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `main.dart` | 鎼存梻鏁ら崗銉ュ經閿涘苯鍨垫慨瀣闁挎瑩顣界紓鎾崇摠閸氬氦鐨熼悽?`runApp` 閸氼垰濮?`GuayanTrainerApp` |
| `app.dart` | MaterialApp 缂佸嫯顥婇敍宀勫帳缂冾喖褰滄搴濆瘜妫版澹婄化浼欑礉home 閹稿洤鎮?`MainShell` |

### 5.3.1 lib/domain/閿?.0 妫板棗鐓欑仦鍌︾礆

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `hexagram_case.dart` | 閸楋缚绶ラ幐浣风畽閸栨牗鐗寸€电钖勯敍姝ヾ / question / createdAt / lines[6] |
| `line_state.dart` | 娑撯偓閻栬崵濮搁幀渚婄窗閻栬缍?/ 閸斻劑娼ら敍鍫ｂ偓渚€妲鹃懓渚€妲奸崣鎴濆З閿? 閹碘偓閸婄厧婀撮弨?|
| `line_endpoint.dart` | 閸忓磭閮寸粩顖滃仯缁嬪啿鐣鹃煬顐″敜閿涙艾宕锋笟褝绱檕riginal/changed閿? 閻栬缍呴敍?..6閿?|
| `relation_type.dart` | 閸忓磭閮寸猾璇茬€烽弸姘 + 閺傜懓鎮滅猾璇插焼 + 鐏炴洜銇氶崥?+ 缁崵绮?RuleId 鐢悂鍣?|
| `relation_key.dart` | 閸忓磭閮寸粙鍐茬暰鐠囶厺绠?key閿涘湯table Relation Identity 閺嶇绺鹃敍?|
| `relation_instance.dart` | 娑撯偓閺夆€冲徔娴ｆ挸鍙х化璇茬杽娓氬绱欓煬顐″敜娴?key 娑撳搫鍣敍灞藉讲闁插秶鐣婚柌宥呯紦閿?|
| `relation_calculator.dart` | 閺堚偓鐏忓繒鈥樼€规碍鈧冨彠缁槒顓哥粻妤嬬窗閸斻劌褰?/ 閸忣厼鍟?/ 閸忣厼鎮?|
| `relation_note.dart` | 閸忓磭閮寸粭鏃囶唶鐎圭偘缍嬮敍鍧坅seId + RelationKey 缂佹垵鐣鹃敍?|
| `relation_note_store.dart` | 缁楁棁顔囩紒鎴濈暰鐎涙ê鍋嶉敍姘卞嚱閸愬懎鐡?+ JSON 鐎电厧鍙嗙€电厧鍤?|
| `README.md` | 妫板棗鐓欑拋鎹愵吀娑?Stable Relation Identity 鐠囧瓨妲?|
| `wu_xing.dart` | 娴滄棁顢?+ 閻㈢喎鍘犻敍娌梤elationTo(self)` 娑撳搫鍙氭禍鎻掑灲鐎规艾鏁稉鈧崗銉ュ經閿涘湩3閿?|
| `di_zhi.dart` | 閸椾椒绨╅崷鐗堟暜閿涙矮绨茬悰?/ 闂冩挳妲?/ 閸忣厼鍟?/ 閸忣厼鎮庨敍鍦?閿?|
| `tian_gan.dart` | 閸椾礁銇夐獮璇х窗娴滄棁顢?/ 闂冩挳妲?/ 閸忣厼宕勯悽鎻掔摍閸欐牕鍏遍敍鍦?閿?|

### 5.3.2 lib/domain/casting/閿涘湩3 閹烘帞娲忓鏇熸惛閿?

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `bagua.dart` | 閸忣偄宕烽敍鍫滅瑏閻栨槒鍤滄稉瀣偓灞肩瑐閿? 閸楋妇顑?+ 娴滄棁顢?+ 閸忓牆銇夋惔?|
| `najia.dart` | 缁惧磭鏁崇悰顭掔礄楠炲弶鏁敍澶涚窗娑斿墽鎾奸悽鎻掞紝閵嗕礁娼崇痪鍏呯閻ч潻绱遍崘鍛樆閸楋箑鍨庨崚顐ヮ棅閸?|
| `palace.dart` | 娴滎剚鍩ч崗顐㈩唫閸楋箑绨?+ 娑撴牕绨查敍鍫㈢暬濞夋洜鏁撻幋鎰剁礉闂堢偟鈥栫紓鏍垳 64 閺夆槄绱?|
| `hexagram_names.dart` | 閸忣厼宕勯崶娑樺捶閸氬秷銆冮敍鍫滅瑐閸?鑴?娑撳宕烽敍?|
| `hexagram64.dart` | 閸忣厾鍩㈤梼鎾Ъ 閳?閸楋箑鎮?/ 鐎诡偂缍?/ 娑撴牕绨?|
| `six_relative.dart` | 閸忣厺缈伴敍鍫滀簰鐎诡偂缍呮禍鏃囶攽娑撴亽鈧本鍨滈妴宥忕礆 |
| `six_spirit.dart` | 閸忣厾顨ｉ敍鍫熷瘻閺冦儱鍏辩挧铚傜伐閿涘矁鍤滈崚婵堝煝閸氭垳绗傛い鐑樺笓閿?|
| `cast_chart.dart` | 閹烘帞娲忕紒鎾寸亯濡€崇€烽敍鍦昦stLine / CastChart閿?|
| `casting_engine.dart` | 瀵洘鎼哥紒鍕棅閿涙碍婀伴崡?/ 閸欐ê宕?/ 閸斻劌褰?/ 缁惧磭鏁?/ 娑撴牕绨?/ 閸忣厺缈?/ 閸忣厾顨?|

### 5.3.3 lib/domain/calendar/閿涘湩3-B 缁傝崵鍤庨崢鍡樼《鐏炲偊绱?

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `calendar_engine.dart` | 閸樺棙纭跺鏇熸惛閿涙俺浠涢崥鍫熸箑瀵?/ 閺冦儴鏅?/ 閺冾剛鈹?|
| `calendar_request.dart` | 鏉堟挸鍙嗘總鎴犲閿涙ocalDateTime + utcOffset + dayBoundaryRule |
| `calendar_context.dart` | 鏉堟挸鍤總鎴犲閿涙艾鐣弫鏉戝坊濞夋洑绗傛稉瀣瀮閿涘牅绗夐崗浣筋啅閸楀﹥鍨氶崫渚婄礆 |
| `calendar_error.dart` | 缁鐎烽崠鏍с亼鐠愩儻绱癐nvalidCalendarDate / CalendarDataMissing / PackInvalid / RevisionRejected |
| `day_boundary_rule.dart` | 閺冦儳鏅憴鍕灟閿涙idnight / ziHourStart閿涘本妫ら梾鎰础姒涙顓婚崐?|
| `day/ganzhi_day.dart` | 閺冦儲鐓撮敍姘壌閻ｃ儲妫╂惔?閳?閸忣厼宕勯悽鎻掔摍閿涘牓鏁嬮悙?1949-10-01 閻㈡彃鐡欓弮銉礆 |
| `day/xun_kong.dart` | 閺冾剛鈹栭敍姘辨暠閺冾剟顩婚幒銊ヮ嚤閿涘奔绗夌紒瀛樺Б閹靛濡辩悰?|
| `solar_term/solar_term_id.dart` | 娴滃苯宕勯崶娑滃Ν濮?+ 婢额亪妲兼鍕病 + 閼?濮樻柨灏崚?|
| `solar_term/solar_term.dart` | 閼哄倹鐨电拋鏉跨秿閿涘牏婀″┃鎰礋閵嗗瞼鐏涢梻娣偓宥堚偓宀勬姜閺冦儲婀￠敍?|
| `solar_term/solar_term_provider.dart` | 閼哄倹鐨甸弶銉︾爱閹跺€熻杽閿涘牆褰查弴鎸庡床鏉堝湱鏅敍?|
| `solar_term/calendar_year_data.dart` | 瀹稿弶鐗庢宀€娈戦崡鏇炲嬀閸樺棙纭堕弫鐗堝祦 |
| `solar_term/month_branch_resolver.dart` | 閺堝牆缂撻敍姘磩娴滃被鈧矁濡妴宥呭隘闂傛潙鍨介弬顓ㄧ礄娑撳骸鍙曢崢鍡樻箑閺冪姴鍙ч敍?|
| `import/calendar_data_pack.dart` | 閺佺増宓侀崠鍛斧婵鑸伴幀渚婄礄鐎涙顔岄崣顖溾敄閿涘奔姘﹂悽杈ㄧ墡妤犲苯娅掑Ч鍥ㄢ偓浼欑礆 |
| `import/calendar_data_pack_parser.dart` | JSON 閳?閺佺増宓侀崠鍜冪礄閸欘亣绀嬬拹锝堫嚔濞夋洑绗岀紒鎾寸€敍?|
| `import/calendar_data_pack_terms.dart` | 閼哄倹鐨甸崚妤勩€冪憴鍕灟閿涙碍鏆熼柌?/ 閸烆垯绔?/ 闁帒顤?/ 楠炵繝鍞ら崥鍫㈡倞閹?|
| `import/calendar_data_pack_validator.dart` | 閸忓啯鏆熼幑顔界墡妤?+ 娑撯偓濞嗏剝鈧勭湽閹鍙忛柈銊ャ亼鐠愩儱甯崶?|
| `import/calendar_data_pack_importer.dart` | 鐟欙絾鐎介埆鎺撶墡妤犲备鍟嬫穱顔款吂閸掋倕鐣鹃埆?*閸樼喎鐡欓幓鎰唉** |
| `store/calendar_data_store.dart` | 閺堫剙婀存禒鎾冲亶鏉堝湱鏅?+ 閸愬懎鐡ㄧ€圭偟骞?|
| `store/stored_solar_term_provider.dart` | 娴犳挸鍋?閳?Provider閿涘牆绱撳銉棅鏉炶棄鎻╅悡褝绱濆鏇熸惛娣囨繃瀵旈崥灞绢劄閿?|

### 5.3.4 lib/presentation/review/閿?.0 鐎光€冲捶瀹搞儰缍旈崣甯礆

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `review_page.dart` | 鐎光€冲捶瀹搞儰缍旈崣鎵矋鐟佸拑绱欐悅3 鐢啫鐪敍娆盿sicInfo 閳?ShenSha 閳?FourPillars 閳?Header 閳?Table 閳?Focus閿?|
| `review_page_state.dart` | 缁?Dart 閻樿埖鈧焦膩閸ㄥ绱欐悅7 閸忋劑鍎寸€涙顔岄敍灞炬弓閹恒儱鍙嗙€涙顔岄弰鎯х础 nullable閿?|
| `review_case_adapter.dart` | HexagramCase + 娴肩姷绮哄锝嗩攳 閳?ReviewPageState閿涙稓鍔嶉悙鐟板彠缁粯娼甸懛?Domain 鐠侊紕鐣?|
| `review_demo_data.dart` | 鐟欏棜顫庣€规氨顭堝鏃傘仛閺佺増宓侀敍鍦玍G 闁劙銆嶆潪顒€缍嶉敍?|
| `widgets/review_app_bar.dart` | 妞よ埖鐖敍鍫ｇ箲閸?chevron + 鐎光€冲捶 + 閹烘帞娲忕紒鎾寸亯閿?|
| `widgets/review_basic_info_card.dart` | 閸╃儤婀版穱鈩冧紖閸椻槄绱欓弬鐟扮础/娴滃銆?闂冨啿宸?闂冩潙宸?+ 瀹歌尙鏁撻幋鎰剁礆 |
| `widgets/review_shensha_card.dart` | 缁佺偟鍘奸崡鈽呯礄Wrap 閺嶅洨顒风純鎴炵壐閿涘本鏆熼幑顕€鈹嶉崝顭掔礆 |
| `widgets/review_four_pillars_strip.dart` | 閸ユ稒鐓撮弶鈽呯礄楠?閺?閺?閺?閺冾剛鈹栭敍瀹籵ft 鎼?44 妤傛﹫绱?|
| `widgets/review_hexagram_result_table.dart` | 鐎瑰本鏆ｉ崡锔炬磸缂佸嫪娆㈤敍鍫濆敶瀹撳奔瀵?閸欐ê宕烽弽鍥暯 + 閸忣叀顢戦幒鎺旀磸 + 鐞涖劌鐔敍?|
| `widgets/review_hexagram_line_row.dart` | 閸忣厾鍩㈤崡鏇☆攽閿?1 閸掓鍠曠紒鎿勭礉閸忣厺缈伴崷鐗堟暜/缁炬娊鐓堕幏鍡曡⒈鐞涘本妫ら惇浣烘殣閸欏嚖绱濋崣顖滃仯妤傛ü瀵掗敍?|
| `widgets/review_line_detail_sheet.dart` | 閻愬湱鍩?Bottom Sheet閿涘牆鍙х化璇插灙鐞?鐟欏嫬鍨笟婵囧祦/婢跺洦鏁?鏉╂稑鍙嗛崗宕囬兇妞ょ绱?|

### 5.3.5 lib/presentation/shared/閿?.0 閸忓彉闊╅悥鑽ょ矋娴犺绱濋幒鎺戝捶/鐎光€冲捶瀵搫鍩楁径宥囨暏閿?

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `yao_glyph.dart` | 缂佺喍绔撮悥缁樞?24鑴?閿涘澒ang/yin/voidYao閿涘奔绮庨崘鍛村劥婵夘偄鍘栨稉宥呮倱閿?|
| `moving_marker.dart` | 閸斻劎鍩㈤弽鍥唶 12鑴?2閿涘牐鈧線妲?閳?/ 閼颁線妲?鑴抽敍瀛妎unding Box 娑撯偓閼疯揪绱?|

### 5.4 lib/shell/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `main_shell.dart` | 鎼存洟鍎撮崶娑欑埉鐎佃壈鍩呴敍鍫ヮ浕妞?鐎涳缚绡?缂佸啩绡?閸ョ偟鍊濋敍澶涚礉`IndexedStack` 妞ょ敻娼版穱婵囧瘮 |

### 5.5 lib/theme/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `wuxing_colors.dart` | 娴滄棁顢戞稉鏄忓 + 濞村懎绨抽懝鍙夋Ё鐏忓嫸绱濋崷鐗堟暜閳帊绨茬悰灞稿晪妫版粏澹婇弻銉嚄閿涘本鏋冪€涙顕В鏃囧鐠侊紕鐣?|

### 5.6 lib/data/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `wuxing_data.dart` | 娴滄棁顢戦崚妤勩€?+ 閻╁摜鏁撻惄绋垮帬閺勭姴鐨犵悰?+ 閸欏秴鎮滈弻銉嚄 |
| `wuxing_self_center_data.dart` | 娴犮儲鍨滄稉杞拌厬韫囧啫鍙х化缁樻Ё鐏?+ 閺冭櫣娴夋导鎴濇磻濮?|
| `dizhi_data.dart` | 閸椾椒绨╅崷鐗堟暜缂佹挻鐎崠鏍ㄦ殶閹诡噯绱版禍鏃囶攽閵嗕線妲鹃梼鐐解偓浣规煙娴ｅ秲鈧焦婀€娴?|
| `relation_data.dart` | 閸忣厼鍟块崗顓炴値閺勭姴鐨?+ 閸欏瞼顏弻銉嚄 + 閸忓磭閮撮崚銈呯暰 |
| `training_question.dart` | 2.0 鐠侇厾绮岄弫鐗堝祦濡€崇€烽敍姝峳ainingModule / RelationType / TrainingQuestion |
| `wuxing_questions.dart` | 娴滄棁顢戦悽鐔峰帬妫版ê绨遍敍姘辨祲閻?5 妫?+ 閻╃鍘?5 妫?|
| `practice/wuxing_practice_question_generator.dart` | 闁氨鏁ゆ０妯虹氨閻㈢喐鍨氶崳顭掔窗閸ユ稓琚禍鏃囶攽妫版ê绨卞ǎ宄版値閸戞椽顣?|

### 5.7 lib/models/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `mistake_item.dart` | 闁挎瑩顣界拋鏉跨秿濡€崇€烽敍灞惧瘮娑斿懎瀵?JSON 鎼村繐鍨崠?|
| `training_question.dart` | 妫版娲扮猾璇茬€烽弸姘閿? 缁夊稄绱? 妫版娲伴弫鐗堝祦缁?|
| `training_result.dart` | 閸楁洟顣芥担婊呯摕鐠佹澘缍?+ 鐠侇厾绮屾导姘崇樈缂佺喕顓搁敍鍫燁劀绾喚宸?閸ョ偟鍊?鏉╃喓鏋掗敍?|
| `practice/practice_enums.dart` | 闁氨鏁ょ紒鍐х瘎閺嬫矮濡囬敍瀛宱main / Topic / AnswerKind / Stage |
| `practice/practice_question.dart` | 闁氨鏁ゆ０妯兼窗濡€崇€?|
| `practice/practice_answer_record.dart` | 缁涙棃顣界拋鏉跨秿 + 娴兼俺鐦界紒鐔活吀 + 閸掑棝銆嶇紒鐔活吀 |

### 5.8 lib/services/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `question_generator.dart` | 閸戞椽顣藉鏇熸惛閿? 缁夊秷顔勭紒鍐┠佸?鑴?8 缁夊秹顣介崹瀣閺堣櫣鏁撻幋?|
| `mistake_store.dart` | 闁挎瑩顣介崶鐐靛€濈€涙ê鍋嶉崳顭掔窗閸氼垰濮╅崚婵嗩潗閸栨牓鈧焦鏁硅ぐ鏇犵摕闁?鏉╃喓鏋掗敍灞剧垼鐠佹澘鍑℃导姘倵缁夊娅?|

### 5.9 lib/utils/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `practice_labels.dart` | 闁氨鏁ょ紒鍐х瘎娑擃厽鏋冮弽鍥╊劮閵嗕線顣芥惔鎾愁啇闁插繈鈧焦妞傞梻瀛樼壐瀵繐瀵查崙鑺ユ殶 |

### 5.10 lib/pages/home/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `home_page.dart` | 鐎涳缚绡勬禒顏囥€冮惄姗堢窗閺嶅洭顣界拠瀛樻 + 鐎涳缚绡勯悩鑸碘偓浣稿幢 + 閸ョ偟鍊濋幓鎰板晪 + 韫囶偅宓庨崗銉ュ經 |

### 5.11 lib/pages/study/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `study_page.dart` | 鐎涳缚绡勬い闈涘弳閸欙綇绱版禍鏃囶攽濡€虫健/閸忣偄宕峰Ο鈥虫健/閸椾椒绨╅崷鐗堟暜/閸忣厼鍟块崗顓炴値閸ユ稑绱剁€涳缚绡勯崡锛勫 |
| `bagua_study_page.dart` | 閸忣偄宕峰Ο鈥虫健鐠囷附鍎忔い纰夌窗閸忣偄宕锋禍褏鏁撻妴浣圭摃鐠団偓閵嗕胶鐓＄拠鍡樷偓璇插幢閵嗕礁鍨庨崡掳鈧胶姊剧挒鈥茬瑢閺傚洨甯囬崡锔藉絹缁€?|
| `wuxing_study_menu_page.dart` | 娴滄棁顢戝Ο鈥虫健閻╊喖缍嶆い纰夌窗妫版粏澹婇妴浣瑰壈鐠灺扳偓浣烘晸閸忓鈧椒浜掗幋鎴滆礋娑擃厼绺剧€佃壈鍩呴崡锛勫 + 缂佺厧鎮庣紒鍐х瘎 + 鐎涳缚绡勫楦款唴 |
| `wuxing_color_page.dart` | 娴滄棁顢戞０婊嗗鐠囷附鍎忔い纰夌窗妫版粏澹婇崡锛勫閵嗕礁顕悡褑銆冮妴浣筋唶韫囧棙褰佺粈鐚寸礉娑撳绔村銉ㄧ箻閸忋儰绨茬悰灞惧壈鐠?|
| `wuxing_imagery_page.dart` | 娴滄棁顢戦幇蹇氳杽鐠囷附鍎忔い纰夌窗娴滄棁顢戦惌銉ㄧ槕閹宕?+ 妫版粏澹?娴滄柨鎳?閼村繗鍘?閺傞€涚秴/閸濅浇宸?閺佹澘鐡?閸ユ稑顒?閸︾増鏁禍鏃囶攽閸掑棙婢橀崸?|
| `wuxing_generate_page.dart` | 娴滄棁顢戦惄鍝ユ晸閿涘牆宕版担宥忕窗閸楀啿鐨㈠鈧弨鎾呯礆 |
| `wuxing_control_page.dart` | 娴滄棁顢戦惄绋垮帬鐎涳缚绡勬い纰夌窗娴滄棁顫楅弰鐔锋禈閵嗕礁鍙х化鏄徯掗柌濞库偓浣规焽閸楋附褰佺粈?|
| `wuxing_center_page.dart` | 娴犮儲鍨滄稉杞拌厬韫囧啫顒熸稊鐘汇€夐敍姘安鐞涘矂鈧瀚?+ 閸忓磭閮撮崶?+ 閺冭櫣娴夋导鎴濇磻濮?|
| `dizhi_study_page.dart` | 閸︾増鏁€涳缚绡勭拠锔藉剰閿涙艾婀撮弨顖氬兊閼硅尙缍夐弽绗衡偓浣风安鐞涘苯缍婄猾姹団偓浣告勾閺€顖氬瀻缁?|
| `relation_study_page.dart` | 閸忣厼鍟块崗顓炴値鐎涳缚绡勭拠锔藉剰閿涙艾鍟块崥鍫濐嚠鐏炴洜銇氶妴浣界儲鏉烆剛绮屾稊?|

### 5.12 lib/pages/practice/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `practice_page.dart` | 缂佸啩绡勬い闈涘弳閸欙綇绱伴幐澶婄唨绾偓/閸忓磭閮?缂佺厧鎮庨崚鍡欑矋鐏炴洜銇氱拋顓犵矊閸楋紕澧?|
| `training_page.dart` | 鐠侇厾绮屾い纰夌窗妫版娲扮仦鏇犮仛 + 瑜扳晞澹婇柅澶愩€?+ 閸楄櫕妞傞崣宥夘洯 + 鏉╂稑瀹抽弶?|
| `result_page.dart` | 缂佹挻鐏夋い纰夌窗濮濓絿鈥橀悳?+ 閸ョ偟鍊?鏉╃喓鏋掑Ч鍥ㄢ偓?+ 闁挎瑩顣介崚妤勩€?+ 缂佈呯敾閹垮秳缍?|
| `practice_setup_page.dart` | 缂佺厧鎮庣紒鍐х瘎鐠佸墽鐤嗘い纰夌窗闁瀚ㄩ弶鍨健 + 妫版ɑ鏆?+ 缂佸啩绡勯弬鐟扮础 |
| `practice_session_page.dart` | 闁氨鏁ょ紒鍐х瘎妞ょ绱扮拋鈩冩 + 閸欏秹顩?+ 閸ョ偟鍊濋崘娆忓弳 |
| `practice_result_page.dart` | 闁氨鏁ょ紒鎾寸亯妞ょ绱伴崚鍡涖€嶇悰銊у箛 + 楠炲啿娼庨崣宥呯安 + 鏉╃喓鏋掔紒鐔活吀 |
| `games/falling_block_game_page.dart` | 閺傜懓娼￠柅鐔虹摕濞撳憡鍨欓敍姘礋妫版ü绗呴拃?+ 閻㈢喎鎳?閸掑棙鏆?鏉╃偛鍤?+ 閸ョ偟鍊?|
| `games/link_match_game_page.dart` | 閸忓磭閮存潻鐐剁箾閻绱?5缂佸嫰鍘ょ€?+ 50瀵姴宕遍悧灞剧Х闂?+ 閸ョ偟鍊?|

### 5.13 lib/pages/review/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `review_page.dart` | 閸ョ偟鍊濇い纰夌窗闁挎瑩顣介崚妤勩€?+ 閸楁洟顣介柌宥呬粵 + 闁插秴浠涢崗銊╁劥闁挎瑩顣?|
| `review_training_page.dart` | 閸ョ偟鍊濈紒鍐х瘎妞ょ绱伴弮鐘哄閸楁洟鈧鍣搁崑姘剧礉缁涙柨顕粔濠氭珟缁涙棃鏁婃穱婵堟殌 |

### 5.14 lib/widgets/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `wuxing_wheel.dart` | 娴滄棁顢戞潪顔炬磸缂佸嫪娆㈤敍姘辩柈鐠侊紕顔勬径鏉戝З閻㈡眹鈧浇鍤滈崝銊ユ儕閻滎垬鈧浇濡悙褰掔彯娴滎喓鈧椒鑵戞径顔惧閺?|
| `wuxing_arrow_painter.dart` | 閸﹀棗濮粻顓炪仈 CustomPainter閿涙碍閮ㄦ潪顔炬磸閸﹀棗鎳嗙紒妯哄煑閻╁摜鏁撳褏鍤?|
| `wuxing_control_wheel.dart` | 娴滄棁顢戦惄绋垮帬鏉烆喚娲忛敍姘安鐟欐帗妲︾槐顖濐吀缁狀厼銇?+ 娴滄梹蝎娴ｅ秶澹掗弫鍫ｅ殰閹?|
| `wuxing_control_arrow_painter.dart` | 娴滄棁顫楅弰鐔烘纯缁捐法顔勬径?CustomPainter閿涙俺娉曢懞鍌滃仯缁俱垼澹婇崗瀣煑缁?|
| `wuxing_control_painter.dart` | 闂堟瑦鈧胶娴夐崗瀣╃安鐟欐帗妲?CustomPainter |
| `wuxing_self_center_wheel.dart` | 娴犮儲鍨滄稉杞拌厬韫囧啫娓鹃惄姗堢窗娑擃厼绺?閸ユ稑鎮滄径鏍ф箑閼哄倻鍋?|
| `wuxing_self_center_painter.dart` | 閸ユ稑鎮滅粻顓炪仈 + 娑擃厼绺鹃崣宀€骞?CustomPainter |
| `effects/control/earth_water_control_html.dart` | 閸︾喎鍘犲?HTML/SVG 閸斻劎鏁鹃敍灞芥埂閸倖娼?|
| `effects/control/fire_metal_control_html.dart` | 閻忣偄鍘犻柌?HTML/SVG 閸斻劎鏁鹃敍宀€鍎撻悘顐ゅ晬闁?|
| `effects/control/metal_wood_control_html.dart` | 闁叉垵鍘犻張?HTML/SVG 閸斻劎鏁鹃敍宀勫櫨閸掑啯鏌囬張?|
| `effects/control/water_fire_control_html.dart` | 濮樻潙鍘犻悘?HTML/SVG 閸斻劎鏁鹃敍灞炬寜楠炴洖甯囬悘?|
| `effects/control/wood_earth_control_html.dart` | 閺堛劌鍘犻崷?HTML/SVG 閸斻劎鏁鹃敍灞炬躬閺嶅湱鐗崷?|
| `effects/control/control_relation_effect.dart` | 閻╃鍘?HTML WebView 鐏忎浇顥?|
| `effects/control/control_relation_effects_layer.dart` | 娴滄梻娴夐崗瀣担宥呭彠缁濮╅悽璇茬湴 |
| `effects/earth_metal_html.dart` | 閸︾喓鏁撻柌?HTML/SVG 閸斻劎鏁鹃敍宀勫櫨閻磭鐗崷鐔烩偓灞藉毉 |
| `effects/fire_earth_html.dart` | 閻忣偆鏁撻崷?HTML/SVG 閸斻劎鏁鹃敍宀€浼嗛悜顒佸负閸╁浼€閼绘鎯婇悳?|
| `effects/generate_relation_effects_layer.dart` | 娴滄梹蝎娴ｅ秴鍙х化璇插З閻㈣鐪伴敍姘祼鐎规艾娼楅弽鍥ㄨ閺屾挸顦块弶鈥冲彠缁濮╅悽?|
| `effects/html_relation_effect.dart` | WebView 鐏忎浇顥婄紒鍕閿涘瓥gnorePointer 闂冨弶瀚ら幋顏庣礉閺€顖涘瘮閸忋劑鍎存禍鏃€娼惄鍝ユ晸 |
| `effects/metal_water_html.dart` | 闁叉垹鏁撳?HTML/SVG 閸斻劎鏁鹃敍灞界槰妞嬪骸鍤屽瀵稿綌濠婄鎯?|
| `effects/water_wood_html.dart` | 濮樺鏁撻張?HTML/SVG 閸斻劎鏁鹃敍灞炬К闂嗐劍榧庨張銊ュ絺閼虹晫绠掗懠?|
| `effects/wood_fire_html.dart` | 閺堛劎鏁撻悘顐︽崌閺堛劌褰囬悘?HTML/SVG 閸斻劎鏁?|

### 5.15 test/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `widget_test.dart` | Widget 閸愭帞鍎ù瀣槸閿涙岸顩绘い鍨劀绾喗瑕嗛弻?|
| `foundation_test.dart` | App Shell 娴滄柨顕遍懜?/ 閼诡喖宕烽崶鐐垼 / 閻樿埖鈧椒绻氶幐?/ 閺囨潙顦块懣婊冨礋妤犲本鏁?|
| `presentation/casting/casting_page_test.dart` | 閹烘帒宕峰銉ょ稊閸欑増绁寸拠鏇礄Test A閳ユ弴 / 鐞涘矂銆庢惔?/ 閼藉顭堟禒鎾崇氨 / 缁绢垶鈧槒绶?/ UI-01~03閿?|
| `presentation/review/review_page_test.dart` | 鐎光€冲捶瀹搞儰缍旈崣鐗堢ゴ鐠囨洩绱欐悅22 A閳ユ弻 / UI-04~08 / 闁倿鍘ら崳?/ 閸欏本鏆熼幑顔跨熅瀵板嫸绱?|
| `presentation/shared/yao_glyph_test.dart` | 閸忓彉闊╅悥鑽ょ矋娴犺泛鏄傜€电鍠曠紒鎾寸ゴ鐠囨洩绱?4鑴? / 12鑴?2閿?|
| `domain/casting/hexagram_tables_test.dart` | R3 鐞涖劋绗岀憴鍕灟閿涙艾鍙撻崡?64 閸楋箑鏁稉鈧幀?閸忣偄顔傛稉鏍х安/缁惧磭鏁?閸忣厺缈?閸忣厾顨?|
| `domain/casting/casting_engine_test.dart` | R3 瀵洘鎼搁敍姘辩病閸忓憡甯撻惄妯侯嚠閻撗嶇礄娑斿彞璐熸径?閸с倓璐熼崷?濞夎棄鍖楅崪闈╃礆+ 閸斻劌褰?|
| `domain/calendar/ganzhi_day_test.dart` | R3-B 閺冦儲鐓撮敍?3 娑擃亣娉曢獮缈犲敩閸╁搫鍣敍鍫濆蓟閻欘剛鐝涘┃鎰墡妤犲矉绱?|
| `domain/calendar/xun_kong_test.dart` | R3-B 閺冾剛鈹栭敍姘彋閺?+ 60 閺冦儱鎯婇悳?+ 閻欘剛鐝涢幀褑宸濇宀冪槈 |
| `domain/calendar/day_boundary_test.dart` | R3-B 閺冦儳鏅敍姘⒈缁夊秷顫夐崚?鑴?閸ユ稐閲滈崗鎶芥暛閺冭泛鍩?|
| `domain/calendar/month_branch_resolver_test.dart` | R3-B 閺堝牆缂撻敍姘磩娴滃被鈧矁濡妴宓?娑撳妞傞悙纭呯珶閻?|
| `domain/calendar/calendar_data_pack_parser_test.dart` | R3-B 閺佺増宓侀崠鍛靶掗弸?|
| `domain/calendar/calendar_data_pack_validator_test.dart` | R3-B 閺佺増宓侀崠鍛墡妤犲矉绱欓弫浼村櫤/閸烆垯绔?閺冨爼妫?閺夈儲绨?楠炵繝鍞ら敍?|
| `domain/calendar/calendar_pack_import_test.dart` | R3-B 鐎电厧鍙嗛崢鐔风摍閹?Golden + 娣囶喛顓归崶娑欌偓?|
| `domain/calendar/calendar_engine_test.dart` | R3-B 瀵洘鎼哥紒鐓庢値 Golden + 缂傚搫鍕炬禒鑺ュ珕缂?|
| `domain/calendar/offline_gate_test.dart` | R3-B 缁傝崵鍤庨梻銊ь洣閿涘牊妫ょ純鎴犵捕 / 閺?Flutter / 閺?DateTime.now閿?|
| `domain/calendar/calendar_pack_fixtures.dart` | R3-B 濞村鐦径鐟板徔閿涘牊鐎柅鐘虫殶閹诡喖瀵?+ 鐠囪褰囩粔宥呯摍閸栧拑绱?|
| `domain/gate_b/gate_b_runner.dart` | R4-GATE-B 妤犲矁鐦夊ù瀣槸 / Markdown 閹躲儴銆冮悽鐔稿灇閸忋儱褰?|

### 5.16 gate-b/

| 閺傚洣娆?| 閼卞矁鐭?|
| --- | --- |
| `README.md` | Gate B 妤犲矁鐦夌拠瀛樻 |
| `01-gb-01.md` | Gate B 閸楁洖濮╅悥缁樼ゴ鐠囨洘濮ら崨?|
| `02-gb-02.md` | Gate B 婢舵艾濮╅悥缁樼ゴ鐠囨洘濮ら崨?|
| `03-gb-03.md` | Gate B 闂堟瑧鍩㈡禍瀣杽濞村鐦幎銉ユ啞 |
| `04-master-table.md` | 娑旀繄琚崗宕囬兇閺嶇顕幀鏄忋€?|

---

## 6. 濡€虫健娓氭繆绂嗛弬鐟版倻

```text
theme/  data/  閳? models/  閳? services/  閳? pages/  +  widgets/
                                                    閳? shell/
```

娓氭繆绂嗙痪锔芥将閿?

1. `data/`閵嗕梗theme/` 娑撳秳绶风挧鏍︽崲娴ｆ洑绗傜仦鍌浤侀崸妞尖偓?
2. `models/` 娑撳秳绶风挧鏍︽崲娴ｆ洑绗傜仦鍌浤侀崸妞尖偓?
3. `services/` 閸欘垯浜掓笟婵婄 `data/` 娑?`models/`閿涘奔绲炬稉宥堝厴娓氭繆绂?Flutter Widget閵?
4. `pages/` 閸欘垯浜掓笟婵婄 `services/`閵嗕梗models/`閵嗕梗data/`閵嗕梗theme/`閵?
5. `shell/` 閸欘垯浜掓笟婵婄閹碘偓閺堝銆夐棃銏∧侀崸妞尖偓?
6. `widgets/` 閸欘亙绶风挧?`models/`閵?
7. 缁備焦顒涘顏嗗箚娓氭繆绂嗛妴?
8. 缁備焦顒涢崷銊┿€夐棃銏㈢矋娴犳湹鑵戦崘娆忣槻閺夊倷绗熼崝锟犫偓鏄忕帆閿涘牆鍤０妯糕偓浣筋吀閸掑棎鈧線鏁婃０妯碱吀閻炲棴绱氶妴?

---

## 7. 瑜版挸澧犻弸鑸电€崢鐔峰灟

### 7.1 閸掑棗鐪伴崢鐔峰灟

```text
閺佺増宓佺€规矮绠?閳?娑撳顣界化鑽ょ埠 閳?娑撴艾濮熼柅鏄忕帆 閳?閻樿埖鈧胶顓搁悶?閳?UI 妞ょ敻娼?
```

| 鐏炲倻楠?| 鐠囧瓨妲?|
| --- | --- |
| 閺佺増宓佺€规矮绠?| 娴滄棁顢戦悽鐔峰帬閺勭姴鐨犻妴浣告勾閺€顖欎繆閹垬鈧礁鍟块崥鍫濆彠缁?|
| 娑撳顣界化鑽ょ埠 | `WuxingColors` 妫版粏澹婃担鎾堕兇 |
| 娑撴艾濮熼柅鏄忕帆 | 閸戞椽顣界粻妤佺《閵嗕浇顓搁弮璺哄灲鐎规哎鈧線鏁婃０妯绘暪瑜?|
| 閻樿埖鈧胶顓搁悶?| `MistakeStore` 閸楁洑绶ョ粻锛勬倞闁挎瑩顣介悩鑸碘偓?|
| UI 妞ょ敻娼?| 閸ユ稒鐖€佃壈鍩?+ 5 娑擃亜鐡欐い鐢告桨閸?|

### 7.2 瑜版挸澧犳稉宥呬粵閻ㄥ嫬鍞寸€?

瑜版挸澧犻悧鍫熸拱閺嗗倷绗夊鈧崣鎴窗

- 閸︾増鏁崷鍡欐磸閸欘垵顫嬮崠鏍矋娴犺绱?
- 娑撳鎮庢稉澶夌窗閺佺増宓佹稉搴ゎ唲缂佸喛绱?
- 婢垛晛鍏遍弫鐗堝祦娑撳氦顔勭紒鍐跨幢
- 缁炬娊鐓舵禍鏃囶攽閿?
- 閸忣厼宕勯崶娑樺捶閿?
- 缂佺喕顓搁崶鎹愩€冩稉搴☆劅娑旂姵娲哥痪鍖＄幢
- 婢舵氨鏁ら幋?婢舵俺顔曟径鍥ф倱濮濄儯鈧?

---

## 8. 閻楀牊婀伴崢鍡楀蕉

| 閻楀牊婀?| 閺冦儲婀?| 缁鐎?| 鐠囧瓨妲?|
| --- | --- | --- | --- |
| `v0.1.12` | 2026-09-15 | 鏂板 | R5-C DSL Parser & Formatter round trip (Fast-Track) |
| `v0.1.11` | 2026-09-14 | 閲嶆瀯 | R5-B Rule Engine |
| `v0.1.10` | 2026-05-22 | 閺傛澘顤?| 閸忓磭閮存潻鐐剁箾閻绱?5缂佸嫰鍘ょ€?50瀵姴宕卞☉鍫ユ珟+閸ョ偟鍊?|
| `v0.1.9` | 2026-05-22 | 閺傛澘顤?| 閺傜懓娼￠柅鐔虹摕濞撳憡鍨欏Ο鈩冩緲閿涘苯宕熸０妯圭瑓閽€?+ 鐠佲剝妞?+ 閸ョ偟鍊?|
| `v0.1.8.3` | 2026-05-18 | 闁插秵鐎?| 閺冄冨弳閸欙綀绺肩粔璇插煂闁氨鏁ょ紒鍐х瘎濡楀棙鐏﹂敍宀€绮￠崗鍛婂瘻闁筋喖顦禒?|
| `v0.1.7.2` | 2026-05-18 | 娴兼ê瀵?| 閸﹀棛娲忛幒鎺斿缁彞鎱ㄩ敍宀€顔勬径鎾缉鐠佲晪绱濋懗璺烘抄閼哄倻鍋?|
| `v0.1.7.1` | 2026-05-18 | 闁插秵鐎?| 娴犮儲鍨滄稉杞拌厬韫囧啫宕岀痪褍娓鹃惄妯肩波閺嬪嫸绱濋崶娑滃缁狀厼銇?|
| `v0.1.7` | 2026-05-18 | 閺傛澘顤?| 娴犮儲鍨滄稉杞拌厬韫囧啫顒熸稊鐘汇€夐敍灞炬閻╅晲绱ら崶姘劥 |
| `v0.1.6.2` | 2026-05-18 | 娴兼ê瀵?| 鏉烆喚娲忕亸鍝勵嚟缁嬪啿鐣鹃敍宀€绮ㄩ弸婊堛€夋稉澶愭▉濞堢數绮虹拋鈽呯礉閸ョ偟鍊濋弶銉︾爱閺嶅洨顒?|
| `v0.1.6.1` | 2026-05-16 | 娣囶喖顦?| 缁涙棃顣介崜宥夋閽樺繑褰佺粈鐚寸礉缁涙棃顣介崥搴㈡▔缁€铏瑰閺?|
| `v0.1.5` | 2026-05-16 | 閺傛澘顤?| 娴滄棁顢戦惄绋垮帬鐎涳缚绡勬い纰夌礉wrongCount 娣囶喖顦查敍灞芥礀閻愬鑴婄粣妤嬬礉闂冭埖顔岄弽鍥╊劮 |
| `v0.1.4.2` | 2026-05-16 | 娣囶喖顦?| 闁叉垵鍘撶槐鐘典紗閼瑰弶鏋冪€涙绱濈粵鏃堫暯閸欏秹顩懝鏌モ偓姘辨暏閸?|
| `v0.1.4.1` | 2026-05-16 | 閺傛澘顤?| 閸ョ偟鍊濋柨娆擃暯闁插秴浠涚化鑽ょ埠閿涘本瀵旀稊鍛鐎涙ê鍋?|
| `v0.1.4` | 2026-05-16 | 閺傛澘顤?| 閻╁摜鏁撶紒鍐х瘎娑撳妯佸▓纰夌窗鏉烆喚娲忛埆鎺戝兊閼规彃宕熼柅澶嗗晪閺冪姾澹婇崡鏇⑩偓?|
| `v0.1.3.13` | 2026-05-16 | 娴兼ê瀵?| 缁狀厼銇?3500ms 鐎靛綊缍?5s 閻楄鏅ラ敍灞肩鏉?25 缁?|
| `v0.1.3.12` | 2026-05-16 | 娴兼ê瀵?| 缁狀厼銇?1800ms閵嗕胶浼€閻㈢喎婀＄痪?CSS 閻楀牅鎱ㄦ径?viewBox |
| `v0.1.3.11` | 2026-05-16 | 閺傛澘顤?| 閸忋劑鍎存禍鏃€娼惄鍝ユ晸 HTML 閸斻劎鏁鹃幒銉ュ弳閿涘矁鐤嗛惄妯跨箷閸樼喐鍙冮柅?|
| `v0.1.3.10` | 2026-05-16 | 娴兼ê瀵?| 鏉烆喚娲忛崝鐘烩偓鐔诲殾 5 缁夋帊绔存潪?|
| `v0.1.3.9` | 2026-05-16 | 閸欐ɑ娲?| 閺堛劎鏁撻悘顐ｆ禌閹诡澀璐熼柦缁樻躬閸欐牜浼€閸斻劎鏁?|
| `v0.1.3.8` | 2026-05-16 | 閺傛澘顤?| 閻忣偆鏁撻崷?HTML 閸斻劎鏁鹃敍瀛抰mlRelationEffect 濞夋稑瀵?|

### 5.3.4 lib/domain/dsl/ (R5-C FAST-TRACK DSL 瑙ｆ瀽)

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| dsl_models.dart | DSL 鏍稿績鏁版嵁缁撴瀯 (ParsedGuayan, DslLine) |
| dsl_diagnostics.dart | 寮傚父鍙婅鍒椾綅缃彁绀烘ā鍨?|
| dsl_nayin_map.dart | 绾抽煶涓枃瀛楃鍒?Stable ID 鏄犲皠琛?|
| dsl_parser.dart | 鍗﹁█璇硶涓昏В鏋愬櫒鍏ュ彛 |
| dsl_formatter.dart | 鍗﹁█璇硶鍙嶅悜鏍煎紡鍖栧櫒 |
| parser/dsl_action_parser.dart | 鍔ㄤ綔瑙ｆ瀽鍣?(鏀寔寰椼€佸彇璞°€佹垚灞€銆佽) |
| parser/dsl_expr_parser.dart | 鏉′欢琛ㄨ揪寮忚В鏋愬櫒 (鏀寔13绉嶇畻瀛愪笌閫昏緫宓屽) |

### 5.17 test/domain/dsl/ (R5-C FAST-TRACK)

| 鏂囦欢 | 鑱岃矗 |
| --- | --- |
| dsl_smoke_test.dart | C1 闃舵 3 椤硅娉曟爲鏋勯€犻獙璇?|
| dsl_round_trip_test.dart | C2 闃舵 Parser/Formatter 骞傜瓑鎬т笌淇℃伅瀹堟亽楠岃瘉 |
| dsl_engine_integration_test.dart | C2 闃舵 DSL 鍒?R5-B RuleEngine 鎵ц鑳藉姏楠岃瘉 |

### 瑙勫垯娌荤悊 (lib/domain/rules/governance/)

| 鏂囦欢/鐩綍 | 鑱岃矗 |
| --- | --- |
| rule_resolver.dart | 鏍稿績瑙ｆ瀽鍣紝璐熻矗鐗堟湰閫夋嫨銆丼YSTEM/CUSTOM 瑕嗗啓銆佸拰纭畾鎬ф帓搴?|
| resolved_rule_set.dart | 瑙ｆ瀽鍚庤緭鍑虹殑鏁版嵁缁撴瀯 (鍖呭惈 active, suppressed, diagnostics) |
| rule_resolution_diagnostic.dart | 瑙ｆ瀽杩囩▼涓殑璇婃柇淇℃伅妯″瀷 |
## R7 Relation Graph & Ledger update — 2026-09-18

新增关系系统文件：

- `lib/domain/relations/relation_record.dart`：统一展示/治理记录模型，区分 RELATION 与 STATE。
- `lib/domain/relations/relation_projection.dart`：从现有 `RelationInstance` 投影稳定 FACT 记录，不重新计算关系。
- `lib/domain/relations/relation_capability.dart`：统计真实 Runtime 关系/状态能力。
- `lib/services/relation_annotation_store.dart`：按 caseId + stable recordId 保存用户备注/标签。
- `lib/services/relation_ledger_query.dart`：关系搜索与 AND 筛选纯逻辑。
- `lib/services/manual_relation_store.dart`：结构化 USER 关系存储。
- `lib/presentation/relations/relations_page.dart`：关系与状态 Ledger、搜索、筛选、详情与备注。
- `lib/presentation/review/relation_visual_tokens.dart`：Guayan Relation Visual Protocol V1.1 视觉 Token。
- `lib/presentation/review/widgets/relation_overlay.dart`：审卦关系 Overlay、Focus 过滤与基础路径绘制。
- `docs/superpowers/specs/2026-09-18-relation-graph-ledger-design.md`：R7 设计文档。
- `docs/superpowers/plans/2026-09-18-relation-graph-ledger.md`：R7 实现计划。

最后编辑时间：2026-09-18
