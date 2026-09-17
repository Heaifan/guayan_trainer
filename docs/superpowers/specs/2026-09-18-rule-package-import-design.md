# G2-R3 JSON Rule Package Import Design

## Goal

Close the user-rule distribution loop: import a Portable JSON RulePack, validate all dependencies atomically, install it as a USER package enabled by default, persist that state across restart, apply it only to future casts, and export it back without semantic drift.

## Frozen boundaries

- SYSTEM rules remain exactly 60; their canonical IDs and payloads are immutable.
- Existing AST, DSL, Operator, Quantifier, Structure, Mapping, and Custom ShenSha formats are reused.
- A historical Case and its original RuleRun are immutable when a package is later imported, enabled, disabled, upgraded, or removed.
- A package is either fully installed or not installed at all.
- Same RuleId plus same version is rejected; USER data can never override SYSTEM data.
- A higher USER version is an explicit install/upgrade operation, never silent replacement.

## Portable package contract

The exchange envelope is:

```json
{
  "schema": "guayan.rulepack",
  "schemaVersion": 1,
  "pack": {"id": "user.example.pack", "name": "示例", "version": "1.0.0"},
  "rules": [],
  "mappings": [],
  "customShensha": []
}
```

`rules` are encoded by the existing RuleDefinition codec. Mapping and Custom ShenSha entries retain their canonical IDs and JSON representations. The validator checks every referenced dependency before any store write.

## Components

- `PortableRulePackage`: immutable package model and JSON codec.
- `RulePackageValidator`: schema/version, rule, dependency, conflict, and SYSTEM-protection validation.
- `RulePackageStore`: atomic persistence of installed USER packages and their content.
- `GlobalRulePackRegistry`: persisted enabled state and install metadata.
- `RulePackageImporter`: parse → validate → commit package + registry state as one operation.
- `RuntimeRuleSetAssembler`: include enabled USER packages for new casts while preserving historical snapshots.
- Rule library UI: import JSON, preview, enable/disable, export, inspect, delete, and human-readable errors.

## Historical behavior

The casting path resolves SYSTEM plus enabled USER packages and writes the resulting pack references into the newly created RuleRun. Existing Case records are never re-resolved by registry changes. Explicit recompute creates a new RuleRun using the user-selected current package set.

## Verification

Tests cover package codec, all validation failures, atomic rollback, persistence restart, activation toggles, new-cast inclusion, historical isolation, explicit recompute, export/import equality, DSL round-trip, and the external golden package containing DynamicBinding, QuantifiedExpr, Structure, Mapping, and Custom ShenSha.
