library;

import 'fact_record.dart';
import 'derived_fact.dart';
import 'structure_fact.dart';
import '../engine/engine_types.dart';

/// 一次规则分析所能读取的不可变基础事实集合。
///
/// 强制 final、unmodifiable，无 add/remove/update 方法。
/// 旨在确保规则引擎读取到的原始事实永远不可修改。
class FactSnapshot {
  const FactSnapshot._(
    this._facts,
    this._relations,
    this._structures,
    this._derivedFacts,
  );

  final Map<String, FactRecord> _facts;
  final List<RuntimeRelation> _relations;
  final List<StructureFact> _structures;
  final List<DerivedFact> _derivedFacts;

  /// 暴露为不可变集合的 facts 迭代器
  Iterable<FactRecord> get facts => _facts.values;

  List<RuntimeRelation> get relations => _relations;

  List<StructureFact> get structures => _structures;

  List<DerivedFact> get derivedFacts => _derivedFacts;

  /// 根据 factId 获取对应的不可变事实
  FactRecord? getFact(String factId) => _facts[factId];

  /// 唯一构建入口：一次性传入所有事实，构建后完全冻结。
  factory FactSnapshot.build(
    Iterable<FactRecord> inputFacts, [
    Iterable<RuntimeRelation> inputRelations = const [],
    Iterable<StructureFact> inputStructures = const [],
    Iterable<DerivedFact> inputDerivedFacts = const [],
  ]) {
    final map = <String, FactRecord>{};
    for (final fact in inputFacts) {
      map[fact.factId] = fact;
    }
    return FactSnapshot._(
      Map.unmodifiable(map),
      List.unmodifiable(inputRelations),
      List.unmodifiable(inputStructures),
      List.unmodifiable(inputDerivedFacts),
    );
  }
}
