import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../domain/rules/ast/binding_selector.dart';
import '../../domain/rules/ast/rule_action.dart';
import '../../domain/rules/ast/rule_binding.dart';
import '../../domain/rules/ast/rule_expr.dart';
import '../../domain/rules/ast/rule_operand.dart';
import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/core/rule_id.dart';
import '../../domain/rules/core/rule_origin.dart';
import '../../domain/rules/core/rule_stage.dart';
import '../../domain/rules/core/rule_version.dart';
import '../../domain/rules/corpus/common_rule_corpus.dart';
import '../../domain/rules/editor/custom_rule_service.dart';
import '../../domain/rules/editor/condition_catalog.dart';
import '../../domain/rules/editor/portable_rule_codec.dart';
import '../../domain/rules/editor/rule_editor_draft.dart';
import '../../domain/rules/editor/rule_visual_renderer.dart';
import '../../domain/rules/editor/rule_mapping_table.dart';
import '../../domain/rules/editor/custom_shen_sha_definition.dart';
import '../../domain/rules/editor/custom_shen_sha_store.dart';
import '../../domain/rules/editor/pickers/picker_request.dart';
import '../../domain/rules/editor/pickers/picker_router.dart';
import '../../domain/rules/editor/pickers/picker_result.dart';
import '../../domain/rules/templates/rule_slot_definition.dart';
import '../../domain/rules/templates/template_catalog.dart';
import '../../domain/rules/templates/template_compiler_registry.dart';
import '../../domain/rules/templates/template_invocation.dart';
import '../../domain/rules/facts/rule_value.dart';
import '../../domain/rules/topics/exam/exam_rule_corpus.dart';
import '../../domain/rules/facts/fact_snapshot.dart';
import '../../domain/hexagram_case.dart';
import '../../domain/casting/casting_engine.dart';
import '../../domain/rules/facts/canonical_fact_snapshot_builder.dart';
import 'rule_test_result_page.dart';

class RuleEditorPage extends StatefulWidget {
  const RuleEditorPage({
    super.key,
    required this.service,
    this.initialRule,
    this.isCopy = false,
    this.testCase,
  });
  final CustomRuleService service;
  final RuleDefinition? initialRule;
  final bool isCopy;
  final HexagramCase? testCase;
  @override
  State<RuleEditorPage> createState() => _RuleEditorPageState();
}

class _RuleEditorPageState extends State<RuleEditorPage> {
  late RuleEditorDraft _draft;
  final _renderer = const RuleVisualRenderer();
  final _history = <RuleDefinition>[];
  int _historyIndex = -1;
  final _customShenShaStore = CustomShenShaStore();

  @override
  void initState() {
    super.initState();
    _draft = RuleEditorDraft.fromDefinition(widget.initialRule ?? _newRule());
    _customShenShaStore.load();
    if (widget.isCopy) {
      _draft.ruleId = RuleId('custom_${const Uuid().v4().substring(0, 8)}');
      _draft.origin = RuleOrigin.CUSTOM;
      _draft.overrideTarget = null;
    }
    _remember();
  }

  RuleDefinition _newRule() => RuleDefinition(
    ruleId: RuleId('custom_${const Uuid().v4().substring(0, 8)}'),
    version: RuleVersion('1.0.0'),
    origin: RuleOrigin.CUSTOM,
    namespace: 'common',
    categoryId: 'common',
    stage: RuleStage.tag,
    title: '新规则',
    description: '',
    provenance: 'user',
    bindings: const [
      RuleBinding(name: 'A', selector: DirectSelector('line/5')),
    ],
    condition: PredicateExpr(
      operatorId: 'spirit',
      operands: [
        const BindingRefOperand('A'),
        LiteralOperand(RuleValue.string('spirit.bai_hu')),
      ],
    ),
    actions: const [
      TagAction(categoryId: 'image', tagId: 'road', subjectBinding: 'A'),
    ],
  );

  RuleDefinition get _definition => _draft.toDefinition();

