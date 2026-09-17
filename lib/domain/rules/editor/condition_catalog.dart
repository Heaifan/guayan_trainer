import '../vocabulary/condition_registry.dart';

enum RuleConditionShape { property, state, relation, tag }

class RuleConditionDescriptor {
  const RuleConditionDescriptor({
    required this.id,
    required this.displayName,
    required this.category,
    required this.shape,
    required this.runtimeOperator,
    required this.supportedSubjects,
  });

  final String id;
  final String displayName;
  final String category;
  final RuleConditionShape shape;
  final String runtimeOperator;
  final List<String> supportedSubjects;
}

class RuleConditionCatalog {
  static const _subjects = [
    'A',
    'B',
    'line/1',
    'line/2',
    'line/3',
    'line/4',
    'line/5',
    'line/6',
  ];

  static final List<RuleConditionDescriptor> all = [
    ..._runtime('relative', '六亲为', '身份', RuleConditionShape.property),
    ..._runtime('spirit', '六神为', '身份', RuleConditionShape.property),
    ..._runtime('generate', '生', '关系', RuleConditionShape.relation),
    ..._runtime('nayin_is', '纳音为', '基础', RuleConditionShape.property),
    ..._runtime('xun_kong', '旬空', '状态', RuleConditionShape.state),
    ..._runtime('yue_po', '月破', '状态', RuleConditionShape.state),
    ..._runtime('ri_po', '日破', '状态', RuleConditionShape.state),
    ..._runtime('in_tomb', '在库', '状态', RuleConditionShape.state),
    ..._runtime('ru_mu', '入库于', '关系', RuleConditionShape.relation),
    ..._runtime('chong_mu', '冲库', '关系', RuleConditionShape.relation),
    ..._runtime('chu_mu', '出库', '关系', RuleConditionShape.relation),
    ..._runtime('has_tag', '有标签', '神煞', RuleConditionShape.tag),
    ..._runtime('stem_is', '天干为', '属性', RuleConditionShape.property),
    ..._runtime('branch_is', '地支为', '属性', RuleConditionShape.property),
    ..._runtime('element_is', '五行为', '属性', RuleConditionShape.property),
    ..._runtime('wuxing_overcomes', '克', '关系', RuleConditionShape.relation),
    ..._runtime('branch_clashes', '冲', '关系', RuleConditionShape.relation),
    ..._runtime('branch_combines', '合', '关系', RuleConditionShape.relation),
    ..._runtime('branch_punishes', '刑', '关系', RuleConditionShape.relation),
    ..._runtime('branch_harms', '害', '关系', RuleConditionShape.relation),
    ..._runtime('branch_breaks', '破', '关系', RuleConditionShape.relation),
    ..._runtime('structure_formed', '成结构', '结构', RuleConditionShape.property),
  ];

  static List<RuleConditionDescriptor> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (item) => '${item.displayName} ${item.id} ${item.category}'
              .toLowerCase()
              .contains(q),
        )
        .toList();
  }

  static List<RuleConditionDescriptor> _runtime(
    String id,
    String name,
    String category,
    RuleConditionShape shape,
  ) {
    final definition = CanonicalConditionRegistry.getDefinition(id);
    if (definition == null) return const [];
    return [
      RuleConditionDescriptor(
        id: id,
        displayName: name,
        category: category,
        shape: shape,
        runtimeOperator: definition.operatorId,
        supportedSubjects: _subjects,
      ),
    ];
  }
}
