# G2-R4 Rule Folder Tree Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将用户规则包与自定义规则升级为可持久化的多级文件夹树，并让文件夹继承开关参与新规则运行时。

**Architecture:** 新增独立的 `RuleFolder` 与 `RuleLibraryIndex` 持久化层，索引只保存文件夹和 `ruleId -> folderId`，不复制 `RuleDefinition.enabled`。规则包注册表和 Runtime assembler 通过一个纯函数计算有效规则；现有 AST、DSL、RuleId、Version 与历史 RuleRun 不变。

**Tech Stack:** Flutter/Dart、SharedPreferences、现有 RuleDefinitionCodec/RulePackageStore、Flutter widget tests。

**Spec:** `docs/superpowers/specs/2026-09-18-rule-folder-tree-design.md`

## Global Constraints

- `RuleDefinition.enabled` 是单条规则开关唯一真相源。
- 保留文件夹使用稳定 ID；“未分类”不可删除，“导入规则”可改名但不可换 ID。
- 文件夹规则数必须递归包含所有后代规则。
- 每个 CUSTOM Rule 必须且只能归属一个有效 folderId；悬空归属自动回落“未分类”。
- 文件夹元数据不得写入 RuleDefinition、PredicateExpr、DSL 或 AST。
- 文件夹开关不得改写规则自身 enabled，不影响历史 Case/RuleRun。
- 不修改既有 Portable JSON schema。

---

### Task 1: Folder domain model and index invariants

**Files:**
- Create: `lib/domain/rules/library/rule_folder.dart`
- Create: `lib/domain/rules/library/rule_library_index.dart`
- Create: `test/domain/rules/library/rule_library_index_test.dart`

**Interfaces:**
- `RuleFolder({folderId, name, parentFolderId, enabled, sortOrder, reservedKind})`
- `RuleLibraryIndex({folders, ruleFolderIds, expandedFolderIds, schemaVersion})`
- `RuleLibraryIndex.effectiveEnabled(String ruleId, {required bool ruleEnabled})`
- `RuleLibraryIndex.recursiveRuleCount(String folderId)`
- `RuleLibraryIndex.moveFolder(String folderId, String? newParentFolderId)`

- [ ] Write failing tests for stable reserved IDs, JSON round-trip, recursive counts, one valid folder per custom rule, and cycle rejection.
- [ ] Run `flutter test test/domain/rules/library/rule_library_index_test.dart --reporter compact`; confirm the new model/API failures are expected.
- [ ] Implement immutable folder/index serialization and tree validation. Use reserved IDs `system:uncategorized` and `system:imported`; reject moving a folder into itself or a descendant.
- [ ] Implement recursive descendant traversal and `effectiveEnabled` using ancestor folders only; read the passed `ruleEnabled` value without storing it.
- [ ] Rerun the focused test until green.

### Task 2: Persistence, migration, and CRUD service

**Files:**
- Create: `lib/domain/rules/library/rule_library_store.dart`
- Create: `lib/domain/rules/library/rule_library_service.dart`
- Create: `test/domain/rules/library/rule_library_store_test.dart`
- Modify: `lib/domain/rules/packages/rule_package_store.dart`

**Interfaces:**
- `RuleLibraryStore.load()` / `save(RuleLibraryIndex index)` using a versioned SharedPreferences key.
- `RuleLibraryService.ensureMigrated(Iterable<RuleDefinition> customRules)`.
- CRUD methods: `createFolder`, `renameFolder`, `deleteFolder`, `moveFolder`, `moveRule`, `setFolderEnabled`, `setExpanded`.

- [ ] Write failing tests for empty-store default tree, migration of old unindexed custom rules, dangling folder fallback, restart persistence, and safe non-empty deletion.
- [ ] Run the focused persistence test and confirm failures before implementation.
- [ ] Implement atomic JSON persistence. On load normalize missing/duplicate/dangling assignments into “未分类”; preserve reserved IDs and reject deleting “未分类”. For normal folder deletion move descendants and rules to the parent by default; expose an explicit destructive mode for content deletion.
- [ ] Make JSON package installation accept a target folder ID and update the index in the same user-visible operation while preserving the existing package JSON.
- [ ] Rerun persistence/migration tests until green.

