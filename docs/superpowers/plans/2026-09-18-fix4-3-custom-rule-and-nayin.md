# GUAYAN-R5-FIX4.3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with verification checkpoints.

**Goal:** Make enabled CUSTOM Rules execute in formal Case recomputation and restore independent fushen/original/changed NaYin semantic elements throughout Review.

**Architecture:** Reuse `RuntimeRuleSetAssembler`, `CanonicalFactSnapshotBuilder`, `RuleEngine`, `RuleRun.fromAnalysis`, and `NaYinCatalog` as the existing domain sources. Add a small formal recomputation coordinator around those sources, extend the pure Review state/adapter with typed NaYin values, and keep Widgets as renderers of adapter data.

**Tech Stack:** Dart, Flutter, `flutter_test`, SharedPreferences-backed rule stores, existing RuleEngine and Review semantic element protocol.

**Spec:** `docs/superpowers/specs/2026-09-18-fix4-3-custom-rule-and-nayin-design.md`

## Global Constraints

- Do not change the smoke-rule JSON, FactSnapshot fixture, or test-only Runtime to hide the formal Case defect.
- Reuse `lib/domain/rules/vocabulary/nayin_catalog.dart`; no second 60 JiaZi table in Review.
- OBJECT evidence remains an object/tag evidence; only true relation rules create relation evidence.
- Pure logic Dart files stay at or below 150 lines; split by concrete responsibility when needed.
- Update `file-tree.md` for every created/renamed/deleted file and for changed responsibilities.
- Run targeted tests, `flutter analyze`, full `flutter test`, and Release APK before completion.

### Task 1: Reproduce the formal CUSTOM Rule gap

**Files:**
- Create: `test/services/cases/formal_case_recompute_test.dart`
- Inspect/modify only if required by the failing test: `lib/app/app_shell.dart`, `lib/domain/rules/engine/runtime_rule_set_assembler.dart`, `lib/services/cases/case_recompute_service.dart`

**Interfaces:**
- Consumes the existing `CustomRuleService`, `RuntimeRuleSetAssembler`, `CanonicalFactSnapshotBuilder`, and `CaseRecomputeService`.
- Produces a failing regression test for an enabled custom OBJECT rule and a trace of the boundary where the formal path currently loses the rule set.

- [ ] **Step 1: Write the failing test**

  Build one real `HexagramCase` with complete six-line facts, seed an enabled custom rule whose predicates are `relative.child` and `spirit.qing_long`, create a `CaseRecord`, and assert that the formal recomputation result contains one matched rule and an OBJECT `DerivedEvidence` with tag `road` and target line 1.

- [ ] **Step 2: Run the test to verify RED**

  Run `flutter test test/services/cases/formal_case_recompute_test.dart -r expanded`.
  Expected: the test fails because the current formal recompute path does not execute the selected custom rule and produces no matching evidence.

- [ ] **Step 3: Trace the boundary without changing production code**

  Compare the test-run rule list, `ResolvedRuleSet.activeRules`, `AnalysisRun.traces`, and persisted `CaseRecord.ruleRuns`; record whether loss occurs before `RuleEngine.execute`, during execution, or when Review reads the Case.

- [ ] **Step 4: Commit the reproducer**

  Run `git add test/services/cases/formal_case_recompute_test.dart && git commit -m "test: reproduce formal custom rule gap"`.

### Task 2: Wire formal recomputation to the selected runtime rule set

**Files:**
- Create: `lib/services/cases/formal_case_recompute_service.dart`
- Modify: `lib/app/app_shell.dart`
- Modify: `lib/domain/rules/engine/runtime_rule_set_assembler.dart` only if the audit proves custom rules are filtered incorrectly
- Test: `test/services/cases/formal_case_recompute_test.dart`

**Interfaces:**
- `FormalCaseRecomputeService.recompute({required CaseRecord record, required List<String> selectedTopicIds, required RuntimeRuleSetAssembler assembler}) -> Future<CaseRecord>` executes the resolved active rules and appends one persisted `RuleRun`.
- The app recompute callback uses this service and reloads the returned Case.

- [ ] **Step 1: Add a focused failing service-level assertion**

  Assert the recomputed `RuleRun.result['matched'] == 1`, `result['notMatched']` counts only active rules, and `derivedEvidence.single.targetKind` is object; also assert the custom rule title and version are in the evidence.

- [ ] **Step 2: Run the focused test and confirm RED**

  Run `flutter test test/services/cases/formal_case_recompute_test.dart -r expanded` and verify the failure is the missing formal execution, not fixture construction.

