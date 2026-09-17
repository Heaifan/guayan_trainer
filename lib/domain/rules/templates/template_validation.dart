library;

import 'rule_slot_definition.dart';
import 'template_invocation.dart';

class TemplateValidation {
  const TemplateValidation._();

  static List<String> validate(TemplateInvocation invocation) {
    final errors = <String>[];
    for (final slot in invocation.template.slots) {
      final value = invocation[slot.id];
      if (value == null) {
        errors.add('缺少 Slot: ${slot.id}');
        continue;
      }
      if (!_matches(slot.type, value)) {
        errors.add('Slot 类型错误: ${slot.id}');
      }
      if (slot.fixedValue != null && _text(value) != slot.fixedValue) {
        errors.add('Slot 固定值错误: ${slot.id}');
      }
    }
    final property = invocation['property'];
    final value = invocation['value'];
    if (property is PropertySlotValue && value is ValueSlotValue) {
      final expected = _catalogFor(property.propertyId);
      if (expected == null || value.catalogId != expected) {
        errors.add('属性和值目录不匹配');
      }
    }
    return errors;
  }

  static bool _matches(RuleSlotType type, TemplateSlotValue value) =>
      switch (type) {
        RuleSlotType.object => value is ObjectSlotValue,
        RuleSlotType.property => value is PropertySlotValue,
        RuleSlotType.value => value is ValueSlotValue,
        RuleSlotType.state => value is StateSlotValue,
        RuleSlotType.relation => value is RelationSlotValue,
      };

  static String? _catalogFor(String property) => const {
    'stem': 'stems',
    'branch': 'branches',
    'element': 'elements',
    'spirit': 'six_spirits',
    'relative': 'six_relatives',
    'nayin': 'nayin',
  }[property];

  static String? _text(TemplateSlotValue value) => switch (value) {
    PropertySlotValue v => v.propertyId,
    StateSlotValue v => v.stateId,
    RelationSlotValue v => v.relationId,
    _ => null,
  };
}
