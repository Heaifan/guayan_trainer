# Rule Trace and Scoped Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add explainable rule execution and generic quantified line matching while preserving all existing rule contracts.

**Architecture:** Add immutable trace models beside the engine, thread trace collection through the existing evaluator/resolver/action pipeline, and preserve the old APIs with additive fields and wrappers. Use a generic six-line scope selector plus matched binding contexts rather than property-specific selectors.

**Tech Stack:** Dart, Flutter, existing Rule AST/Codec/DSL, package:test, Flutter widget tests.

**Spec:** `docs/superpowers/specs/2026-09-18-rule-trace-and-scoped-runtime-design.md`

## Global Constraints

- Existing AST semantics and old JSON remain readable.
- `ERROR` is never reported as `NOT_MATCHED`.
- Services/domain remain free of Flutter dependencies.
- Pure logic files stay under 150 lines where practical; barrel files preserve exports when split.
- Test mode never writes Case or historical RuleRun data.

### Task 1: Trace model and evaluator results

**Files:**
- Create: `lib/domain/rules/engine/rule_trace.dart`
- Modify: `lib/domain/rules/engine/predicate_result.dart`
- Test: `test/domain/rules/engine/rule_trace_test.dart`

- [ ] Write failing tests for `MATCHED`, `NOT_MATCHED`, `SKIPPED`, `ERROR`, nested expression children, expected/actual values, and JSON-safe trace data.
- [ ] Run the focused test and confirm it fails because the trace model is absent.
- [ ] Implement immutable trace/status/value models and additive `PredicateResult.trace`/`matchedBindings` fields.
- [ ] Re-run the focused tests and existing predicate tests.

### Task 2: Binding, predicate, and action traces

**Files:**
- Modify: `lib/domain/rules/engine/binding_resolver.dart`
- Modify: `lib/domain/rules/engine/predicate_evaluator.dart`
- Modify: `lib/domain/rules/engine/action_executor.dart`
- Modify: `lib/domain/rules/engine/engine_types.dart`
- Test: `test/domain/rules/engine/trace_execution_test.dart`

- [ ] Add failing tests for direct/dynamic binding evidence, predicate actual values, nested all/any/not/quantified trees, action success, and unresolved binding errors.
- [ ] Run them to verify the expected failures.
- [ ] Add trace-aware methods while keeping `resolve` and `evaluate` behavior compatible; collect errors as `ERROR` at the execution boundary.
- [ ] Return per-action trace entries and preserve old `ActionExecutionResult` fields.
- [ ] Run focused and existing engine tests.

### Task 3: Rule execution status and quantified subjects

**Files:**
- Modify: `lib/domain/rules/engine/stage_iteration_runner.dart`
- Modify: `lib/domain/rules/engine/stage_runner.dart`
- Modify: `lib/domain/rules/engine/analysis_stage_executor.dart`
- Modify: `lib/domain/rules/engine/rule_engine.dart`
- Test: `test/domain/rules/engine/scoped_runtime_test.dart`

- [ ] Add failing tests for matched/not-matched/skipped/error rule entries and two matched child lines producing two action subjects.
- [ ] Verify red.
- [ ] Thread trace entries through stage execution and execute actions once per matched binding context.
- [ ] Ensure empty action output still reports condition/action status and stage convergence remains unchanged.
- [ ] Verify green and run the complete rules suite.

### Task 4: Codec and DSL round trips

**Files:**
- Modify: `lib/domain/rules/editor/rule_expr_codec.dart`
- Modify: `lib/domain/rules/dsl/condition_formatter.dart`
- Modify: `lib/domain/rules/dsl/condition_parser.dart`
- Test: `test/domain/rules/engine/trace_round_trip_test.dart`

- [ ] Add failing round-trip tests for generic line scope/quantified expressions and all existing logic nodes.
- [ ] Implement additive codec/formatter/parser support without changing old node shapes.
- [ ] Verify JSON → AST → JSON and DSL → AST semantic equality.

### Task 5: Rule editor test mode and review summary

**Files:**
- Create: `lib/presentation/rules/rule_test_result_page.dart`
- Create: `lib/presentation/rules/widgets/rule_trace_tree.dart`
- Create: `lib/presentation/review/widgets/review_rule_run_card.dart`
- Modify: `lib/presentation/rules/rule_editor_page.dart`
- Modify: `lib/presentation/review/review_page.dart`
- Test: `test/presentation/rules/rule_test_result_page_test.dart`
- Test: `test/presentation/review/review_rule_run_card_test.dart`

- [ ] Add failing widget tests for test button, summary, tree, and review status filters.
- [ ] Implement a read-only test execution route using a snapshot and no persistence.
- [ ] Add compact review entry with drill-down trace.
- [ ] Verify existing presentation tests.

### Task 6: Acceptance corpus, docs, and release verification

**Files:**
- Create: `test/domain/rules/corpus/r5_rule_trace_corpus_test.dart`
- Modify: `file-tree.md`
- Modify: `CHANGELOG.md`
- Modify: `android/app/build.gradle`

- [ ] Add R1–R8 runtime tests using existing operators and generic scope.
- [ ] Run targeted rules tests, `flutter analyze`, full `flutter test`, and `flutter build apk --release`.
- [ ] Update file tree and changelog with current timestamp and version/build metadata.
- [ ] Commit with `feat:`/`fix:` prefixes and report the APK absolute path.
