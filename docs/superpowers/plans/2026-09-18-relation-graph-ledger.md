# Relation Graph & Ledger Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the shared RelationRecord projection, compact relation ledger, review focus overlay, and manual relation authoring in R7-A → R7-B → R7-C order.

**Architecture:** Existing `RelationInstance`, chart facts, and Rule Runtime remain authoritative. A deterministic Domain projection creates `RelationRecord`; an independent annotation store reattaches user notes by stable id. Ledger and Review Overlay consume the same records and ids.

**Tech Stack:** Flutter/Dart, existing Material widgets, CustomPainter/gestures, package:flutter_test, existing RelationKey/RelationInstance/RelationNoteStore.

**Spec:** `docs/superpowers/specs/2026-09-18-relation-graph-ledger-design.md`

## Global Constraints

- Do not create a second relation engine; project existing facts and rule outputs only.
- Keep `RelationKind.relation` and `RelationKind.state` distinct in Domain.
- Use deterministic IDs for FACT/RULE; USER IDs are created once and persisted.
- Keep annotations separate from rebuildable records.
- Runtime capability matrix must report unsupported relations instead of fabricating them.
- `RelationVisualTokens` contains visual mappings only.
- Pure logic files stay at or below 150 lines; widgets may be larger but responsibilities remain single-purpose.
- Update `file-tree.md` for every added/changed file.

### Task 1: R7-A Domain records and deterministic projection

**Files:**
- Create: `lib/domain/relations/relation_record.dart`
- Create: `lib/domain/relations/relation_record_id.dart`
- Create: `lib/domain/relations/relation_projection.dart`
- Create: `lib/domain/relations/relation_capability.dart`
- Modify: `lib/domain/relation_instance.dart` only if an adapter accessor is required
- Test: `test/domain/relations/relation_record_test.dart`

**Interfaces:** `RelationRecord`, `RelationKind`, `RelationSourceKind`, structured refs, `RelationProjection.projectFacts(...)`, `RelationProjection.projectRelationInstances(...)`, and `RelationCapabilitySnapshot.fromRecords(...)`.

- [ ] Write tests for relation/state separation, participants-based involvement, stable projection ids, and capability output.
- [ ] Run `flutter test test/domain/relations/relation_record_test.dart`; confirm failure because the new types do not exist.
- [ ] Implement immutable records and deterministic canonical id generation from source/type/endpoints/context.
- [ ] Project existing `RelationInstance` without recalculating its semantics; represent unsupported types only in capability diagnostics.
- [ ] Run the focused test and confirm pass.
- [ ] Commit only new Domain files and tests with `feat(relation): add deterministic ledger records`.

### Task 2: R7-A Annotation persistence and query/filter service

**Files:**
- Create: `lib/services/relation_annotation_store.dart`
- Create: `lib/services/relation_ledger_query.dart`
- Test: `test/domain/relations/relation_ledger_query_test.dart`

**Interfaces:** `RelationAnnotation`, `RelationAnnotationStore.upsert`, `RelationAnnotationStore.annotationFor`, `RelationLedgerQuery.search`, and `RelationLedgerQuery.filter`.

- [ ] Write tests for note survival after reprojection, search over title/objects/rule output/labels/evidence/note, and AND behavior for kind/position/category/keyword.
- [ ] Run the focused test and confirm expected missing-symbol failures.
- [ ] Implement annotation storage keyed by case id and stable record id, with JSON round-trip.
- [ ] Implement pure query/filter matching; use `participants` for position matching.
- [ ] Run focused tests and confirm pass.
- [ ] Commit with `feat(relation): add annotation-aware ledger queries`.

### Task 3: R7-A compact Relation Ledger page

**Files:**
- Create: `lib/presentation/relation/relation_page.dart`
- Create: `lib/presentation/relation/widgets/relation_filter_bar.dart`
- Create: `lib/presentation/relation/widgets/relation_ledger_row.dart`
- Create: `lib/presentation/relation/widgets/relation_detail_sheet.dart`
- Modify: `lib/app/app_shell.dart`, `lib/app/navigation/main_tabs.dart`
- Test: `test/presentation/relation/relation_page_test.dart`

**Interfaces:** `RelationPage(records:, annotationStore:, onOpenReview:)` and callbacks carrying `record.id`.

