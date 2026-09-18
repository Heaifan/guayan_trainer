# GUAYAN R5 Rule Trace and Scoped Runtime Design

## Goal

Make every rule execution observable without changing existing rule semantics, then extend the existing quantified runtime so a matched line can be preserved as an action subject.

## Design

`PredicateEvaluator` keeps its existing boolean API for compatibility and gains a trace-producing sibling path. A trace is an immutable tree containing rule status, expression kind, binding resolutions, predicate expected/actual evidence, and action outcomes. Errors are represented explicitly and are never converted to `NOT_MATCHED`.

`RuleEngine.execute` continues to return the existing `AnalysisRun` fields and adds optional trace data. Rules skipped by enabled/stage/package selection are represented by the engine boundary that selected the rule; existing callers remain source-compatible through defaults.

Quantified evaluation returns matched binding contexts in addition to boolean support. The action executor consumes those contexts, so a quantified rule can emit one action per matched line. Existing non-quantified rules use the original single binding context and therefore preserve their output.

The first UI increment adds a test entry to the rule editor and a compact rule-run entry to review. The test path executes against a supplied or demo `FactSnapshot` and never writes Case or RuleRun storage.

## Compatibility

Old AST JSON (`predicate`, empty `all`/`any`, direct bindings), existing `RuleDefinition`, `RuleRun`, SYSTEM/CUSTOM rules, and evidence IDs remain readable. New trace fields are additive and omitted/defaulted when absent.

## Verification

Add unit tests for all trace node types, four statuses, action isolation, quantified matched subjects, JSON and DSL round trips, and the eight acceptance rules. Run targeted rules tests, `flutter analyze`, full `flutter test`, and an Android release build.
