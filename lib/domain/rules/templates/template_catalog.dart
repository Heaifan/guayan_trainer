library;

import 'rule_slot_definition.dart';
import 'template_definition.dart';

class TemplateCatalog {
  static const propertyEquals = TemplateDefinition(
    id: 'template.property.equals',
    displayName: '属性为',
    category: RuleTemplateCategory.property,
    operatorId: null,
    previewPattern: '[对象] [属性] 为 [值]',
    dslPattern: '[对象][属性]为[值]',
    slots: [
      RuleSlotDefinition(id: 'object', type: RuleSlotType.object),
      RuleSlotDefinition(id: 'property', type: RuleSlotType.property),
      RuleSlotDefinition(id: 'value', type: RuleSlotType.value),
    ],
  );

  static const stateHas = TemplateDefinition(
    id: 'template.state.has',
    displayName: '具有状态',
    category: RuleTemplateCategory.state,
    operatorId: null,
    previewPattern: '[对象] [状态]',
    dslPattern: '[对象][状态]',
    slots: [
      RuleSlotDefinition(id: 'object', type: RuleSlotType.object),
      RuleSlotDefinition(id: 'state', type: RuleSlotType.state),
    ],
  );

  static const wuxingRelation = TemplateDefinition(
    id: 'template.relation.wuxing',
    displayName: '五行关系',
    category: RuleTemplateCategory.wuxingRelation,
    operatorId: null,
    previewPattern: '[对象A] [关系] [对象B]',
    dslPattern: '[对象A] [关系] [对象B]',
    slots: [
      RuleSlotDefinition(id: 'objectA', type: RuleSlotType.object),
      RuleSlotDefinition(
        id: 'relation',
        type: RuleSlotType.relation,
        catalogId: 'wuxing_relations',
        projection: 'element',
      ),
      RuleSlotDefinition(id: 'objectB', type: RuleSlotType.object),
    ],
  );

  static const branchRelation = TemplateDefinition(
    id: 'template.relation.branch',
    displayName: '地支关系',
    category: RuleTemplateCategory.branchRelation,
    operatorId: null,
    previewPattern: '[对象A] [关系] [对象B]',
    dslPattern: '[对象A] [关系] [对象B]',
    slots: [
      RuleSlotDefinition(id: 'objectA', type: RuleSlotType.object),
      RuleSlotDefinition(
        id: 'relation',
        type: RuleSlotType.relation,
        catalogId: 'branch_relations',
        projection: 'branch',
      ),
      RuleSlotDefinition(id: 'objectB', type: RuleSlotType.object),
    ],
  );

  static const all = [propertyEquals, stateHas, wuxingRelation, branchRelation];
}
