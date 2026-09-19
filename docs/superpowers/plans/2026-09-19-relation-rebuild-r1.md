# GUAYAN-R5-RELATION-REBUILD-R1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the review-page relation visualization with a four-type, obstacle-aware rounded orthogonal renderer while preserving Domain and the relation ledger.

**Architecture:** Keep `RelationResolutionResult` and `RelationRecord` as the semantic source. Add a review-only projection, geometry/obstacle/router/cache services, and a thin Flutter overlay that collects real RenderBox bounds after layout. Ordinary Sheng/Ke use the orthogonal router; HuiTouSheng/HuiTouKe use a local return glyph.

**Tech Stack:** Dart, Flutter `CustomPainter`, `RenderBox`, `Rect`/`Path`, Flutter tests, existing Domain relation models.

**Spec:** `docs/superpowers/specs/2026-09-19-relation-rebuild-r1-design.md`

## Global Constraints

- Only `RelationType.sheng`, `ke`, `huiTouSheng`, and `huiTouKe` reach the review renderer.
- Domain data, `EffectiveRelationSet`, relation page, Evidence, notes, and persistence remain intact.
- Every node exposes eight anchors derived from real layout bounds; no fixed endpoint selection.
- Every visible board element is a hard obstacle inflated by the centralized 5dp safe-padding token.
- No Bezier, giant C/U detour, fixed text-width estimate, or Widget-side wuxing calculation.
- Register every actually visible board element with a real RenderBox bound as a Hard Obstacle; when uncertain, register it rather than omit it.
- A router with no legal candidate returns `NoRoute` and draws nothing; it never falls back to an illegal or guessed path.
- Route and label processing uses stable Relation identity ordering; repeated calculation of the same input produces an identical `RelationRenderPlan`.
- Pure logic Dart files remain under 150 lines; oversized Widget pages are allowed by `AGENTS.md`.
- Update `file-tree.md` for every file addition/deletion/responsibility change.

## Review Focus

- Missing RenderBox during the first frame must produce no route, not guessed coordinates — test overlay geometry collection with incomplete keys in Task 5.
- Every visible board element, including all fushen/main/changed text, nayin, yao bodies, X/O, Shi/Ying and state text, must be registered as an obstacle — test complete bound registration in Task 5.
- No legal route must produce `NoRoute` and no drawing — test the hard failure in Task 3.
- A relation label must become an obstacle before the next relation is routed — test sequential label placement in Task 4.
- A same-position moving relation with no wuxing relation must not create a return glyph — test projection and glyph filtering in Task 1 and Task 3.
- Selection and repaint must not invoke routing again — test cache counters in Task 6.
- The relation ledger must still expose excluded relations and notes after review filtering — preserve the existing relation-page regression in Task 7.

### Task 1: Domain algorithm proof and review projection

**Files:**
- Modify: `test/domain/relation_back_relations_test.dart`
- Create: `test/domain/relation_wuxing_direction_test.dart`
- Create: `lib/presentation/review/review_relation_projection.dart`
- Create: `test/presentation/review/review_relation_projection_test.dart`

**Interfaces:**
- Consumes: `RelationResolutionResult.effectiveRelationSet`, `RelationResolutionEntry.relation`, `RelationType`, `YaoEndpoint`.
- Produces: `ReviewRelationKind { generates, overcomes, returnGenerates, returnOvercomes }`, `ReviewRelationProjection.project(Iterable<RelationResolutionEntry>)`, and `ReviewRelationProjection.fromRecords(Iterable<RelationRecord>)`.