### Task 3: Runtime effective rule assembly

**Files:**
- Create: `lib/domain/rules/library/effective_rule_selector.dart`
- Modify: `lib/domain/rules/engine/runtime_rule_set_assembler.dart`
- Modify: `lib/domain/rules/packages/global_rule_pack_registry.dart`
- Create: `test/domain/rules/library/effective_rule_selector_test.dart`

**Interfaces:**
- `selectEffectiveRules(Iterable<RuleDefinition> rules, RuleLibraryIndex index)` returns only rules where `rule.enabled` and all folder ancestors are enabled.

- [ ] Write failing tests proving folder OFF suppresses descendants without changing each rule’s `enabled`, reopening restores prior states, and moving folders recomputes membership.
- [ ] Run the focused runtime test and verify it fails before implementation.
- [ ] Implement selection as a pure function and use it when assembling USER rules. Keep SYSTEM rules outside folder indexing and preserve RulePackVersionRef behavior.
- [ ] Add a regression asserting a historical `RuleRun`/Case snapshot is unchanged when the current index changes.
- [ ] Rerun focused runtime tests until green.

### Task 4: Folder-aware package import and rule actions

**Files:**
- Modify: `lib/domain/rules/packages/rule_package_importer.dart`
- Modify: `lib/presentation/rules/rule_package_page.dart`
- Modify: `lib/presentation/rules/rule_library_page.dart`
- Create: `test/domain/rules/packages/rule_package_folder_target_test.dart`

- [ ] Write failing tests for import into a selected folder and root import into stable “导入规则”.
- [ ] Run the focused import test and confirm the target-folder failure.
- [ ] Pass the current folder ID through preview/confirm/install; do not alter Portable JSON fields. Preserve default global enabled behavior.
- [ ] Add rule move, duplicate, delete, enable/disable and export actions through the existing rule operation boundaries; ensure duplicate gets a new rule ID without changing the source.
- [ ] Rerun package tests and existing import smoke tests.

### Task 5: Tree UI and safe menus

**Files:**
- Create: `lib/presentation/rules/widgets/rule_folder_tree.dart`
- Create: `lib/presentation/rules/widgets/rule_folder_row.dart`
- Create: `lib/presentation/rules/widgets/rule_tree_action_sheet.dart`
- Modify: `lib/presentation/rules/rule_package_page.dart`
- Create: `test/presentation/rules/rule_folder_tree_test.dart`

- [ ] Write failing widget tests for nested expand/collapse, recursive counts, folder switch inheritance, rule switch independence, and menu labels.
- [ ] Run the widget test and confirm it fails because the tree is not wired.
- [ ] Implement compact mobile rows: folder arrow/name/count/switch, rule name/switch/menu. Keep create/rename/move/import/delete in the action sheet; disable delete for “未分类”.
- [ ] Implement non-empty delete confirmation with default “移动到上一级” and a second confirmation for deleting contents.
- [ ] Rerun widget tests and the existing package import smoke test.

### Task 6: Documentation and full verification

**Files:**
- Modify: `file-tree.md`
- Modify: relevant test fixtures only when required by verified compatibility behavior.

- [ ] Add G2-R4 files and responsibilities to `file-tree.md` and update its last-edited timestamp.
- [ ] Run `flutter test` with the complete repository suite.
- [ ] Run `flutter analyze` and `git diff --check`; resolve all failures without weakening assertions or skipping tests.
- [ ] Verify RuleId/Version/AST equality across move, migration, import, and duplicate flows.
- [ ] Build `flutter build apk --debug` only after all gates pass.
- [ ] Install the APK over ADB and manually verify create folder, child folder, move, import target, folder off/on, rule off preservation, restart persistence, and non-empty deletion safety.
