import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_definition_codec.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/objects/dynamic_object_resolver.dart';

FactRecord fact(String id, String line, String predicate, String value) =>
    FactRecord(
      factId: id,
      subject: SemanticRef('line', line),
      predicateId: predicate,
      value: RuleValue.string(value),
      origin: FactOrigin.baseRelation,
    );

FactSnapshot snapshot() => FactSnapshot.build([
  fact('spirit-2', '2', 'spirit', 'spirit.xuan_wu'),
  fact('branch-3', '3', 'branch', '卯'),
  fact('branch-5', '5', 'branch', '戌'),
  fact('movement-2', '2', 'movement', 'moving'),
  fact('movement-5', '5', 'movement', 'moving'),
  fact('shi-4', '4', 'shi_ying', 'shi'),
  fact('ying-1', '1', 'shi_ying', 'ying'),
]);

RuleDefinition definition(BindingSelector selector) => RuleDefinition(
  ruleId: const RuleId('dynamic_test'),
  version: RuleVersion('1.0.0'),
  origin: RuleOrigin.CUSTOM,
  namespace: 'common',
  categoryId: 'common',
  stage: RuleStage.tag,
  title: 'dynamic',
  description: '',
  provenance: 'test',
  bindings: [RuleBinding(name: 'A', selector: selector)],
  condition: const AllExpr([]),
  actions: const [],
);

void main() {
  test('spirit, shi and ying resolve to one line', () {
    final resolver = const DynamicObjectResolver();
    expect(
      resolver.resolveSingle(
        const DynamicBindingSelector(
          selectorId: 'dynamic.line.by_spirit',
          parameters: {'spirit': 'spirit.xuan_wu'},
        ),
        snapshot(),
      ),
      const SemanticRef('line', '2'),
    );
    expect(
      resolver.resolveSingle(
        const DynamicBindingSelector(selectorId: 'dynamic.line.shi'),
        snapshot(),
      ),
      const SemanticRef('line', '4'),
    );
    expect(
      resolver.resolveSingle(
        const DynamicBindingSelector(selectorId: 'dynamic.line.ying'),
        snapshot(),
      ),
      const SemanticRef('line', '1'),
    );
  });

  test('many selectors return candidates and never choose implicitly', () {
    final resolver = const DynamicObjectResolver();
    final moving = resolver.resolve(
      const DynamicBindingSelector(selectorId: 'dynamic.line.moving'),
      snapshot(),
    );
    expect(moving.candidates, [
      const SemanticRef('line', '2'),
      const SemanticRef('line', '5'),
    ]);
    expect(
      () => resolver.resolveSingle(
        const DynamicBindingSelector(selectorId: 'dynamic.line.moving'),
        snapshot(),
      ),
      throwsStateError,
    );
  });

  test('branch relation selector resolves matching candidates', () {
    final result = const DynamicObjectResolver().resolve(
      const DynamicBindingSelector(
        selectorId: 'dynamic.line.by_branch_relation',
        parameters: {'referenceObject': 'line/3', 'relation': 'combines'},
      ),
      snapshot(),
    );
    expect(result.candidates, [const SemanticRef('line', '5')]);
  });

  test(
    'dynamic binding codec preserves selector and old selectors remain readable',
    () {
      final dynamic = definition(
        const DynamicBindingSelector(
          selectorId: 'dynamic.line.by_spirit',
          parameters: {'spirit': 'spirit.xuan_wu'},
        ),
      );
      final restored = RuleDefinitionCodec.fromJson(
        RuleDefinitionCodec.toJson(dynamic),
      );
      final selector =
          restored.bindings.single.selector as DynamicBindingSelector;
      expect(selector.selectorId, 'dynamic.line.by_spirit');
      expect(selector.parameters['spirit'], 'spirit.xuan_wu');

      final old = RuleDefinitionCodec.fromJson({
        ...RuleDefinitionCodec.toJson(dynamic),
        'bindings': [
          {'name': 'A', 'type': 'dir', 'target': 'line/2'},
        ],
      });
      expect((old.bindings.single.selector as DirectSelector).target, 'line/2');
    },
  );
}
