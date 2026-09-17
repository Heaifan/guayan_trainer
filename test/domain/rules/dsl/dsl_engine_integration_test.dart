import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/dsl/guayan_dsl_parser.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';

void main() {
  test('Engine Integration Smoke Test', () {
    final dsl = """
取 A = @line/2
取 M = @calendar/month

若 A 六亲为父母
    且 M 生 A
则
    得 A state.parent_supported
""";

    final parser = GuayanDslParser();
    final result = parser.parse(dsl);
    expect(
      result.isSuccess,
      isTrue,
      reason: result.diagnostics.map((e) => e.message).join(', '),
    );
    final body = result.value!;

    final definition = RuleDefinition(
      ruleId: const RuleId('smoke'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.SYSTEM,
      namespace: 'test',
      categoryId: 'test',
      stage: RuleStage.derivedState,
      title: 'smoke',
      description: 'smoke',
      provenance: 'test',
      bindings: body.bindings,
      condition: body.condition,
      actions: body.actions,
    );

    final snapshot = FactSnapshot.build(
      [
        FactRecord(
          factId: '1',
          subject: const SemanticRef('line', '2'),
          predicateId: 'relative',
          value: RuleValue.string('relative.parent'),
          origin: FactOrigin.baseRelation,
        ),
      ],
      [
        RuntimeRelation(
          relationId: 'generate',
          subjects: const ['calendar/month', 'line/2'],
          evidenceId: 'e2',
        ),
      ],
    );

    final engine = RuleEngine();
    final output = engine.execute([definition], snapshot);

    expect(
      output.derivedFacts.any(
        (f) =>
            f.predicateId == 'derive' &&
            f.value.value == 'state.parent_supported' &&
            f.subject.kind == 'line' &&
            f.subject.key == '2',
      ),
      isTrue,
    );
  });
}
