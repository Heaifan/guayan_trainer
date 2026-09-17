library;

import '../rule_value_catalog.dart';
import '../../objects/dynamic_object_catalog.dart';

class PickerOption {
  const PickerOption(this.value, this.displayText);
  final String value;
  final String displayText;
}

class PickerCatalog {
  const PickerCatalog._();

  static List<PickerOption> values(String catalogId) {
    final ids = switch (catalogId) {
      'stem' || 'stems' => RuleValueCatalog.stems,
      'branch' || 'branches' => RuleValueCatalog.branches,
      'element' || 'elements' => RuleValueCatalog.elements,
      'spirit' || 'six_spirits' => RuleValueCatalog.sixSpirits,
      'kinship' || 'six_relatives' => RuleValueCatalog.sixRelatives,
      'nayin' => RuleValueCatalog.naYin,
      _ => throw ArgumentError('未知值目录: $catalogId'),
    };
    return ids
        .map((id) => PickerOption(id, RuleValueCatalog.display(id)))
        .toList();
  }

  static List<PickerOption> properties() => const [
    PickerOption('spirit', '六神'),
    PickerOption('relative', '六亲'),
    PickerOption('nayin', '纳音'),
    PickerOption('stem', '天干'),
    PickerOption('branch', '地支'),
    PickerOption('element', '五行'),
  ];

  static List<PickerOption> conditionKinds() => [...properties(), ...states()];

  static List<PickerOption> states() => const [
    PickerOption('xun_kong', '旬空'),
    PickerOption('yue_po', '月破'),
    PickerOption('ri_po', '日破'),
    PickerOption('in_tomb', '在库'),
    PickerOption('ru_mu', '入库于'),
    PickerOption('chong_mu', '冲库'),
    PickerOption('chu_mu', '出库'),
  ];

  static List<PickerOption> relations(String catalogId) => switch (catalogId) {
    'wuxing_relations' => const [
      PickerOption('generate', '生'),
      PickerOption('controls', '克'),
    ],
    'branch_relations' => const [
      PickerOption('clashes', '冲'),
      PickerOption('combines', '合'),
      PickerOption('punishes', '刑'),
      PickerOption('harms', '害'),
      PickerOption('breaks', '破'),
    ],
    _ => throw ArgumentError('未知关系目录: $catalogId'),
  };

  static List<PickerOption> objects() => const [
    PickerOption('line/1', '初爻'),
    PickerOption('line/2', '二爻'),
    PickerOption('line/3', '三爻'),
    PickerOption('line/4', '四爻'),
    PickerOption('line/5', '五爻'),
    PickerOption('line/6', '上爻'),
  ];

  static List<PickerOption> objectChoices() => [
    ...objects(),
    ...dynamicObjects(),
  ];

  static List<PickerOption> dynamicObjects() => DynamicObjectCatalog.all
      .map((item) => PickerOption(item.selectorId, item.displayName))
      .toList();

  static List<PickerOption> dynamicParameters(String selectorId) {
    if (selectorId == 'dynamic.line.by_spirit') {
      return values('six_spirits');
    }
    throw ArgumentError('动态对象没有可选参数: $selectorId');
  }
}
