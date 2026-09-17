# R5-G1 Rule Center UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with review checkpoints.

**Goal:** 将规则中心重构为方案 A 的中文化、分类化、可查看界面，同时保留现有 Engine、DSL、AST、COMMON 保存边界和规则执行语义不变。

**Architecture:** 在 `lib/presentation/rules/presentation/` 增加纯展示模型与映射器，直接读取真实 `RuleDefinition`、AST 和 `GuayanDslFormatter` 输出；页面层拆成首页、系统规则列表、详情页和编辑页，编辑器继续复用现有 Binding/Condition/Action Editor 与 `CustomRuleService.save`。

**Tech Stack:** Flutter Material widgets, Dart pure presentation adapters, `flutter_test`, existing rule corpus and DSL formatter.

**Spec:** User-frozen R5-G1 Scheme A pasted specification in the conversation.

## Global Constraints

- 不修改 Rule Engine、DSL Grammar、Parser、AST、Evidence 计算语义。
- 不修改 COMMON Rule ID、COMMON 数据和 `CustomRuleSaveBoundary`。
- 系统规则只读；只有已有复制能力可用时才显示复制入口。
- 新建自定义规则默认使用 CUSTOM namespace。
- 不新增数据库；最近使用只保存于当前 session state。
- 页面职责拆分，避免把规则中心继续塞进单一 Dart 文件。
- 保留现有未跟踪截图、`uploads/screenshots/` 和 `window.xml`。

---

### Task 1: Presentation metadata and test fixtures

**Files:**
- Create: `lib/presentation/rules/presentation/rule_display_model.dart`
- Create: `lib/presentation/rules/presentation/rule_presentation_mapper.dart`
- Create: `test/presentation/rules/rule_presentation_mapper_test.dart`

- [ ] Write tests for Chinese title/category/description mapping, COMMON fallback, technical ID preservation, and DSL formatting.
- [ ] Run the mapper test and verify it fails because the adapter does not exist.
- [ ] Implement immutable display metadata and a mapper based on actual rule origin, category, actions, conditions, and existing formatter.
- [ ] Run the mapper test until green.

### Task 2: Rule library home and system rule list

**Files:**
- Modify: `lib/presentation/rules/rule_library_page.dart`
- Create: `lib/presentation/rules/system_rule_list_page.dart`
- Create: `lib/presentation/rules/widgets/rule_search_bar.dart`
- Create: `lib/presentation/rules/widgets/rule_entry_card.dart`
- Create: `lib/presentation/rules/widgets/rule_category_filter.dart`
- Create: `lib/presentation/rules/widgets/rule_list_card.dart`
- Create: `test/presentation/rules/rule_library_page_test.dart`

- [ ] Add widget tests for the three ordered entry cards, search field, and recent session state.
- [ ] Run the widget test and verify it fails against the old Skeleton.
- [ ] Implement the Scheme A home page and route system rules to the new list page.
- [ ] Implement list filtering by Chinese title, rule ID, and derived category; keep enable toggles working through the existing governance state.
- [ ] Run the focused widget tests.

### Task 3: Read-only rule details

**Files:**
- Create: `lib/presentation/rules/rule_detail_page.dart`
- Create: `lib/presentation/rules/widgets/rule_dsl_preview.dart`
- Create: `test/presentation/rules/rule_detail_page_test.dart`

- [ ] Add widget tests for title, Chinese description, technical metadata, binding/condition/action sections, and formatted DSL.
- [ ] Verify the new test fails before implementation.
- [ ] Implement a read-only details page and connect each system rule card's 查看 action to it.
- [ ] Only expose copy-as-custom when the existing copy route is available; never show a fake edit button for SYSTEM rules.
- [ ] Run the focused detail tests.

### Task 4: Scheme A custom editor layout

**Files:**
- Modify: `lib/presentation/rules/rule_editor_page.dart`
- Modify: `lib/presentation/rules/rule_editor_form.dart`
- Create: `lib/presentation/rules/widgets/rule_editor_action_card.dart`
- Create: `test/presentation/rules/rule_editor_page_test.dart`

- [ ] Add tests for CUSTOM default namespace, three editor entry cards, non-empty/empty DSL preview, and save boundary routing.
- [ ] Verify the tests fail against the current debug-style editor.
- [ ] Implement the reorganized basic-info fields, persistent DSL preview, three action cards, and fixed bottom action bar.
- [ ] Preserve the existing draft/editor widgets and call `CustomRuleService.save` unchanged.
- [ ] Run focused editor tests.

### Task 5: Integrated verification and acceptance handoff

**Files:**
- Modify: `file-tree.md`
- Modify: `CHANGELOG.md`

- [ ] Run `flutter analyze` and fix only R5-G1 presentation issues.
- [ ] Run focused presentation and R5 DSL/Engine/CUSTOM tests.
- [ ] Run `flutter test`.
- [ ] Run Gate A verify and `git diff --check`.
- [ ] Launch/reload the existing Android emulator app for the six-item human acceptance checklist.
- [ ] Commit, push, and verify local/remote SHA equality after user-visible implementation is complete.
