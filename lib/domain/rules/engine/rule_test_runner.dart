library;

import '../core/rule_definition.dart';
import '../facts/fact_snapshot.dart';
import '../facts/canonical_fact_snapshot_builder.dart';
import '../../hexagram_case.dart';
import 'engine_types.dart';
import 'rule_engine.dart';

/// Executes an editor RuleDefinition against an in-memory snapshot.
/// It intentionally has no Case/RuleRun or persistence dependency.
class RuleTestRunner {
  const RuleTestRunner();

  AnalysisRun run(RuleDefinition rule, FactSnapshot snapshot) {
    return RuleEngine().execute([rule], snapshot);
  }

  /// Runs against a read-only real Case using the canonical fact projection.
  AnalysisRun runCase(RuleDefinition rule, HexagramCase hexagramCase) {
    return run(rule, CanonicalFactSnapshotBuilder.build(hexagramCase));
  }
}
