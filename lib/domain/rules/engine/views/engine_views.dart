library;

import '../../facts/fact_record.dart';
import '../../facts/semantic_ref.dart';

/// 运行时事实视图（只读）
abstract class RuntimeFactView {
  /// 查询实体是否具有指定的标量属性（例如 六亲、空亡、月破）
  FactRecord? queryProperty(SemanticRef subject, String predicateId);
  
  /// 获取实体的所有属性事实
  List<FactRecord> getFactsFor(SemanticRef subject);
}

/// 关系视图，用于查询二元/三元关系（生、克、冲、墓等）
abstract class RelationView {
  /// 查找特定关系，返回源/目的/类型，如果只是简单 bool 查询，可返回证据 ID 列表
  /// 目前简单返回对应关系的关联事实或关系记录列表
  List<FactRecord> queryRelation(SemanticRef source, String relationType, [SemanticRef? target]);
}

/// 标签视图
abstract class TagView {
  FactRecord? queryTag(SemanticRef subject, String categoryId, String tagId);
}
