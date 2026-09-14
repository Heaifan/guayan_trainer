import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

void main() {
  group('BindingResolver', () {
    late BindingResolver resolver;
    late FactSnapshot snapshot;

    setUp(() {
      resolver = const BindingResolver();
      snapshot = FactSnapshot.build([
        FactRecord(
          factId: 'f1',
          subject: SemanticRef('line', '2'),
          predicateId: 'changedLine',
          value: RuleValue.string('changed_line/2'),
          origin: FactOrigin.baseRelation,
        ),
      ]);
    });

    test('DirectSelector passes', () {
      final bindings = [
        const RuleBinding(name: 'A', selector: DirectSelector('line/2')),
      ];
      final context = resolver.resolve(bindings, snapshot);
      expect(context.get('A'), SemanticRef('line', '2'));
    });

    test('RelativeSelector passes', () {
      final bindings = [
        const RuleBinding(name: 'A', selector: DirectSelector('line/2')),
        const RuleBinding(name: 'B', selector: RelativeSelector(baseBinding: 'A', path: 'changedLine')),
      ];
      final context = resolver.resolve(bindings, snapshot);
      expect(context.get('B'), SemanticRef('changed_line', '2'));
    });

    test('Forward Reference passes', () {
      final bindings = [
        const RuleBinding(name: 'B', selector: RelativeSelector(baseBinding: 'A', path: 'changedLine')),
        const RuleBinding(name: 'A', selector: DirectSelector('line/2')),
      ];
      final context = resolver.resolve(bindings, snapshot);
      expect(context.get('A'), SemanticRef('line', '2'));
      expect(context.get('B'), SemanticRef('changed_line', '2'));
    });

    test('Unknown Relative Path fails closed', () {
      final bindings = [
        const RuleBinding(name: 'A', selector: DirectSelector('line/2')),
        const RuleBinding(name: 'B', selector: RelativeSelector(baseBinding: 'A', path: 'unknownPath')),
      ];
      expect(() => resolver.resolve(bindings, snapshot), throwsA(isA<BindingResolutionException>()));
    });

    test('Relative Binding Cycle fails closed', () {
      final bindings = [
        const RuleBinding(name: 'A', selector: RelativeSelector(baseBinding: 'B', path: 'somePath')),
        const RuleBinding(name: 'B', selector: RelativeSelector(baseBinding: 'A', path: 'somePath')),
      ];
      expect(() => resolver.resolve(bindings, snapshot), throwsA(isA<BindingResolutionException>()));
    });
  });
}
