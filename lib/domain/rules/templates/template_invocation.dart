library;

import 'rule_slot_definition.dart';
import 'template_definition.dart';

class TemplateInvocation {
  const TemplateInvocation({required this.template, required this.values});

  final TemplateDefinition template;
  final Map<String, TemplateSlotValue> values;

  TemplateSlotValue? operator [](String slotId) => values[slotId];
}