- [ ] **Step 1: Write failing Domain tests** for all five wuxing generation pairs, all five overcoming pairs, and the controlled `YaoEndpoint(original, 3)` earth → `YaoEndpoint(original, 6)` water Golden Case. Assert candidate type, effective flag, source/target semantic IDs, and reason `EFFECTIVE`; add a same-position no-relation case that asserts no return type.
- [ ] **Step 2: Run the new tests** with `flutter test test/domain/relation_wuxing_direction_test.dart test/domain/relation_back_relations_test.dart`; confirm failure is in the missing Golden/proof expectation, not a test import error.
- [ ] **Step 3: Implement only the minimum test fixtures/assertion helpers** needed to expose existing Domain behavior; do not alter relation calculation semantics unless the new Golden Case proves an actual bug.
- [ ] **Step 4: Run the Domain tests again** and confirm all wuxing and return cases pass; if the Golden Case exposes a direction issue, add the smallest Domain regression fix and preserve candidate/effective reason.
- [ ] **Step 5: Write the projection test first** asserting excluded types (`dongBian`, flying, `liuHe`, `liuChong`, month/day) never appear and the four allowed types retain original IDs/evidence.
- [ ] **Step 6: Run projection test to see it fail**, then implement `ReviewRelationProjection` as a pure filter/mapper with no wuxing decisions.
- [ ] **Step 7: Run both Domain and projection tests** and commit `feat: prove review relation domain subset`.

### Task 2: Geometry, anchors, obstacles, and centralized visual tokens

**Files:**
- Create: `lib/presentation/review/relation_geometry.dart`
- Create: `lib/presentation/review/relation_obstacle_map.dart`
- Modify: `lib/presentation/review/relation_visual_tokens.dart`
- Create: `test/presentation/review/relation_geometry_test.dart`
- Create: `test/presentation/review/relation_obstacle_map_test.dart`

**Interfaces:**
- Consumes: real `Rect` values in overlay coordinates.
- Produces: `RelationAnchor`/`RelationAnchors` with NW/N/NE/W/E/SW/S/SE, `RelationObstacleMap`, `RelationObstacle`, `RelationVisualTokens.safePadding`, and collision APIs `isClearSegment`/`isClearPath`.

- [ ] **Step 1: Write failing geometry tests** for all eight anchors on a known Rect, top/bottom relative-direction candidate ordering, and preservation of source/target Rect identity.
- [ ] **Step 2: Run the geometry test and observe the expected missing-type failure.**
- [ ] **Step 3: Implement pure anchor derivation** from `Rect` centers and edges; expose direction filtering without selecting a final anchor.
- [ ] **Step 4: Run the geometry test and verify it passes.**
- [ ] **Step 5: Write failing obstacle tests** proving `inflate(5)` blocks text, nan-yin, Shi/Ying, yao glyphs, and a relation label; assert a segment touching the inflated edge is invalid.
- [ ] **Step 6: Run the obstacle test, implement `RelationObstacleMap` with immutable inflated bounds and segment/polyline collision, then rerun it green.**
- [ ] **Step 7: Update visual tokens** to 5dp safe padding, 2dp normal stroke, 9dp arrow scale, green/red colors, and labels 生/克/回生/回克; retain only token APIs still used by the relation ledger glyph.
- [ ] **Step 8: Run geometry, obstacle, and existing relation visual protocol tests; commit `feat: add review relation geometry obstacles`.**

### Task 3: Rounded orthogonal router and return glyph

**Files:**
- Delete: `lib/presentation/review/relation_route_layout.dart`
- Delete: `lib/presentation/review/relation_route_path.dart`
- Delete: `lib/presentation/review/back_relation_glyph.dart`
- Create: `lib/presentation/review/relation_orthogonal_router.dart`
- Create: `lib/presentation/review/return_relation_glyph.dart`
- Create: `test/presentation/review/relation_orthogonal_router_test.dart`
- Create: `test/presentation/review/return_relation_glyph_test.dart`
- Delete: `test/presentation/review/relation_route_layout_test.dart`
- Delete: `test/presentation/review/relation_route_path_test.dart`
- Replace: `test/presentation/review/back_relation_glyph_test.dart` with `return_relation_glyph_test.dart`