- [ ] **Step 3: Implement the minimal coordinator**

  Build `FactSnapshot` from the Case, call `assembler.assemble(selectedTopicIds).activeRules`, invoke `RuleEngine.execute` exactly once with the Case id and new run id, create `RuleExecutionContext` from the resolved rule versions, then call `CaseRecomputeService.recomputeAnalysis`.

- [ ] **Step 4: Connect Review’s recompute action**

  Replace the current `AppShellState._recomputeActiveCase` behavior that copies the latest result/evidence with the coordinator; initialize the same rule stores/assembler used by the rule library and preserve selected rule-pack/topic choices.

- [ ] **Step 5: Run the focused test and confirm GREEN**

  Run `flutter test test/services/cases/formal_case_recompute_test.dart -r expanded` and verify one formal RuleRun contains the custom OBJECT evidence.

- [ ] **Step 6: Commit the execution fix**

  Run `git add lib/services/cases/formal_case_recompute_service.dart lib/app/app_shell.dart lib/domain/rules/engine/runtime_rule_set_assembler.dart test/services/cases/formal_case_recompute_test.dart && git commit -m "fix: execute selected rules during case recompute"`.

### Task 3: Close Trace, actual-value, and OBJECT/RELATION regressions

**Files:**
- Modify: `lib/domain/rules/engine/predicate_evaluator.dart` or the actual trace-producing resolver identified in Task 1
- Modify: `lib/presentation/rules/widgets/rule_trace_tree.dart`
- Modify: `lib/domain/rules/editor/rule_mapping_table.dart` or the existing display mapper for `road`
- Test: `test/domain/rules/engine/trace_execution_test.dart`
- Test: `test/presentation/review/review_evidence_presentation_test.dart`

**Interfaces:**
- Trace nodes preserve `expected` and resolved `actual` display values.
- The display mapper returns `道路` for `road` while serialization remains `road`.

- [ ] **Step 1: Add failing assertions**

  Assert a formal run has one rule trace for the smoke rule, its relative predicate has actual `子孙`, and the OBJECT evidence does not appear in relation records; add a true relation fixture asserting only the `有路冲家` rule creates a relation record.

- [ ] **Step 2: Run targeted tests and confirm RED**

  Run `flutter test test/domain/rules/engine/trace_execution_test.dart test/presentation/review/review_evidence_presentation_test.dart -r expanded`.

- [ ] **Step 3: Fix the source of duplication/value loss**

  If traces are duplicated in `AnalysisStageExecutor`/`StageRunner`, stop the second execution or duplicate append; if only the widget duplicates them, render the persisted tree once. Preserve actual values from operand resolution instead of falling back to `未知`.

- [ ] **Step 4: Fix the display-only tag mapping**

  Route `road` through the existing rule value/tag display catalog and assert `tagId == road` remains unchanged.

- [ ] **Step 5: Run targeted tests and confirm GREEN**

  Repeat the two targeted test commands and inspect the trace tree output for one rule/predicate/action chain.

- [ ] **Step 6: Commit the trace/evidence fix**

  Run `git add lib/domain/rules lib/presentation/rules/widgets/rule_trace_tree.dart test/domain/rules/engine/trace_execution_test.dart test/presentation/review/review_evidence_presentation_test.dart && git commit -m "fix: preserve formal rule trace values and evidence semantics"`.

### Task 4: Add typed independent NaYin values to Review adapter

**Files:**
- Modify: `lib/presentation/review/review_page_state.dart`
- Modify: `lib/presentation/review/review_case_adapter.dart`
- Modify: `lib/domain/casting/cast_chart.dart` only if a missing typed changed `gan/branch` accessor is required
- Test: `test/domain/rules/nayin_truth_test.dart`
- Test: `test/presentation/review/review_case_adapter_test.dart`

**Interfaces:**
- Add nullable `naYin` fields to `ReviewLineIdentity`, `ReviewChangedLine`, and each structured `FushenResult` projection without changing existing text compatibility fields.
- Adapter derives each value from the specific `TianGan + DiZhi` pair through `NaYinCatalog`, with no Widget calculation.

- [ ] **Step 1: Expand domain truth tests first**

  Add parameterized checks for all 60 JiaZi indices mapping to 30 entries, and explicit tests proving a changed line uses its changed stem/branch and a fushen uses its own stem/branch.

- [ ] **Step 2: Run NaYin tests and confirm RED for missing line projections**

  Run `flutter test test/domain/rules/nayin_truth_test.dart test/presentation/review/review_case_adapter_test.dart -r expanded`.

