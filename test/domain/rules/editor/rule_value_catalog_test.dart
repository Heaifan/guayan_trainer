import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_value_catalog.dart';

void main() {
  test('value catalog exposes complete closed vocabularies', () {
    expect(RuleValueCatalog.sixSpirits, hasLength(6));
    expect(RuleValueCatalog.sixRelatives, hasLength(5));
    expect(RuleValueCatalog.naYin, hasLength(30));
    expect(RuleValueCatalog.display('nayin.hai_zhong_jin'), '海中金');
    expect(RuleValueCatalog.display('relative.brother'), '兄弟');
    expect(RuleValueCatalog.display('relative.sibling'), '兄弟');
  });
}