  void _remember() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(
      PortableRuleCodec.fromJson(PortableRuleCodec.encode(_definition)),
    );
    if (_history.length > 30) _history.removeAt(0);
    _historyIndex = _history.length - 1;
  }

  void _restore(RuleDefinition value) => setState(() {
    _draft = RuleEditorDraft.fromDefinition(value);
    _remember();
  });
  void _undo() {
    if (_historyIndex <= 0) return;
    setState(() {
      _historyIndex--;
      _draft = RuleEditorDraft.fromDefinition(_history[_historyIndex]);
    });
  }

  void _redo() {
    if (_historyIndex >= _history.length - 1) return;
    setState(() {
      _historyIndex++;
      _draft = RuleEditorDraft.fromDefinition(_history[_historyIndex]);
    });
  }

  PredicateExpr? _firstPredicate(RuleExpr? expr) {
    if (expr is PredicateExpr) return expr;
    if (expr is NotExpr) return _firstPredicate(expr.node);
    if (expr is AllExpr && expr.nodes.isNotEmpty) {
      return _firstPredicate(expr.nodes.first);
    }
    if (expr is AnyExpr && expr.nodes.isNotEmpty) {
      return _firstPredicate(expr.nodes.first);
    }
    return null;
  }

  void _replaceFirst(PredicateExpr replacement, PredicateExpr target) {
    RuleExpr replace(RuleExpr expr) {
      if (identical(expr, target)) return replacement;
      if (expr is AllExpr) return AllExpr(expr.nodes.map(replace).toList());
      if (expr is AnyExpr) return AnyExpr(expr.nodes.map(replace).toList());
      if (expr is NotExpr) return NotExpr(replace(expr.node));
      return expr;
    }

    _draft.condition = replace(_draft.condition!);
    setState(_remember);
  }

  Future<String?> _pick(String title, List<String> items) {
    var query = '';
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filtered = items.where((item) => item.contains(query)).toList();
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: '搜索',
                      ),
                      onChanged: (value) => setSheetState(() => query = value),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: filtered
                          .map(
                            (item) => ListTile(
                              title: Text(item),
                              onTap: () => Navigator.pop(context, item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<PickerResult?> _pickFromRouter(
    String title,
    PickerRequest request,
  ) async {
    final options = PickerRouter.optionsFor(request);
    final display = await _pick(
      title,
      options.map((e) => e.displayText).toList(),
    );
    if (display == null) return null;
    return PickerRouter.resultFor(
      options.firstWhere((option) => option.displayText == display),
    );
  }

  Future<void> _chooseObject() async {
    final result = await _pickFromRouter(
      '选择对象',
      const PickerRequest(
        slotId: 'object',
        slotType: RuleSlotType.object,
        catalogId: 'object_choices',
      ),
    );
    if (result == null) return;
    final old = _draft.bindings.first;
    BindingSelector selector;
    if (result.value.startsWith('dynamic.')) {
      if (result.value == 'dynamic.line.moving' ||
          result.value == 'dynamic.line.by_branch_relation') {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('该对象可能包含多个结果，需要范围/量词。')));
        }
        return;
      }
      var parameters = const <String, String>{};
      if (result.value == 'dynamic.line.by_spirit') {
        final spirit = await _pickFromRouter(
          '选择六神',
          PickerRequest(
            slotId: 'spirit',
            slotType: RuleSlotType.value,
            catalogId: result.value,
          ),
        );
        if (spirit == null) return;
        parameters = {'spirit': spirit.value};
      }
      selector = DynamicBindingSelector(
        selectorId: result.value,
        parameters: parameters,
      );
    } else {
      selector = DirectSelector(result.value);
    }
    _draft.bindings = [
      RuleBinding(name: old.name, selector: selector),
      ..._draft.bindings.skip(1),
    ];
    setState(_remember);
  }

  Future<void> _chooseProperty() async {
    final result = await _pickFromRouter(
      '选择属性或状态',
      const PickerRequest(
        slotId: 'condition-kind',
        slotType: RuleSlotType.property,
        catalogId: 'condition_kinds',
      ),
    );
    if (result == null) return;
    final value = result.displayText;
    final ids = {
      '六神': 'spirit',
      '六亲': 'relative',
      '纳音': 'nayin_is',
      '天干': 'stem_is',
      '地支': 'branch_is',
      '五行': 'element_is',
      '旬空': 'xun_kong',
      '月破': 'yue_po',
      '日破': 'ri_po',
      '在库': 'in_tomb',
    };
    final op = ids[value]!;
    final old = _firstPredicate(_draft.condition);
    if (old == null) return;
    final operands = op == 'spirit'
        ? [
            const BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('spirit.bai_hu')),
          ]
        : op == 'relative'
        ? [
            const BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('relative.parent')),
          ]
        : op == 'nayin_is'
        ? [
            const BindingRefOperand('A'),
            LiteralOperand(RuleValue.string('nayin.hai_zhong_jin')),
          ]
        : const {'stem_is', 'branch_is', 'element_is'}.contains(op)
        ? [const BindingRefOperand('A'), LiteralOperand(RuleValue.string(''))]
        : [const BindingRefOperand('A')];
    _replaceFirst(PredicateExpr(operatorId: op, operands: operands), old);
  }

  Future<void> _chooseValue() async {
    final p = _firstPredicate(_draft.condition);
    if (p == null ||
        const {
          'xun_kong',
          'yue_po',
          'ri_po',
          'in_tomb',
        }.contains(p.operatorId)) {
      return;
    }
    final result = await _pickFromRouter(
      '选择值',
      PickerRouter.requestForPredicate(p.operatorId),
    );
    if (result == null) return;
    final operands = [...p.operands];
    if (operands.length > 1) {
      operands[1] = LiteralOperand(RuleValue.string(result.value));
    }
    _replaceFirst(
      PredicateExpr(operatorId: p.operatorId, operands: operands),
      p,
    );
  }

  PredicateExpr? _templateConditionFor(String label) {
    const properties = {
      '六神为': ('spirit', 'six_spirits', 'spirit.bai_hu'),
      '六亲为': ('relative', 'six_relatives', 'relative.parent'),
      '纳音为': ('nayin', 'nayin', 'nayin.hai_zhong_jin'),
      '天干为': ('stem', 'stems', '丙'),
      '地支为': ('branch', 'branches', '申'),
      '五行为': ('element', 'elements', '金'),
    };
    final property = properties[label];
    if (property != null) {
      return TemplateCompilerRegistry.compile(
            TemplateInvocation(
              template: TemplateCatalog.propertyEquals,
              values: {
                'object': const ObjectSlotValue('A'),
                'property': PropertySlotValue(property.$1),
                'value': ValueSlotValue(
                  catalogId: property.$2,
                  value: property.$3,
                ),
              },
            ),
          )
          as PredicateExpr;
    }
    const states = {
      '旬空': 'xun_kong',
      '月破': 'yue_po',
      '日破': 'ri_po',
      '在库': 'in_tomb',
    };
    final state = states[label];
    if (state != null) {
      return TemplateCompilerRegistry.compile(
            TemplateInvocation(
              template: TemplateCatalog.stateHas,
              values: {
                'object': const ObjectSlotValue('A'),
                'state': StateSlotValue(state),
              },
            ),
          )
          as PredicateExpr;
    }
    const wuxing = {'生': 'generate', '克': 'controls'};
    final wuxingRelation = wuxing[label];
    if (wuxingRelation != null) {
      return TemplateCompilerRegistry.compile(
            TemplateInvocation(
              template: TemplateCatalog.wuxingRelation,
              values: {
                'objectA': const ObjectSlotValue('A'),
                'relation': RelationSlotValue(wuxingRelation),
                'objectB': const ObjectSlotValue('B'),
              },
            ),
          )
          as PredicateExpr;
    }
    const branch = {
      '冲': 'clashes',
      '合': 'combines',
      '刑': 'punishes',
      '害': 'harms',
      '破': 'breaks',
    };
    final branchRelation = branch[label];
    if (branchRelation != null) {
      return TemplateCompilerRegistry.compile(
            TemplateInvocation(
              template: TemplateCatalog.branchRelation,
              values: {
                'objectA': const ObjectSlotValue('A'),
                'relation': RelationSlotValue(branchRelation),
                'objectB': const ObjectSlotValue('B'),
              },
            ),
          )
          as PredicateExpr;
    }
    return null;
  }

  PredicateExpr _conditionFor(String label) {
    final descriptor = RuleConditionCatalog.all.firstWhere(
      (item) => item.id == label,
      orElse: () => RuleConditionCatalog.all.firstWhere(
        (item) => item.displayName == label,
      ),
    );
    final canonicalLabel = descriptor.displayName;
    final compiled = _templateConditionFor(canonicalLabel);
    if (compiled != null) return compiled;
    // Legacy-only conditions remain here; the four E1 template families are
    // compiled above through TemplateInvocation and TemplateCompilerRegistry.
    final values = <String, List<RuleOperand>>{
      '成结构': [LiteralOperand(RuleValue.string('sanHe.木'))],
      '入库于': [const BindingRefOperand('A'), const BindingRefOperand('B')],
      '冲库': [const BindingRefOperand('A'), const BindingRefOperand('B')],
      '出库': [
        const BindingRefOperand('A'),
        const BindingRefOperand('B'),
        const BindingRefOperand('C'),
      ],
      '有标签': [
        const BindingRefOperand('A'),
        LiteralOperand(RuleValue.string('shensha')),
        LiteralOperand(RuleValue.string('shensha.custom.my_rule')),
      ],
    };
    final ids = {
      '成结构': 'structure_formed',
      '入库于': 'ru_mu',
      '冲库': 'chong_mu',
      '出库': 'chu_mu',
      '有标签': 'has_tag',
    };
    return PredicateExpr(
      operatorId: ids[canonicalLabel]!,
      operands: values[canonicalLabel]!,
    );
  }

  Future<void> _addCondition() async {
    final label = await _pick(
      '添加条件',
      RuleConditionCatalog.all.map((item) => item.displayName).toList(),
    );
    if (label == null) return;
    final added = _conditionFor(
      RuleConditionCatalog.all
          .firstWhere((item) => item.displayName == label)
          .id,
    );
    if (added.operands.any(
          (operand) =>
              operand is BindingRefOperand && operand.bindingName == 'B',
        ) &&
        !_draft.bindings.any((binding) => binding.name == 'B')) {
      _draft.bindings = [
        ..._draft.bindings,
        const RuleBinding(name: 'B', selector: DirectSelector('line/6')),
      ];
    }
    if (added.operands.any(
          (operand) =>
              operand is BindingRefOperand && operand.bindingName == 'C',
        ) &&
        !_draft.bindings.any((binding) => binding.name == 'C')) {
      _draft.bindings = [
        ..._draft.bindings,
        const RuleBinding(name: 'C', selector: DirectSelector('line/1')),
      ];
    }
    final current = _draft.condition!;
    _draft.condition = current is AllExpr
        ? AllExpr([...current.nodes, added])
        : AllExpr([current, added]);
    setState(_remember);
  }

  void _deleteCondition() {
    final current = _draft.condition!;
    if (current is AllExpr && current.nodes.length > 1) {
      _draft.condition = AllExpr(
        current.nodes.sublist(0, current.nodes.length - 1),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('至少保留一个条件')));
      return;
    }
    setState(_remember);
  }

  Future<void> _chooseResultType({bool append = false}) async {
    final type = await _pick('选择结果类型', const ['取象', '标签', '状态', '记录结果']);
    if (type == null) return;
    final content = append || _draft.actions.isEmpty
        ? ''
        : _actionContent(_draft.actions.first);
    RuleAction action;
    if (type == '取象') {
      action = TagAction(
        categoryId: 'image',
        tagId: content,
        subjectBinding: 'A',
      );
    } else if (type == '标签') {
      action = TagAction(
        categoryId: 'common',
        tagId: content,
        subjectBinding: 'A',
      );
    } else if (type == '状态') {
      action = DeriveAction(targetBinding: 'A', factKey: content);
    } else if (type == '记录结果') {
      action = RecordAction(
        recordType: 'custom',
        content: {'text': RuleValue.string(content)},
      );
    } else {
      action = const TagAction(
        categoryId: 'common',
        tagId: 'custom',
        subjectBinding: 'A',
      );
    }
    if (append) {
      _draft.actions = [..._draft.actions, action];
    } else if (_draft.actions.isEmpty) {
      _draft.actions = [action];
    } else {
      _draft.actions = [action, ..._draft.actions.skip(1)];
    }
    setState(_remember);
  }

  String _actionContent(RuleAction action) {
    if (action is TagAction) return action.tagId;
    if (action is DeriveAction) return action.factKey;
    if (action is StructureAction) return action.structureId;
    return (action as RecordAction).content['text']?.value?.toString() ?? '';
  }

  Future<void> _chooseResultValue(int index) async {
    if (index < 0 || index >= _draft.actions.length) return;
    final controller = TextEditingController(
      text: _actionContent(_draft.actions[index]),
    );
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('填写结果内容'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '例如：道路、阻滞、可成',
            helperText: RuleMappingTable.imageFor(controller.text),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (value == null || value.isEmpty) return;
    final old = _draft.actions[index];
    final type = old is TagAction
        ? (old.categoryId == 'image' ? '取象' : '标签')
        : old is DeriveAction
        ? '状态'
        : '记录结果';
    final action = type == '取象'
        ? TagAction(categoryId: 'image', tagId: value, subjectBinding: 'A')
        : type == '标签'
        ? TagAction(categoryId: 'common', tagId: value, subjectBinding: 'A')
        : type == '状态'
        ? DeriveAction(targetBinding: 'A', factKey: value)
        : RecordAction(
            recordType: 'custom',
            content: {'text': RuleValue.string(value)},
          );
    _draft.actions = [..._draft.actions]..[index] = action;
    setState(_remember);
  }

  Future<void> _addCustomShenSha() async {
    final idController = TextEditingController(text: 'shensha.custom.');
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建自定义神煞'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: '稳定 ID'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '名称'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: '说明'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (saved != true || nameController.text.trim().isEmpty) return;
    await _customShenShaStore.addOrUpdate(
      CustomShenShaDefinition(
        id: idController.text.trim(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('自定义神煞已保存')));
    }
  }

  Future<void> _addQuantifier() async {
    final kind = await _pick('选择范围条件', const ['任一', '全部', '不存在', '至少', '恰好']);
    if (kind == null) return;
    if (!mounted) return;
    var count = 1;
    if (kind == '至少' || kind == '恰好') {
      final controller = TextEditingController(text: '1');
      final value = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('$kind几个发动之爻'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '数量'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, int.tryParse(controller.text)),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      if (value == null || value < 1) return;
      count = value;
    }
    final quantifier = switch (kind) {
      '任一' => QuantifierKind.any,
      '全部' => QuantifierKind.all,
      '不存在' => QuantifierKind.none,
      '至少' => QuantifierKind.atLeast,
      _ => QuantifierKind.exactly,
    };
    _draft.condition = QuantifiedExpr(
      bindingName: 'moving',
      selector: const DynamicBindingSelector(selectorId: 'dynamic.line.moving'),
      kind: quantifier,
      count: count,
      node: _draft.condition!,
    );
    setState(_remember);
  }

  void _deleteResult() {
    if (_draft.actions.isEmpty) return;
    if (_draft.actions.length == 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('至少保留一个结果')));
      return;
    }
    _draft.actions = _draft.actions.sublist(0, _draft.actions.length - 1);
    setState(_remember);
  }

  Future<void> _showJson() async {
    final controller = TextEditingController(
      text: PortableRuleCodec.encodeText(_definition),
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AST JSON'),
        content: SizedBox(
          width: 600,
          child: TextField(controller: controller, maxLines: 14),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: controller.text)),
            child: const Text('复制'),
          ),
          TextButton(
            onPressed: () {
              try {
                _restore(PortableRuleCodec.decodeText(controller.text));
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('导入'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await widget.service.save(_definition, [
      ...CommonRuleCorpus.v1(),
      ...ExamRuleCorpus.v1(),
    ]);
    if (mounted) Navigator.pop(context);
  }

  void _testRule() {
    final hexagramCase = widget.testCase;
    if (hexagramCase == null) {
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('无法测试规则'),
          content: Text('暂无测试卦例，请先选择或创建一个卦例。'),
        ),
      );
      return;
    }
    late final FactSnapshot snapshot;
    try {
      snapshot = CanonicalFactSnapshotBuilder.build(hexagramCase);
    } catch (error) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('测试卦例数据不完整'),
          content: Text('$error'),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RuleTestResultPage(
          rule: _definition,
          snapshot: snapshot,
          testCase: hexagramCase,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = _renderer.render(_definition);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F3),
        title: const Text('规则编辑器'),
        actions: [
          IconButton(onPressed: _undo, icon: const Icon(Icons.undo)),
          IconButton(onPressed: _redo, icon: const Icon(Icons.redo)),
          IconButton(onPressed: _showJson, icon: const Icon(Icons.data_object)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            initialValue: _draft.title,
            decoration: const InputDecoration(labelText: '规则名称'),
            onChanged: (value) => _draft.title = value,
          ),
          const SizedBox(height: 16),
          const Text(
            '可视化规则',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFA),
              border: Border.all(color: const Color(0xFFD7E0DC)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < lines.length; i++)
                  _VisualLine(
                    number: i + 1,
                    line: lines[i],
                    onTokenTap: (token) {
                      if (token.kind == VisualTokenKind.object) _chooseObject();
                      if (token.kind == VisualTokenKind.property ||
                          token.kind == VisualTokenKind.operator) {
                        _chooseProperty();
                      }
                      if (token.kind == VisualTokenKind.value) _chooseValue();
                      if (token.kind == VisualTokenKind.resultType) {
                        _chooseResultType();
                      }
                      if (token.kind == VisualTokenKind.resultValue &&
                          token.actionIndex != null) {
                        _chooseResultValue(token.actionIndex!);
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '点击对象、属性或值即可修改；换行和缩进由编辑器自动生成。',
            style: TextStyle(color: Color(0xFF66736D)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _addCondition,
                icon: const Icon(Icons.add),
                label: const Text('添加条件'),
              ),
              OutlinedButton.icon(
                onPressed: _addQuantifier,
                icon: const Icon(Icons.filter_alt),
                label: const Text('添加范围'),
              ),
              OutlinedButton.icon(
                onPressed: _deleteCondition,
                icon: const Icon(Icons.remove),
                label: const Text('删除条件'),
              ),
              OutlinedButton.icon(
                onPressed: () => _chooseResultType(append: true),
                icon: const Icon(Icons.add),
                label: const Text('添加结果'),
              ),
              OutlinedButton.icon(
                onPressed: _deleteResult,
                icon: const Icon(Icons.remove),
                label: const Text('删除结果'),
              ),
              OutlinedButton.icon(
                onPressed: _addCustomShenSha,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('新建神煞'),
              ),
          ],
          ),
          const SizedBox(height: 12),
          _TestCaseSummary(testCase: widget.testCase),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _testRule,
                icon: const Icon(Icons.play_arrow),
                label: const Text('测试规则'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCaseSummary extends StatelessWidget {
  const _TestCaseSummary({required this.testCase});

  final HexagramCase? testCase;

  @override
  Widget build(BuildContext context) {
    if (testCase == null) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('测试卦例'),
        subtitle: Text('请选择测试卦例'),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('测试卦例'),
      subtitle: Text(
        '${_hexagramName(testCase!)}\n${testCase!.createdAt.toLocal().toString().split('.').first}\n只读，不会修改正式卦例或 RuleRun',
      ),
    );
  }

  String _hexagramName(HexagramCase value) => CastingEngine.cast([
        for (final line in value.lines) line.movementType,
      ]).original.name;
}

class _VisualLine extends StatelessWidget {
  const _VisualLine({
    required this.number,
    required this.line,
    required this.onTokenTap,
  });
  final int number;
  final VisualRuleLine line;
  final ValueChanged<VisualToken> onTokenTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '$number',
            style: const TextStyle(color: Color(0xFF8A9690)),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: line.indent * 28),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: line.tokens
                  .map(
                    (token) =>
                        _Token(token: token, onTap: () => onTokenTap(token)),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Token extends StatelessWidget {
  const _Token({required this.token, required this.onTap});
  final VisualToken token;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(
    label: Text(token.text),
    onPressed: token.kind == VisualTokenKind.keyword ? null : onTap,
    backgroundColor:
        token.kind == VisualTokenKind.resultType ||
            token.kind == VisualTokenKind.resultValue
        ? const Color(0xFFE8F1FF)
        : const Color(0xFFF0F4F1),
  );
}
