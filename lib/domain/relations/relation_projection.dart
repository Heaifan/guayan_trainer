import '../relation_instance.dart';
import '../relation_endpoint.dart';
import '../relation_type.dart';
import 'relation_record.dart';

abstract final class RelationProjection {
  static List<RelationRecord> projectRelationInstances(
    Iterable<RelationInstance> instances,
  ) => [for (final instance in instances) _project(instance)];

  static RelationRecord _project(RelationInstance instance) {
    final key = instance.key;
    return RelationRecord.relation(
      id: 'fact:${key.canonical}',
      sourceKind: RelationSourceKind.fact,
      relationType: instance.type,
      fromRef: instance.source,
      toRef: instance.target,
      title:
          '${instance.type.displayName}：${_label(instance.source)}'
          '${_arrow(instance)}${_label(instance.target)}',
      subtitle:
          '${instance.type.displayName} · ${_label(instance.source)} / '
          '${_label(instance.target)}',
      category: _category(instance),
      ruleId: key.ruleId,
    );
  }

  static String _category(RelationInstance instance) => switch (instance.type) {
    RelationType.sheng ||
    RelationType.ke ||
    RelationType.huiTouSheng ||
    RelationType.huiTouKe => '生克',
    RelationType.monthGenerate ||
    RelationType.monthControl ||
    RelationType.dayGenerate ||
    RelationType.dayControl => '月日',
    RelationType.liuChong || RelationType.liuHe => '冲合',
    RelationType.dongBian => '动变',
  };

  static String _label(Object endpoint) => switch (endpoint) {
    YaoEndpoint(:final position, :final scope) =>
      '${scope.machineName == 'changed' ? '变' : ''}${_position(position)}',
    MonthEndpoint() => '月建',
    DayEndpoint() => '日辰',
    _ => endpoint.toString(),
  };

  static String _position(int position) =>
      const ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'][position - 1];

  static String _arrow(RelationInstance instance) =>
      instance.type.directionKind == RelationDirectionKind.directed ? '→' : '↔';
}
