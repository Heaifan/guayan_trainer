# GUAYAN-R5-FIX4.2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with verification checkpoints.

**Goal:** Let rule tests select a real Case and make the visual editor faithfully render quantified, dynamic, and tagged AST nodes without semantic loss.

**Architecture:** Thread an optional read-only `CaseRepository` and current `HexagramCase` from the app shell into the rule editor. Keep the selected Case in editor-session state, build facts only through `CanonicalFactSnapshotBuilder`, and render selectors/tags through domain catalogs. The visual renderer remains a projection; saving continues to serialize the unchanged draft AST.

**Tech Stack:** Flutter/Dart, widget tests, pure domain tests, existing CaseRepository and PortableRuleCodec.

**Spec:** `GUAYAN-R5-FIX4.2` pasted task text supplied on 2026-09-18.

## Global Constraints

- Do not modify the frozen “有路冲家” JSON semantics.
- Do not restore empty or fake FactSnapshot execution.
- Test mode is read-only and never writes Case, RuleRun, or DerivedEvidence.
- Do not add 十二长生 facts.
- Preserve old subject JSON compatibility and existing FIX4 Runtime behavior.
- Keep pure logic files under 150 lines where practical and update `file-tree.md` for changed responsibilities.

### Task 1: Case selection and editor-session context

**Files:**
- Modify: `lib/presentation/rules/rule_editor_page.dart`
- Modify: `lib/presentation/rules/rule_test_result_page.dart`
- Modify: `lib/app/app_shell.dart`, `lib/app/more_menu.dart`
- Modify: `lib/presentation/rules/rule_library_page.dart`, `rule_center_page_loader.dart`, `rule_center_page.dart`, `system_rule_list_page.dart`
- Test: `test/presentation/rules/rule_editor_page_test.dart`

- [ ] Write a failing widget test proving no Case opens a Case selector, selecting a Case starts a read-only test, and a second test reuses the session Case.
- [ ] Run the focused widget test and confirm it fails because the editor currently only shows an error dialog.
- [ ] Add repository injection, query recent non-deleted Cases, convert the selected `CaseRecord` to `HexagramCase`, and store it in editor state.
- [ ] Pass the existing current Case and repository through the app rule-library navigation.
- [ ] Route selected Cases through `CanonicalFactSnapshotBuilder` and `RuleTestRunner`; never create an empty snapshot.
- [ ] Show Case question, derived hexagram name, and timestamp with a “更换” action; show an explicit empty-repository dialog.
- [ ] Run the focused widget and Case tests; confirm test mode does not call repository update/create.

### Task 2: AST visual projection and semantic vocabulary

**Files:**
- Modify: `lib/domain/rules/editor/rule_visual_renderer.dart`
- Modify: `lib/domain/rules/objects/dynamic_object_catalog.dart`
- Modify: existing tag/value catalog source selected after audit
- Test: `test/domain/rules/editor/rule_visual_renderer_test.dart`

- [ ] Write failing renderer tests for `QuantifiedExpr` with nested `AllExpr`, dynamic spirit binding, `dynamic.line.all`, and `road_clash_home`.
- [ ] Run the renderer tests and confirm placeholders/raw tag IDs appear.
- [ ] Render quantified headers from selector catalog metadata, recurse into nested nodes, and add the quantified binding to the local projection context.
- [ ] Resolve direct and dynamic binding labels through selector/catalog formatters; do not add rule-specific Widget branches.
- [ ] Add the stable tag vocabulary entry for `road_clash_home` and map it through the existing domain presentation catalog.
- [ ] Verify JSON → AST → visual projection → unchanged AST → JSON semantic equivalence.

### Task 3: Full verification and delivery

**Files:**
- Modify: `file-tree.md`

- [ ] Run `flutter analyze`.
- [ ] Run FIX4.2 focused tests, CASE A–E, Case/RuleRun/Review tests, and full `flutter test`.
- [ ] Build `flutter build apk --release`.
- [ ] Commit with a `fix:` prefix and push `origin/feat/guayan-2.0`.
- [ ] Recheck local/remote SHA, ahead/behind, clean worktree, and report per-file line counts.
