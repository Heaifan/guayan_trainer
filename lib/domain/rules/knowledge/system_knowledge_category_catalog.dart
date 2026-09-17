class SystemKnowledgeCategory {
  const SystemKnowledgeCategory({
    required this.id,
    required this.displayName,
    required this.order,
    required this.description,
  });

  final String id;
  final String displayName;
  final int order;
  final String description;

  Map<String, Object> toJson() => {
    'id': id,
    'displayName': displayName,
    'order': order,
    'description': description,
  };
}

class SystemKnowledgeCategoryCatalog {
  static const categories = <SystemKnowledgeCategory>[
    SystemKnowledgeCategory(
      id: 'knowledge.category.foundation',
      displayName: '基础理论',
      order: 1,
      description: '五行、地支、纳甲、六亲生成及直接参与规则执行的基础理论。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.six_relatives',
      displayName: '六亲与取用',
      order: 2,
      description: '六亲与用神、原神、忌神、仇神、闲神等取用体系。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.six_spirits',
      displayName: '六神体系',
      order: 3,
      description: '青龙、朱雀、勾陈、螣蛇、白虎、玄武及其基础取象。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.shi_ying',
      displayName: '世应体系',
      order: 4,
      description: '世爻、应爻、世应定位、世应关系及相关判断。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.calendar_influence',
      displayName: '月日时令',
      order: 5,
      description: '月建、日辰及月日对爻的直接作用，不等同于最终旺衰结论。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.strength',
      displayName: '旺衰判断',
      order: 6,
      description: '旺相休囚死、得令失令、综合旺衰与强弱判断。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.state',
      displayName: '状态体系',
      order: 7,
      description: '旬空、入库、出库、填实、冲空及十二长生状态。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.relation',
      displayName: '生克冲合',
      order: 8,
      description: '生、克、冲、合、刑、害、破与三合、三会、六合等合局。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.change',
      displayName: '动变体系',
      order: 9,
      description: '动爻、变爻、化进化退、进神退神及爻自身变化关系。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.hidden',
      displayName: '飞伏体系',
      order: 10,
      description: '飞神、伏神、飞伏关系、伏神得出与受制。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.hexagram_structure',
      displayName: '卦象结构',
      order: 11,
      description: '反吟、伏吟、六冲卦、六合卦、游魂、归魂等整卦特殊结构。',
    ),
    SystemKnowledgeCategory(
      id: 'knowledge.category.shen_sha',
      displayName: '神煞体系',
      order: 12,
      description: '神煞定义、计算、适用范围及相关规则。',
    ),
  ];

  static Set<String> get ids =>
      categories.map((category) => category.id).toSet();

  static SystemKnowledgeCategory byId(String id) =>
      categories.singleWhere((category) => category.id == id);

  const SystemKnowledgeCategoryCatalog._();
}
