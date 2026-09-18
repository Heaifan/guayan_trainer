library;

import '../../di_zhi.dart';
import '../ast/binding_selector.dart';
import '../facts/fact_snapshot.dart';
import '../facts/fact_record.dart';
import '../facts/semantic_ref.dart';
import '../engine/operators/foundational_operators.dart';
import 'dynamic_object_catalog.dart';
import 'dynamic_object_definition.dart';

class DynamicResolution {
  const DynamicResolution({required this.definition, required this.candidates});
  final DynamicObjectDefinition definition;
  final List<SemanticRef> candidates;
  bool get isMany => definition.cardinality == DynamicCardinality.many;
}

class DynamicObjectResolver {
  const DynamicObjectResolver();

  DynamicResolution resolve(
    DynamicBindingSelector selector,
    FactSnapshot snapshot,
  ) {
    final definition = DynamicObjectCatalog.find(selector.selectorId);
    if (definition == null) {
      throw ArgumentError('未知动态对象: ${selector.selectorId}');
    }
    _validateParameters(selector);
    final candidates = switch (selector.selectorId) {
      'dynamic.line.all' => _allLines(snapshot),
      'dynamic.line.by_spirit' => _bySpirit(selector, snapshot),
      'dynamic.line.shi' => _byMarker('shi', snapshot),
      'dynamic.line.ying' => _byMarker('ying', snapshot),
      'dynamic.line.moving' => _byMovement(snapshot),
      'dynamic.line.by_branch_relation' => _byBranchRelation(
        selector,
        snapshot,
      ),
      _ => <SemanticRef>[],
    };
    return DynamicResolution(definition: definition, candidates: candidates);
  }

  SemanticRef resolveSingle(
    DynamicBindingSelector selector,
    FactSnapshot snapshot,
  ) {
    final result = resolve(selector, snapshot);
    if (result.candidates.length > 1 || result.isMany) {
      throw StateError('${result.definition.displayName}可能包含多个对象，需要范围/量词');
    }
    if (result.candidates.isEmpty) {
      throw StateError('${result.definition.displayName}没有匹配对象');
    }
    return result.candidates.single;
  }

  List<SemanticRef> _bySpirit(
    DynamicBindingSelector selector,
    FactSnapshot snapshot,
  ) {
    final wanted = _spiritId(selector.parameters['spirit']);
    return _facts(snapshot, 'spirit')
        .where((fact) => _spiritId(fact.value.value?.toString()) == wanted)
        .map((fact) => fact.subject)
        .where((ref) => ref.kind == 'line')
        .toSet()
        .toList();
  }

  void _validateParameters(DynamicBindingSelector selector) {
    if (selector.selectorId == 'dynamic.line.by_spirit' &&
        (selector.parameters['spirit'] == null ||
            selector.parameters['spirit']!.isEmpty)) {
      throw ArgumentError('dynamic.line.by_spirit 缺少 spirit 参数');
    }
    if (selector.selectorId == 'dynamic.line.by_branch_relation' &&
        (selector.parameters['referenceObject'] == null ||
            selector.parameters['relation'] == null)) {
      throw ArgumentError('dynamic.line.by_branch_relation 参数不完整');
    }
  }

  List<SemanticRef> _allLines(FactSnapshot snapshot) {
    final refs = snapshot.facts
        .map((fact) => fact.subject)
        .where((ref) => ref.kind == 'line')
        .toSet()
        .toList();
    refs.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    return refs;
  }

  List<SemanticRef> _byMarker(String marker, FactSnapshot snapshot) => snapshot
      .facts
      .where(
        (fact) =>
            fact.subject.kind == 'line' &&
            (fact.predicateId == 'shi_ying' || fact.predicateId == 'shiYing') &&
            fact.value.value.toString() == marker,
      )
      .map((fact) => fact.subject)
      .toList();

  List<SemanticRef> _byMovement(FactSnapshot snapshot) => snapshot.facts
      .where(
        (fact) =>
            fact.subject.kind == 'line' &&
            (fact.predicateId == 'movement' || fact.predicateId == 'state') &&
            const {'moving', 'dong', '动'}.contains(fact.value.value),
      )
      .map((fact) => fact.subject)
      .toSet()
      .toList();

  List<SemanticRef> _byBranchRelation(
    DynamicBindingSelector selector,
    FactSnapshot snapshot,
  ) {
    final reference = _parse(selector.parameters['referenceObject']);
    final refBranch = _branch(snapshot, reference);
    if (refBranch == null) return const [];
    return _facts(snapshot, 'branch')
        .where(
          (fact) => fact.subject.kind == 'line' && fact.subject != reference,
        )
        .where((fact) {
          final branch = _branchValue(fact.value.value);
          return branch != null &&
              _matches(selector.parameters['relation'], branch, refBranch);
        })
        .map((fact) => fact.subject)
        .toSet()
        .toList();
  }

  Iterable<FactRecord> _facts(FactSnapshot snapshot, String predicate) =>
      snapshot.facts.where((fact) => fact.predicateId == predicate);

  DiZhi? _branch(FactSnapshot snapshot, SemanticRef? ref) {
    if (ref == null) return null;
    final fact = _facts(
      snapshot,
      'branch',
    ).where((f) => f.subject == ref).firstOrNull;
    return fact == null ? null : _branchValue(fact.value.value);
  }

  DiZhi? _branchValue(Object? value) => DiZhi.tryFromLabel(value.toString());

  bool _matches(String? id, DiZhi a, DiZhi b) => switch (id) {
    'combines' => branchCombines(a, b),
    'clashes' => branchClashes(a, b),
    'harms' => branchHarms(a, b),
    'punishes' => branchPunishes(a, b),
    'breaks' => branchBreaks(a, b),
    _ => false,
  };

  SemanticRef? _parse(String? value) {
    if (value == null) return null;
    final parts = value.split('/');
    return parts.length == 2 ? SemanticRef(parts[0], parts[1]) : null;
  }

  String _spiritId(String? value) => switch (value) {
    '青龙' || 'qingLong' || 'spirit.qing_long' => 'spirit.qing_long',
    '朱雀' || 'zhuQue' || 'spirit.zhu_que' => 'spirit.zhu_que',
    '勾陈' || 'gouChen' || 'spirit.gou_chen' => 'spirit.gou_chen',
    '螣蛇' || '腾蛇' || 'tengShe' || 'spirit.teng_she' => 'spirit.teng_she',
    '白虎' || 'baiHu' || 'spirit.bai_hu' => 'spirit.bai_hu',
    '玄武' || 'xuanWu' || 'spirit.xuan_wu' => 'spirit.xuan_wu',
    _ => value ?? '',
  };
}
