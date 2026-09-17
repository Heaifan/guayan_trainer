import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/editor/pickers/picker_catalog.dart';
import 'package:guayan_trainer/domain/rules/editor/pickers/picker_request.dart';
import 'package:guayan_trainer/domain/rules/editor/pickers/picker_router.dart';
import 'package:guayan_trainer/domain/rules/templates/rule_slot_definition.dart';

void main() {
  List<PickerOption> value(String catalogId) => PickerRouter.optionsFor(
    PickerRequest(
      slotId: 'value',
      slotType: RuleSlotType.value,
      catalogId: catalogId,
    ),
  );

  test('value catalog routes to exact closed vocabulary', () {
    expect(value('stem'), hasLength(10));
    expect(value('branch'), hasLength(12));
    expect(value('element'), hasLength(5));
    expect(value('spirit'), hasLength(6));
    expect(value('kinship'), hasLength(5));
    expect(value('nayin'), hasLength(30));
  });

  test('property routes to matching value catalog request', () {
    expect(PickerRouter.requestForPredicate('branch_is').catalogId, 'branches');
    expect(
      PickerRouter.requestForPredicate('element_is').catalogId,
      'elements',
    );
    expect(
      PickerRouter.optionsFor(PickerRouter.requestForPredicate('branch_is')),
      hasLength(12),
    );
  });

  test('relation and state catalogs are closed and separated', () {
    expect(
      PickerRouter.optionsFor(
        const PickerRequest(
          slotId: 'relation',
          slotType: RuleSlotType.relation,
          catalogId: 'wuxing_relations',
        ),
      ).map((e) => e.displayText),
      ['生', '克'],
    );
    expect(
      PickerRouter.optionsFor(
        const PickerRequest(
          slotId: 'relation',
          slotType: RuleSlotType.relation,
          catalogId: 'branch_relations',
        ),
      ),
      hasLength(5),
    );
    expect(
      PickerRouter.optionsFor(
        const PickerRequest(slotId: 'state', slotType: RuleSlotType.state),
      ),
      hasLength(7),
    );
  });

  test('unknown catalog fails closed', () {
    expect(() => value('not_exists'), throwsArgumentError);
  });
}
