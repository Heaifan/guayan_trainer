import '../../domain/relation_endpoint.dart';
import '../../domain/relation_type.dart';
import '../review/review_page_state.dart';

class RelationEndpointDisplay {
  const RelationEndpointDisplay({
    required this.position,
    required this.identity,
  });
  final String position;
  final String identity;
  String get fullName => '$position · $identity';
}

/// 将 Domain 端点转换为普通用户可读的六爻语义。
class RelationEndpointPresenter {
  const RelationEndpointPresenter(this.state);
  final ReviewPageState? state;

  RelationEndpointDisplay present(RelationEndpoint endpoint) {
    switch (endpoint) {
      case YaoEndpoint(:final position, :final scope):
        final line = state?.lineAt(position);
        final identity = scope == LineScope.changed
            ? line?.changed?.sixRelative ?? line?.sixRelative ?? '—'
            : line?.sixRelative ?? line?.identity?.relative ?? '—';
        return RelationEndpointDisplay(
          position:
              '${scope == LineScope.changed ? '变' : ''}${reviewLinePositionName(position)}',
          identity: identity,
        );
      case MonthEndpoint():
        return RelationEndpointDisplay(
          position: '月建',
          identity: state?.monthPillar ?? '—',
        );
      case DayEndpoint():
        return RelationEndpointDisplay(
          position: '日辰',
          identity: state?.dayPillar ?? '—',
        );
    }
  }

  String relationName(RelationType type) => type.displayName;

  String categoryName(String? category, RelationType? type) =>
      category ?? _categoryFor(type);

  String sourceName() => '排盘事实';

  String ruleName(RelationType? type, String? ruleId) {
    if (type == null) return '系统规则';
    return switch (type) {
      RelationType.sheng => '五行相生',
      RelationType.ke => '五行相克',
      RelationType.liuChong => '地支六冲',
      RelationType.liuHe => '地支六合',
      RelationType.huiTouSheng => '回头生',
      RelationType.huiTouKe => '回头克',
      RelationType.dongBian => '动爻变卦',
    };
  }

  static String _categoryFor(RelationType? type) => switch (type) {
    RelationType.sheng ||
    RelationType.ke ||
    RelationType.huiTouSheng ||
    RelationType.huiTouKe => '生克',
    RelationType.liuChong || RelationType.liuHe => '冲合',
    RelationType.dongBian => '动变',
    null => '状态',
  };
}
