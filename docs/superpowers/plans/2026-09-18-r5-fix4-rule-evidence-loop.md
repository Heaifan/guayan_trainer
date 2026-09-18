# GUAYAN-R5-G2-R5-FIX4 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with verification checkpoints.

**Goal:** Connect rule matches to persisted Derived Evidence and a minimal review-page presentation while preserving the existing FIX3 runtime, trace, empty-binding, and legacy action semantics.

**Architecture:** Keep `RuleTrace` as the calculation explanation and introduce immutable `DerivedEvidence` as the result contract. Extend `TagAction` with an optional typed target that defaults to the existing object/subject behavior; relation actions use explicit source/target bindings and never infer a relation by attaching a tag to one endpoint. Carry both evidence and serialized traces through `AnalysisRun` and `RuleRun`, then adapt those persisted results into review state and small evidence/rule-run widgets.

**Tech Stack:** Flutter/Dart, existing Rule AST/Codec, `FactSnapshot`, `RuleEngine`, `RuleRun`/`CaseRecord`, SharedPreferences case repository, Flutter widget tests.

**Spec:** `C:\Users\35013\.codex\attachments\9ad46b1b-b220-4b1e-9798-d0299c585061\已粘贴的文本.txt`

## Global Constraints

- Preserve `e2b0940c` EMPTY/NO_MATCH behavior; legal empty dynamic selectors remain false, not ERROR.
- Preserve old JSON `{type: tag, cat, tagId, subject}`; absent target means OBJECT evidence.
- Keep Trace and Evidence separate: review result cards consume DerivedEvidence; debug details consume RuleTrace.
- Test-mode runs must not write CaseRecord or formal RuleRun.
- Historical evidence retains rule id/version/origin after the rule is disabled or removed.
- Do not add special runtime branches for “有路冲家” or new unrelated metaphysical operators.
- Update `file-tree.md` for every new/changed module and keep pure logic files focused.

### Task 1: Finish FIX3 trace and real corpus

**Files:**
- Modify: `lib/domain/rules/engine/predicate_evaluator.dart`
- Modify: `lib/domain/rules/engine/binding_resolver.dart`
- Modify: `lib/domain/rules/engine/action_executor.dart`
- Modify: `lib/presentation/rules/widgets/rule_trace_tree.dart`
- Create: `lib/domain/rules/engine/trace_labels.dart`
- Create: `test/domain/rules/engine/r5_real_rule_corpus_test.dart`

- [ ] Run the existing FIX3 corpus and confirm CASE A–E behavior before changing the trace layer.
- [ ] Keep candidate-level quantified traces and human-readable predicate/binding/action labels; retain machine `NO_MATCH` in serialized trace and localize it only in the widget.
- [ ] Assert CASE A–E, candidate count/match count, action success, and no error for CASE E.
- [ ] Run the focused test and `flutter analyze`.

### Task 2: Add typed action targets and DerivedEvidence

**Files:**
- Modify: `lib/domain/rules/ast/rule_action.dart`
- Modify: `lib/domain/rules/editor/rule_action_codec.dart`
- Create: `lib/domain/rules/evidence/derived_evidence.dart`
- Create: `test/domain/rules/evidence/derived_evidence_test.dart`
- Modify: `test/domain/rules/editor/rule_action_codec_test.dart` or the existing action codec test file.

- [ ] Add `ActionTarget` with OBJECT, RELATION, and CASE variants; keep `TagAction.subjectBinding` as the compatibility default.
- [ ] Encode relation targets with source binding, target binding, and relation id; decode both old and new JSON.
- [ ] Add immutable `DerivedEvidence` fields for id, case id, rule id/version/origin, action/category/value, target kind/refs, relation metadata, supports, run id, and trace reference, with JSON round-trip and equality.
- [ ] Test legacy object action, object target, relation target, case target, multiple supports, and provenance.

### Task 3: Emit evidence from runtime paths