**Interfaces:**
- Consumes: `RelationAnchors`, `RelationObstacleMap`, source/target Anchor pairs, viewport Rect.
- Produces: `RelationRoute` with rounded `Path`, ordered `RouteSegment`s, selected anchors, bend count, length, and cost; `ReturnRelationGlyph.layout(...)` with path, arrow, label bounds and obstacle validity.

- [ ] **Step 1: Write failing router tests** for the three-earth-to-six-water Golden Case, HV/VH candidate generation, obstacle rejection, endpoint preservation, no cubic segments, no giant C/U outer detour, and shortest legal route selection.
- [ ] **Step 2: Run router tests and confirm they fail because the new router is absent.**
- [ ] **Step 3: Implement candidate generation and rounded-corner path construction** for HV, VH, H-V-H and V-H-V; reject any candidate intersecting hard obstacles; score legal candidates using length, bends, crossings, detour, and anchor-direction penalties.
- [ ] **Step 4: Run router tests and verify the Golden Case reports source anchor, target anchor, obstacle count, bend count, and route length within assertions; verify all-illegal candidates return `NoRoute` and never draw.**
- [ ] **Step 5: Write failing return-glyph tests** for mirrored HuiTouSheng/HuiTouKe local hooks, labels, arrow direction, same row, obstacle bounds, and no long-distance route.
- [ ] **Step 6: Implement `ReturnRelationGlyph`** using local row geometry and obstacle checks; do not accept `dongBian` as a drawable type.
- [ ] **Step 7: Run router and glyph tests plus relation visual protocol tests; commit `feat: replace review routes with orthogonal geometry`.**

### Task 4: Label placement and debug geometry

**Files:**
- Create: `lib/presentation/review/relation_label_placer.dart`
- Create: `lib/presentation/review/relation_debug_painter.dart`
- Create: `test/presentation/review/relation_label_placer_test.dart`
- Create: `test/presentation/review/relation_debug_painter_test.dart`

**Interfaces:**
- Consumes: `RelationRoute`, `RelationObstacleMap`, relation type, previously placed label bounds.
- Produces: `PlacedRelationLabel` with exact `Rect`, center, text and route association; debug painter inputs for nodes, anchors, obstacles, selected anchors and segments.

- [ ] **Step 1: Write failing label tests** asserting actual measured `TextPainter` size plus padding, rejection against obstacles and prior labels, and acceptance of the first clear candidate near a route segment.
- [ ] **Step 2: Run the label tests and observe the missing implementation failure.**
- [ ] **Step 3: Implement candidate generation around legal segments, use `TextPainter.layout()` for width/height, inflate the result by safe padding, and return placed labels in deterministic order.
- [ ] **Step 4: Run label tests and verify they pass, including the review-focus sequential obstacle case.**
- [ ] **Step 5: Write a debug-mode test** proving debug output is present only when enabled and contains Node Bounds, 8 Anchors, Obstacle Bounds, selected anchors, route segments and label bounds.
- [ ] **Step 6: Implement the debug painter as a separate optional layer and run its test; commit `feat: add relation label placement and debug bounds`.**

### Task 5: Replace the审卦 overlay without UI-side relation logic

**Files:**
- Replace: `lib/presentation/review/widgets/relation_overlay.dart`
- Modify: `lib/presentation/review/review_page.dart`
- Modify: `lib/presentation/review/widgets/review_hexagram_result_table.dart`
- Modify: `lib/presentation/review/widgets/hexagram_line_cell.dart`
- Create: `test/presentation/review/relation_overlay_test.dart`

**Interfaces:**
- Consumes: review state records, real `GlobalKey` RenderBoxes for every visible text/symbol/state element, `ReviewRelationProjection`, router, label placer and glyph.
- Produces: a `RelationOverlay` whose `visibleRecords` preserves focus/category behavior but whose painter only receives the four projected relation types and real obstacle bounds.

