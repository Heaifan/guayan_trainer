import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/editor/condition_catalog.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';

void main() {
  test('catalog exposes only unique runtime-backed conditions', () {
    final catalog = RuleConditionCatalog.all;
    expect(catalog, isNotEmpty);
    expect(catalog.map((item) => item.id).toSet(), hasLength(catalog.length));
    expect(catalog.every((item) => item.displayName.isNotEmpty), isTrue);
    expect(catalog.any((item) => item.id == 'xun_kong'), isTrue);
    expect(catalog.any((item) => item.id == 'nayin_is'), isTrue);
    expect(catalog.any((item) => item.id == 'chang_sheng'), isFalse);
    expect(catalog, hasLength(22));
    expect(catalog.any((item) => item.id == 'empty'), isFalse);
    expect(
      catalog.singleWhere((item) => item.id == 'in_tomb').displayName,
      '在库',
    );
    expect(
      catalog.map((item) => item.id),
      containsAll([
        'generate',
        'ru_mu',
        'chong_mu',
        'chu_mu',
        'has_tag',
        'stem_is',
        'branch_is',
        'element_is',
        'wuxing_overcomes',
        'branch_clashes',
        'branch_combines',
        'branch_punishes',
        'branch_harms',
        'branch_breaks',
      ]),
    );
  });

  test('catalog search returns only legal descriptors', () {
    final results = RuleConditionCatalog.search('旬空');
    expect(results.map((item) => item.id), contains('xun_kong'));
    expect(results.every((item) => item.displayName.contains('旬空')), isTrue);
  });

  test('every visible condition has a registered evaluator', () {
    final registry = OperatorRegistry();
    expect(RuleConditionCatalog.all.every((item) => registry.getOperator(item.runtimeOperator) != null), isTrue);
  });
}
