# G2-R3 JSON Rule Package Import Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with verification checkpoints.

**Goal:** Implement atomic Portable JSON USER RulePack import/export, persisted global activation, future-cast integration, and historical Case isolation.

**Architecture:** Add one exchange-envelope model around the existing RuleDefinition/PortableRuleCodec. Validate the complete graph before committing package content and registry metadata. Keep installed package content and enabled state in SharedPreferences, then let the casting assembler consume only enabled USER packs for newly created RuleRuns.

**Tech Stack:** Dart, Flutter, SharedPreferences, existing RuleDefinition/RulePack/RuleResolver/PortableRuleCodec, Flutter file chooser abstraction.

**Spec:** `docs/superpowers/specs/2026-09-18-rule-package-import-design.md`

## Global Constraints

- Do not change SYSTEM ExecutionRule count, canonical IDs, AST, DSL, Operator, Quantifier, or Structure contracts.
- USER import must be atomic: validation failure leaves package stores and registry unchanged.
- Historical Cases and original RuleRuns remain unchanged until explicit recompute.
- Preserve all existing dirty worktree changes; never reset, clean, or stash them.
- Update `file-tree.md` for every created file and at completion.

---

### Task 1: Package envelope and validation

**Files:**
- Create: `lib/domain/rules/packages/portable_rule_package.dart`
- Create: `lib/domain/rules/packages/rule_package_error.dart`
- Create: `lib/domain/rules/packages/rule_package_validator.dart`
- Test: `test/domain/rules/packages/rule_package_validator_test.dart`

**Interfaces:**
- `PortableRulePackage.fromJson(Map<String,Object?>)` and `.toJson()`.
- `RulePackageValidator.validate(PortableRulePackage, {required Iterable<RuleDefinition> existingRules, required Iterable<RulePack> installedPacks, ...})` returns structured validation issues without writing state.

- [ ] Add failing tests for valid package, malformed JSON, unknown schema, future schema, unknown operator, missing Mapping/Custom ShenSha, SYSTEM-origin/ID override, and same-version conflict.
- [ ] Run the package validator test and confirm the missing model/validator failures.
- [ ] Implement immutable envelope decoding using existing codecs and dependency-reference extraction.
- [ ] Implement structured user-facing error codes and detailed developer diagnostics.
- [ ] Run the targeted validator tests.

### Task 2: Atomic persistence and global registry

**Files:**
- Create: `lib/domain/rules/packages/rule_package_store.dart`
- Create: `lib/domain/rules/packages/global_rule_pack_registry.dart`
- Test: `test/domain/rules/packages/rule_package_store_test.dart`

**Interfaces:**
- `RulePackageStore.loadInstalled()` / `saveInstalled()` / `remove()`.
- `GlobalRulePackRegistry.load()` / `setEnabled(packId, enabled)` / `register()` / `unregister()`.
- `RulePackageImporter.install()` commits both stores or neither.

- [ ] Add tests for restart persistence, default enabled, disable/re-enable, delete protection, and rollback after a late commit failure.
- [ ] Implement versioned SharedPreferences JSON storage with one package record containing content, metadata, and registry state.
- [ ] Implement importer transaction by preparing the complete next state, then performing one persistence commit; preserve old state on validation failure.
- [ ] Run store/importer tests.

### Task 3: Runtime and historical Case integration

**Files:**
- Modify: `lib/domain/rules/engine/runtime_rule_set_assembler.dart`
- Modify: `lib/services/cases/generated_case_recorder.dart`
- Modify: `lib/services/cases/case_recompute_service.dart`
- Modify: `lib/domain/cases/rule_run.dart`
- Test: `test/services/cases/rule_package_activation_test.dart`

**Interfaces:**
- New-cast assembly consumes `GlobalRulePackRegistry.enabledUserPacks`.
- `RuleRun` stores immutable pack references and versions already selected for that run.

- [ ] Add tests for enabled USER inclusion, disabled exclusion, restart retention, historical isolation, and explicit recompute with the new package.
- [ ] Extend assembly with enabled USER packages while preserving SYSTEM-first resolution and conflict rules.
- [ ] Freeze selected pack metadata into new RuleRun creation; never mutate existing Case snapshots.
- [ ] Run activation and historical tests.

### Task 4: External golden package and semantic round-trips

**Files:**
- Create: `test/fixtures/external_test_pack.json`
- Create: `test/domain/rules/packages/rule_package_round_trip_test.dart`
- Modify: existing package codec only if required by failing tests.

- [ ] Encode rules covering DynamicBinding, QuantifiedExpr, Structure, Mapping, and Custom ShenSha in the fixture.
- [ ] Test export → import → install → enable → restart → runtime evaluation.
- [ ] Assert AST equality, Portable JSON equality, DSL round-trip equality, Mapping equality, and Custom ShenSha equality.
- [ ] Run the complete package round-trip test.

### Task 5: Rule library UI and file adapter

**Files:**
- Modify: `lib/presentation/rules/rule_library_page.dart`
- Create: `lib/presentation/rules/widgets/rule_package_import_dialog.dart`
- Create: `lib/presentation/rules/widgets/rule_package_card.dart`
- Create: `lib/services/rules/rule_package_file_adapter.dart`
- Modify: `pubspec.yaml` only if an existing supported file-picker abstraction is absent.
- Test: `test/presentation/rules/rule_package_page_test.dart`

- [ ] Add widget tests for 导入 JSON, preview counts, validation errors, 导入后全局启用, enable/disable, export, and delete.
- [ ] Implement a narrow file adapter with injectable read/write callbacks so widget tests do not depend on platform channels.
- [ ] Add package preview and human-readable errors; keep technical diagnostics behind an expandable detail section.
- [ ] Add package list actions and use the importer/store interfaces rather than embedding persistence in widgets.
- [ ] Run UI tests at mobile dimensions.

### Task 6: Full final gate

**Files:**
- Modify: `file-tree.md`
- Test: existing full suite plus package suites.

- [ ] Run targeted package, activation, historical, UI, Golden, knowledge-catalog, and codec tests.
- [ ] Run `flutter test` and record the exact total.
- [ ] Run `flutter analyze` and require 0 issues.
- [ ] Run `git diff --check`.
- [ ] Re-run SYSTEM 60/orphan 0/canonical ID checks.
- [ ] Review the diff for forbidden AST/DSL/Operator changes and report the final R3 gate without building an APK unless separately requested.