- [ ] **Step 1: Write failing widget tests** with real keys for main/changed/hidden/nayin/yao/shi-ying nodes; assert excluded relations render no route, four allowed labels render, and a missing first-frame RenderBox renders no guessed route.
- [ ] **Step 2: Run the widget test and confirm the expected failure from the old overlay behavior/imports.**
- [ ] **Step 3: Add keys/Bounds registration to every actually visible board element** — fushen six-relative/branch/wuxing/nayin, main and changed six-relative/branch/wuxing/nayin, yin/yang yao body, X/O, Shi/Ying and every visible state/status label — and pass a unified `Map<String, GlobalKey>`/row map into the overlay; collect RenderBox bounds after layout in overlay coordinates. If a visible element has no relation, it is still registered as an obstacle.
- [ ] **Step 4: Implement the new overlay painter**: projection filter → obstacle map → anchors → route/glyph → label placement → debug layer. Keep relation taps and selection opacity-only.
- [ ] **Step 5: Run the widget tests and verify all visible board elements are treated as hard obstacles and no old route APIs remain.**
- [ ] **Step 6: Run review page tests and commit `feat: connect the rebuilt relation renderer to review`.**

### Task 6: Route cache and relation statistics

**Files:**
- Create: `lib/presentation/review/relation_route_cache.dart`
- Modify: `lib/presentation/review/review_relation_filter.dart`
- Modify: `lib/presentation/review/widgets/review_relation_toolbar.dart`
- Create: `test/presentation/review/relation_route_cache_test.dart`
- Modify: `test/presentation/review/relation_visual_protocol_test.dart`

**Interfaces:**
- Consumes: layout fingerprint, effective relation fingerprint, viewport/font/visibility state and projected relations.
- Produces: cached `RelationRenderPlan`; counters/test seam proving route calculation count.

- [ ] **Step 1: Write failing cache tests** for first calculation, cache hit on repaint, cache hit on selection, and invalidation on Bounds/effective-set/size/visibility changes.
- [ ] **Step 2: Run tests and observe the missing cache failure.**
- [ ] **Step 3: Implement immutable fingerprinted cache and route-plan storage; separate `shouldRepaint` selection changes from route-plan invalidation.**
- [ ] **Step 4: Run cache tests and verify repaint Route Calculation count remains zero on hits; calculate the same input repeatedly and assert byte-for-byte-equivalent route/label plans.**
- [ ] **Step 5: Simplify toolbar statistics** to `全部 N / 生克 N / 特殊 N`, counting only the four renderer types and leaving other Domain records available to the relation page.
- [ ] **Step 6: Run cache, toolbar, review-page and relation-page tests; commit `perf: cache review relation routes`.**

### Task 7: Documentation, full regression, APK, and delivery report

**Files:**
- Modify: `file-tree.md`
- Modify: `CHANGELOG.md`
- Modify: `android/app/build.gradle` only if release versioning requires it
- Create: `docs/reports/2026-09-19-guayan-r5-relation-rebuild-r1.md`

- [ ] **Step 1: Update `file-tree.md`** with all new/deleted files, responsibilities, version/update log and current system time.
- [ ] **Step 2: Write the completion report** with old deletion list, relation-page regression result, Domain Candidate/Effective/Reason for 三爻土 → 六爻水, Golden Route anchors/obstacles/bends/length, four relation test evidence, obstacle count, projected relation count, initial render-plan calculation duration, cache hit count, selection-triggered route calculation count (0), verification commands and git state.
- [ ] **Step 3: Run `flutter analyze`, all targeted Domain/geometry/router/review/relation-page tests, and `flutter test`; read exit codes and failures.**
- [ ] **Step 4: Run `git diff --check` and `flutter build apk --release`; record exact outputs in the report.
- [ ] **Step 5: Commit `feat: rebuild review relation renderer r1` only after all gates pass; inspect `git status`, `git log`, remote and ahead/behind.
- [ ] **Step 6: Push only after confirming the target remote/branch and report the exact commit and remote state.**
