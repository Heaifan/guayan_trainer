library;

enum RuleSlotType { object, property, value, state, relation }

class RuleSlotDefinition {
  const RuleSlotDefinition({
    required this.id,
    required this.type,
    this.editable = true,
    this.fixedValue,
    this.catalogId,
    this.projection,
  });

  final String id;
  final RuleSlotType type;
  final bool editable;
  final String? fixedValue;
  final String? catalogId;
  final String? projection;
}

abstract class TemplateSlotValue {
  const TemplateSlotValue();
}

class ObjectSlotValue extends TemplateSlotValue {
  const ObjectSlotValue(this.bindingName);
  final String bindingName;
}

class PropertySlotValue extends TemplateSlotValue {
  const PropertySlotValue(this.propertyId);
  final String propertyId;
}

class ValueSlotValue extends TemplateSlotValue {
  const ValueSlotValue({required this.catalogId, required this.value});
  final String catalogId;
  final Object value;
}

class StateSlotValue extends TemplateSlotValue {
  const StateSlotValue(this.stateId);
  final String stateId;
}

class RelationSlotValue extends TemplateSlotValue {
  const RelationSlotValue(this.relationId);
  final String relationId;
}
