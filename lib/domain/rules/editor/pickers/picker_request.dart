library;

import '../../templates/rule_slot_definition.dart';

class PickerRequest {
  const PickerRequest({
    required this.slotId,
    required this.slotType,
    this.catalogId,
    this.currentValue,
    this.allowedValues,
  });

  final String slotId;
  final RuleSlotType slotType;
  final String? catalogId;
  final Object? currentValue;
  final List<String>? allowedValues;
}
