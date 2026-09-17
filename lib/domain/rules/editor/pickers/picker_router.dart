library;

import '../../templates/rule_slot_definition.dart';
import '../pickers/picker_catalog.dart';
import 'picker_request.dart';
import 'picker_result.dart';

class PickerRouter {
  const PickerRouter._();

  static List<PickerOption> optionsFor(PickerRequest request) {
    final options = switch (request.slotType) {
      RuleSlotType.object =>
        request.catalogId == 'dynamic_objects'
            ? PickerCatalog.dynamicObjects()
            : request.catalogId == 'object_choices'
            ? PickerCatalog.objectChoices()
            : PickerCatalog.objects(),
      RuleSlotType.property =>
        request.catalogId == 'condition_kinds'
            ? PickerCatalog.conditionKinds()
            : PickerCatalog.properties(),
      RuleSlotType.value =>
        request.catalogId == 'dynamic.line.by_spirit'
            ? PickerCatalog.dynamicParameters(request.catalogId!)
            : PickerCatalog.values(_required(request.catalogId)),
      RuleSlotType.state => PickerCatalog.states(),
      RuleSlotType.relation => PickerCatalog.relations(
        _required(request.catalogId),
      ),
    };
    final allowed = request.allowedValues;
    if (allowed == null) return options;
    return options.where((option) => allowed.contains(option.value)).toList();
  }

  static PickerRequest requestForPredicate(String operatorId) {
    const values = {
      'relative': 'six_relatives',
      'spirit': 'six_spirits',
      'nayin_is': 'nayin',
      'stem_is': 'stems',
      'branch_is': 'branches',
      'element_is': 'elements',
    };
    final catalogId = values[operatorId];
    if (catalogId == null) {
      throw ArgumentError('条件没有值目录: $operatorId');
    }
    return PickerRequest(
      slotId: 'value',
      slotType: RuleSlotType.value,
      catalogId: catalogId,
    );
  }

  static PickerResult resultFor(PickerOption option) =>
      PickerResult(value: option.value, displayText: option.displayText);

  static String _required(String? value) {
    if (value == null || value.isEmpty) {
      throw ArgumentError('Picker 缺少 catalogId');
    }
    return value;
  }
}