- [ ] Write widget tests for compact rows, 文书 search, type/position/category AND filters, detail opening, and editable note persistence.
- [ ] Run focused tests and confirm failure before implementation.
- [ ] Replace the relation placeholder tab with the Ledger page and inject the latest case projection.
- [ ] Keep UI logic limited to selection/input state; delegate search/filter/save to query/store services.
- [ ] Run focused widget tests at 360px and 390px widths.
- [ ] Commit with `feat(relation): replace placeholder with relation ledger`.

### Task 4: R7-B visual tokens, state labels, and overlay painter

**Files:**
- Create: `lib/presentation/review/relation_visual_tokens.dart`
- Create: `lib/presentation/review/widgets/relation_overlay.dart`
- Create: `lib/presentation/review/widgets/relation_overlay_painter.dart`
- Create: `lib/presentation/review/widgets/relation_state_labels.dart`
- Test: `test/presentation/review/relation_visual_protocol_test.dart`

**Interfaces:** `RelationVisualTokens.forType`, `RelationOverlay(records:, focusRef:, selectedId:, onRelationTap:, onClearFocus:)`.

- [ ] Write tests for exact colors/sizes/opacities, single vs double arrow direction, line styles, and no painter output for STATE.
- [ ] Run focused tests and confirm failure.
- [ ] Implement token-only visual mapping and CustomPainter paths with small markers and curved lanes.
- [ ] Implement compact state labels with overflow-safe vertical layout and preserve `□□` in line text.
- [ ] Run visual protocol tests and overflow checks at 360/390 widths.
- [ ] Commit with `feat(review): add compact relation overlay protocol`.

### Task 5: R7-B Review Focus and shared record navigation

**Files:**
- Modify: `lib/presentation/review/review_page_state.dart`
- Modify: `lib/presentation/review/review_case_adapter.dart`
- Modify: `lib/presentation/review/review_page.dart`
- Modify: `lib/presentation/review/widgets/review_hexagram_result_table.dart`
- Modify: `lib/app/app_shell.dart`
- Test: `test/presentation/review/relation_focus_test.dart`

**Interfaces:** state stores `List<RelationRecord>`, `focusedRelationRecords`, `focusRef`, and `selectedRelationId`; navigation passes the exact stable id.

- [ ] Write tests for tap/tap-again focus toggle, switching focus from 初爻 to 五爻, blank-board clear, all participants included, and Ledger-to-Review selected id.
- [ ] Run focused tests and confirm failure.
- [ ] Adapt current calculated relations into records and feed both Ledger and Overlay from one projection.
- [ ] Add Stack overlay and hit testing without embedding arrows into individual line widgets.
- [ ] Run review tests plus existing review suite.
- [ ] Commit with `feat(review): add shared relation focus navigation`.

### Task 6: R7-C manual relation authoring

**Files:**
- Create: `lib/services/manual_relation_store.dart`
- Create: `lib/presentation/relation/widgets/manual_relation_flow.dart`
- Modify: `lib/presentation/relation/relation_page.dart`
- Modify: `lib/presentation/review/review_page.dart`
- Test: `test/presentation/relation/manual_relation_test.dart`

**Interfaces:** `ManualRelationDraft`, `ManualRelationStore.create`, and structured endpoint selection for YAO/CHANGED/MONTH/DAY.

- [ ] Write tests for the five-step flow and resulting `sourceKind=USER`, stable persisted id, structured endpoints, and note searchability.
- [ ] Run focused tests and confirm failure.
- [ ] Implement the smallest modal flow with validation for distinct start/endpoints and non-empty relation type.
- [ ] Merge USER records into the same case ledger and review overlay source.
- [ ] Run focused tests and confirm pass.
- [ ] Commit with `feat(relation): add manual relation authoring`.

### Task 7: capability report, documentation, and full verification

**Files:**
- Modify: `file-tree.md`
- Create: `test/domain/relations/relation_capability_report_test.dart`

- [ ] Run the capability matrix against the real demo/fixture and record supported/unsupported runtime types without adding fake runtime records.
- [ ] Run `flutter analyze`.
- [ ] Run all relation-focused tests.
- [ ] Run `flutter test`.
- [ ] Run `git diff --check`.
- [ ] Review modified-file scope and report branch, Before HEAD, Final HEAD, Remote HEAD, ahead/behind, workspace, record counts by kind/source, and verification results.
- [ ] Do not begin unrelated G2/R8 work.