- [ ] **Step 3: Implement one domain-to-NaYin helper**

  Add a pure helper in the domain/vocabulary layer that resolves a `TianGan`/`DiZhi` pair to the catalog entry; calculate the JiaZi index from the existing enum cycle values and do not duplicate labels.

- [ ] **Step 4: Extend adapter state**

  Populate main, changed, and fushen NaYin fields independently; leave them null when no changed line or no fushen exists. Preserve reload determinism because all values derive from serialized Case facts.

- [ ] **Step 5: Run adapter/domain tests and confirm GREEN**

  Run the two targeted test files and verify main/changed values differ where their干支 differ.

- [ ] **Step 6: Commit the adapter model**

  Run `git add lib/domain lib/presentation/review/review_page_state.dart lib/presentation/review/review_case_adapter.dart test/domain/rules/nayin_truth_test.dart test/presentation/review/review_case_adapter_test.dart && git commit -m "feat: project independent nayin facts into review lines"`.

### Task 5: Render NaYin as compact clickable semantic elements

**Files:**
- Modify: `lib/presentation/review/widgets/review_hexagram_line_row.dart`
- Modify: `lib/presentation/review/widgets/hexagram_line_cell.dart`
- Modify: `lib/presentation/review/widgets/review_line_detail_sheet.dart` if detail routing needs a NaYin element
- Test: `test/presentation/review/review_page_test.dart`
- Test: `test/presentation/review/review_evidence_presentation_test.dart` if semantic tap coverage belongs there

**Interfaces:**
- The row renders a second, weaker text baseline under each non-null fushen/main/changed identity.
- Tapping a NaYin uses the existing semantic element callback/identity and exposes type `纳音`, object scope, and value to the detail/notes path.

- [ ] **Step 1: Add failing widget/semantics assertions**

  Pump a line containing all three NaYin types and assert all labels are visible, a line without fushen has no placeholder, and the NaYin semantic node reports type/value/object scope.

- [ ] **Step 2: Run the focused widget test and confirm RED**

  Run `flutter test test/presentation/review/review_page_test.dart -r expanded` and verify the failure is missing labels/semantics rather than layout setup.

- [ ] **Step 3: Implement compact rendering**

  Reuse the row’s existing secondary baseline, apply the weaker color/text style, and only allocate the baseline for non-null NaYin. Keep fixed board column geometry and existing long-text overflow protections.

- [ ] **Step 4: Implement semantic detail/notes identity**

  Pass a stable identity containing source (`fushen`, `original`, or `changed`) and position into the existing click/annotation flow; do not make NaYin a plain decorative `Text`.

- [ ] **Step 5: Run widget tests and confirm GREEN**

  Run the review page and semantic detail tests, then inspect the golden/layout assertions for unchanged six-line density.

- [ ] **Step 6: Commit the UI semantic restoration**

  Run `git add lib/presentation/review/widgets test/presentation/review/review_page_test.dart test/presentation/review/review_evidence_presentation_test.dart && git commit -m "feat: restore compact clickable nayin review display"`.

### Task 6: Documentation, full verification, APK, and delivery

**Files:**
- Modify: `file-tree.md`
- Modify: `pubspec.yaml` and `android/app/build.gradle` only if the release version is intentionally incremented for this release

- [ ] **Step 1: Run all targeted Rules/Case/Review tests**

  Run `flutter test test/domain/rules test/services/cases test/presentation/review test/presentation/rules -r expanded`.

- [ ] **Step 2: Run analyzer**

  Run `flutter analyze` and resolve every error/warning introduced by this change.

- [ ] **Step 3: Run the full suite**

  Run `flutter test -r expanded`; record total passing tests and any pre-existing skips/failures separately.

- [ ] **Step 4: Build Release APK**

  Run `flutter build apk --release`; record the generated APK path and build exit code.

- [ ] **Step 5: Update project tree and inspect diff**

  Update `file-tree.md` with the actual files and current system time, then run `git diff --check`, `git status --short`, and `git diff --stat`.

- [ ] **Step 6: Commit, push, and verify delivery state**

  Commit with a `fix:` or `feat:` why-oriented message, push the current branch, then run `git status --porcelain=v1`, `git rev-list --left-right --count @{u}...HEAD`, and `git rev-parse HEAD`. Report the final SHA, remote `0/0`, clean state, tests, APK, root cause, evidence result, NaYin audit, Trace root cause, and per-file `+/-` counts.
