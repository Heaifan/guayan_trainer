import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/dsl/dsl_parser.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import '../rules/engine/rule_engine_test_fixture.dart';

void main() {
  test('R5-C2 FAST-TRACK: Engine Integration Smoke', () {
    final source = '''
取 A = @line/2
取 M = @month/M

若 A 六亲为parent
    且 M 生 A
则
    得 A state.parent_supported
'''.trim();

    final parsed = GuayanDslParser.parse(source);
    
    final ruleDef = RuleDefinition(
      ruleId: const RuleId('smoke_test'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM,
      namespace: 'smoke',
      categoryId: 'smoke',
      stage: RuleStage.derivedState,
      title: 'Smoke Test',
      description: 'Smoke test for C2',
      provenance: 'test',
      bindings: parsed.bindings,
      condition: parsed.condition!,
      actions: parsed.actions,
    );

    final engine = RuleEngine();
    final snapshot = createInitialSnapshot(); // from fixture
    
    final result = engine.execute([ruleDef], snapshot);
    
    expect(result.derivedFacts.length, 1);
    expect(result.derivedFacts.first.predicateId, 'derive');
    expect(result.derivedFacts.first.value.value, 'state.parent_supported');
    expect(result.derivedFacts.first.subject.kind, 'line');
    expect(result.derivedFacts.first.subject.key, '2');
  });
}
