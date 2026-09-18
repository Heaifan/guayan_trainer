# Relation Semantics and Router 2.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Correct relation semantics and make focused review overlays readable without dimming valid relation colors.

**Architecture:** Keep the domain ledger as the semantic source of truth, add explicit diagnostics for the current Case, and move route geometry into a pure presentation layout model. The painter consumes deterministic lanes and draws original colors at full opacity, with focus represented by stroke and endpoint emphasis.

**Tech Stack:** Dart, Flutter CustomPainter, flutter_test, pure domain/presentation value objects.

**Spec:** Approved in chat on 2026-09-18 from the “关系语义审计 + Relationship Router 2.0” requirements.

## Global Constraints

- Pure logic Dart files remain under 150 lines; split new logic by responsibility.
- Domain must not depend on Flutter; presentation may depend on domain.
- Relation facts and route geometry must be deterministic and testable.
- Existing relation filters and stable RelationKey identities must remain compatible.
- `file-tree.md` must be updated for added files and final edit time.

---

### Task 1: Reproduce and lock relation semantics

**Files:**
- Create: `test/domain/relation_semantics_regression_test.dart`
- Modify: `lib/domain/relation_rules/month_day.dart` only if the regression identifies a generation defect.

**Interfaces:**
- Consume `calculateRelationResult` and the existing Case fixture.
- Produce assertions that same-element/same-branch ruler facts never become `sheng` or `ke`, while legitimate month/day effects retain their source rule ids.

- [ ] Write the failing Case regression first.
- [ ] Run the focused test and confirm it fails for the semantic reason.
- [ ] Trace whether the bad type originates in generation, projection, or presentation mapping.
- [ ] Apply the smallest domain fix and rerun the focused test.

### Task 2: Add a pure deterministic relationship router

**Files:**
- Create: `lib/presentation/review/relation_route_layout.dart`
- Create: `test/presentation/review/relation_route_layout_test.dart`

**Interfaces:**
- `RelationRouteLayout.layout(records, bounds, obstacles)` returns deterministic route assignments, lane offsets, and branch metadata.
- The overlay remains responsible only for anchor lookup and painting.

- [ ] Write tests for grouped lanes, same-source trunk/fan-out, stable ordering, and obstacle clearance.
- [ ] Run the focused tests and confirm they fail before implementation.
- [ ] Implement the smallest pure layout model.
- [ ] Run focused tests and refactor only after green.

### Task 3: Integrate full-color focus-aware overlay rendering

**Files:**
- Modify: `lib/presentation/review/relation_visual_tokens.dart`
- Modify: `lib/presentation/review/widgets/relation_overlay.dart`
- Modify: `test/presentation/review/relation_visual_protocol_test.dart`

**Interfaces:**
- Default relation stroke opacity is 1.0.
- Focus uses stroke width, endpoint radius, and endpoint color rather than dimming every other relation.
- Existing category filtering and state exclusion remain unchanged.

- [ ] Add failing visual token and route integration assertions.
- [ ] Run the focused tests and confirm the expected failures.
- [ ] Integrate the pure router and preserve current arrow direction/filter semantics.
- [ ] Run focused presentation tests.

### Task 4: Update project tree and verify the complete change

**Files:**
- Modify: `file-tree.md`

- [ ] Run domain and presentation focused tests.
- [ ] Run the full `flutter test` suite and `flutter analyze`.
- [ ] Update the project tree, module responsibility, and last edited time.
- [ ] Review the diff against all ten acceptance criteria.