**Files:**
- Modify: `lib/domain/rules/engine/engine_types.dart`
- Modify: `lib/domain/rules/engine/action_executor.dart`
- Modify: `lib/domain/rules/engine/stage_iteration_runner.dart`
- Modify: `lib/domain/rules/engine/rule_engine.dart`
- Modify: `lib/domain/rules/engine/rule_test_runner.dart`
- Create: `test/domain/rules/engine/derived_evidence_runtime_test.dart`

- [ ] Extend `ActionExecutionResult` and `AnalysisRun` with immutable `derivedEvidence` without removing existing tags/rule hits/traces.
- [ ] Pass the matched binding contexts and rule metadata into action emission. A relation target resolves explicit source/target bindings and preserves `branch_clashes` plus all predicate supports; object targets use the legacy subject binding; case targets have no endpoint.
- [ ] Make `AnyExpr` preserve every matched path’s binding context so simultaneous child matches yield separate evidence supports, while normal fact/tag de-duplication remains presentation-only.
- [ ] Generate stable evidence ids from case/run/rule/action/target/support identity and keep test runner output in memory only.
- [ ] Test R5 CASE A–E as Relation Evidence, both quantified and five-line paths, empty white-tiger path, action success, and test-mode non-persistence.

### Task 4: Persist RuleRun evidence and traces

**Files:**
- Modify: `lib/domain/cases/rule_run.dart`
- Modify: `lib/domain/cases/case_record.dart`
- Modify: `lib/domain/hexagram_case.dart`
- Modify: `lib/services/cases/generated_case_recorder.dart`
- Modify: `lib/services/cases/case_recompute_service.dart`
- Create/modify: `test/services/cases/rule_run_persistence_test.dart`

- [ ] Add structured serialized DerivedEvidence and RuleTrace snapshots to RuleRun with backward-compatible defaults for old JSON.
- [ ] Carry historical runs through `CaseRecord.toHexagramCase()` so reopening a case does not recalculate from current rules.
- [ ] Add recorder/recompute entry points that persist formal runs and leave `RuleTestRunner` untouched as memory-only.
- [ ] Test reload, rule version/origin provenance, disabled/deleted current rule with retained history, and recompute appending a new run.

### Task 5: Adapt review state and minimum evidence/rule-run UI

**Files:**
- Modify: `lib/presentation/review/review_page_state.dart`
- Modify: `lib/presentation/review/review_case_adapter.dart`
- Modify: `lib/presentation/review/review_page.dart`
- Modify: `lib/presentation/review/widgets/review_line_detail_sheet.dart`
- Create: `lib/presentation/review/widgets/review_evidence_card.dart`
- Create: `lib/presentation/review/widgets/review_rule_runs_card.dart`
- Create: `test/presentation/review/review_evidence_presentation_test.dart`

- [ ] Expose persisted evidence and rule-run summaries in review state; do not derive evidence by parsing Trace.
- [ ] Add a compact “取象” card and “规则运行” card with filters for all/matched/not-matched/skipped/error.
- [ ] Show object evidence in line detail, relation evidence in relation detail/section, and open a read-only source dialog showing rule origin/id/version, supports, and serialized trace.
- [ ] Deduplicate identical main-display evidence by target/value while preserving all underlying evidence references.
- [ ] Test object/relation/case presentation, multi-support deduplication, line detail visibility, and rule-run counts/statuses.

### Task 6: Corpus, docs, and final gates

**Files:**
- Modify: `file-tree.md`
- Create/modify: `test/domain/rules/corpus/r5_fix4_corpus_test.dart`

- [ ] Add R1, R3, R5, R6 coverage where existing runtime facts support it; mark R8 BLOCKED if twelve-growth facts are not available instead of faking them.
- [ ] Run `flutter analyze`, all rules tests, all tests, and `flutter build apk --release`.
- [ ] Review `git diff --check`, update file-tree, commit with a `feat:` or `fix:` why-oriented message, push `origin/feat/guayan-2.0`, and verify equal local/remote HEAD, 0/0, and clean worktree.

