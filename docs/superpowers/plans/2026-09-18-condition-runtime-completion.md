# G2-C Condition Runtime Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the rule editor derive its condition choices from one canonical runtime-backed catalog, expose all currently executable conditions, and establish a tested path for adding future six-line facts without fake UI capabilities.

**Architecture:** Keep AST and Runtime OperatorRegistry as execution truth, while introducing a single typed ConditionCatalog descriptor consumed by validation, editor menus, value dependencies, and tests. First normalize the 13 technical operators into 12 user conditions by hiding the `empty` compatibility alias and renaming `in_tomb` to user-facing “在墓”; then implement structured operand selection for unary, attribute, relation, and tag predicates.

**Tech Stack:** Dart, Flutter, existing Rule AST/Codec, Runtime OperatorRegistry, Flutter widget tests.

**Spec:** User-pasted G2-C Condition Runtime completion task in the conversation.

## Global Constraints

- Do not change existing SYSTEM rules, G2 Catalog semantics, casting, review, or Engine behavior outside explicit new operator coverage.
- AST remains the only editor source of truth; no DSL text state in normal editing.
- Unsupported capabilities must not appear in UI until a real evaluator and persistence path exist.
- Keep pure logic Dart files under 150 lines and update `file-tree.md` for new files/responsibilities.

---

### Task 1: Freeze the canonical condition capability matrix

**Files:**
- Create: `lib/domain/rules/editor/condition_capability.dart`
- Modify: `lib/domain/rules/editor/condition_catalog.dart`
- Test: `test/domain/rules/editor/condition_catalog_test.dart`

- [ ] Add descriptors for the 12 user conditions: six-spirit, six-relative, na-yin, xun-kong, month-break, day-break, in-tomb (displayed as 在墓), generates, enters-tomb-of, clashes-tomb, exits-tomb, has-tag.
- [ ] Mark `empty` as compatibility-only and exclude it from user catalog output.
- [ ] Include shape, operand count/kinds, runtime operator id, value source, and supported status in each descriptor.
- [ ] Write failing tests asserting catalog IDs are unique, `empty` is absent, `in_tomb` is labeled 在墓, and every visible descriptor resolves in OperatorRegistry.
- [ ] Run the catalog tests to observe the expected failure before implementation.
- [ ] Implement the typed descriptor and catalog projection from `CanonicalConditionRegistry` plus explicit alias policy.
- [ ] Run targeted tests and `flutter analyze`.

### Task 2: Expose the catalog instead of hard-coded editor choices

**Files:**
- Modify: `lib/presentation/rules/rule_editor_page.dart`
- Modify: `lib/domain/rules/editor/condition_catalog.dart`
- Test: `test/presentation/rules/rule_editor_page_test.dart`

- [ ] Add a widget test that opens 添加条件 and asserts all 12 user conditions are present while 空亡 is absent.
- [ ] Replace `_conditionFor`’s seven-item list with catalog-driven descriptors filtered to supported runtime conditions.
- [ ] Preserve user labels: 在墓, 入墓于, 冲墓, 出墓, 有标签.
- [ ] Add search to the condition sheet and use the descriptor display name/keywords.
- [ ] Run the widget test before implementation and verify it fails because the sheet currently exposes seven items.
- [ ] Implement the catalog-driven sheet and keep the existing AST mutation only for shapes it can currently construct.
- [ ] Run widget tests and analyze.

### Task 3: Complete closed value catalogs and display mapping

**Files:**
- Create: `lib/domain/rules/editor/rule_value_catalog.dart`
- Modify: `lib/domain/rules/editor/rule_visual_renderer.dart`
- Modify: `lib/presentation/rules/rule_editor_page.dart`
- Test: `test/domain/rules/editor/rule_value_catalog_test.dart`

- [ ] Test six spirits, five relatives, all 30 NaYin entries, and Chinese display for every stable id.
- [ ] Normalize relative IDs to the existing canonical vocabulary and add compatibility mapping for legacy aliases.
- [ ] Replace the five-item NaYin list with the complete catalog and searchable picker.
- [ ] Ensure renderer never shows `nayin.*`, `relative.*`, or `spirit.*` in normal UI.
- [ ] Run targeted tests and analyze.

### Task 4: Add structured AST builders for relation and tag predicates

**Files:**
- Create: `lib/domain/rules/editor/condition_ast_builder.dart`
- Modify: `lib/presentation/rules/rule_editor_page.dart`
- Test: `test/domain/rules/editor/condition_ast_builder_test.dart`

- [ ] Write failing tests for exact operand shapes: generate(2 refs), ru_mu(2 refs), chong_mu(2 refs), chu_mu(3 refs), has_tag(ref/category/value).
- [ ] Implement builders that construct valid PredicateExpr operands and preserve All/Any/Not parent nodes.
- [ ] Add object-B/object-C selection for relation conditions without exposing binding names.
- [ ] Add category and value selection for 有标签 using the existing tag category and shensha catalogs.
- [ ] Run builder and existing codec/service tests.

### Task 5: Runtime foundation audit and first missing operators

**Files:**
- Create/modify only after tests: `lib/domain/rules/engine/operators/*`
- Modify: `lib/domain/rules/vocabulary/condition_id.dart`
- Test: `test/domain/rules/engine/*_operator_test.dart`

- [ ] Produce a source-backed matrix for elemental facts and relations before adding any operator.
- [ ] Add failing tests for element_is, branch_is, heavenly_stem_is, yin_yang_is, generates, controls, clashes, combines, harms, punishes, breaks, line_position_is, shi_ying_is, and movement_is only where snapshot facts can prove them.
- [ ] Implement only operators with existing immutable facts in the runtime snapshot; do not invent missing facts.
- [ ] Register each implemented operator and add schema/codec coverage.
- [ ] Leave unsupported twelve-growth, fly/hidden, advance/retreat, and hexagram-structure capabilities out of UI until their facts exist.

### Task 6: Integrate structured selection and regressions

**Files:**
- Modify: `lib/presentation/rules/rule_editor_page.dart`
- Test: `test/presentation/rules/rule_editor_page_test.dart`
- Modify: `file-tree.md`

- [ ] Test UI flows for attribute, unary state, binary relation, and tag condition shapes.
- [ ] Verify changing an attribute clears incompatible values and that technical IDs never render.
- [ ] Verify imported JSON reconstructs all Token rows from AST.
- [ ] Run targeted editor/domain tests, `flutter analyze`, then full `flutter test` and record unrelated failures without changing out-of-scope code.
- [ ] Update file-tree responsibilities and timestamp.

## Verification Summary

The completion gate is: catalog/runtime/UI counts agree; `empty` is hidden; 在墓 is correctly labeled; all currently supported relation/tag predicates can be constructed as valid AST; unsupported capabilities remain absent; targeted tests and `flutter analyze` pass.
