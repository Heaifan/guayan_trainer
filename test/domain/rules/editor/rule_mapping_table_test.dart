import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_mapping_table.dart';

void main() {
  test('mapping table keeps stable values separate from display imagery', () {
    expect(RuleMappingTable.imageFor('sanHe.木'), contains('繁荣'));
    expect(RuleMappingTable.imageFor('element.金'), contains('决断'));
    expect(RuleMappingTable.imageFor('unknown.value'), isNull);
  });
}
