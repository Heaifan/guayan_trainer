/// 关系端点的**领域语义身份**（R4 基础契约）。
///
/// ```text
/// RelationKey 的 source / target 必须表示真实语义对象。
/// 禁止为了复用六爻 position 模型，给非爻对象制造虚假的 position。
/// ```
/// 月建、日辰因此**没有** position（semanticId 就是 `month` / `day`）。
/// `LineEndpoint` 只属于绘线定位层，不再是关系身份真源。
/// 完整契约与扩展清单见 `lib/domain/README.md`。
library;

import 'line_scope.dart';

export 'line_scope.dart';

/// 端点种类（序列化用稳定机器名）。
enum RelationEndpointKind {
  yao('yao'),
  month('month'),
  day('day');

  const RelationEndpointKind(this.machineName);

  final String machineName;

  static RelationEndpointKind fromMachineName(String name) =>
      values.firstWhere((k) => k.machineName == name);
}

/// 关系端点：Domain 语义身份（唯一真源）。
sealed class RelationEndpoint {
  const RelationEndpoint();

  RelationEndpointKind get kind;

  /// 唯一 canonical 语义 id，参与 RelationKey canonical：
  /// `yao:original:3` / `yao:changed:6` / `month` / `day`。
  String get semanticId;

  Map<String, Object?> toJson();

  /// 反序列化。
  ///
  /// 兼容旧数据：`{'scope': ..., 'position': ...}`（无 `kind`）视为 [YaoEndpoint]，
  /// 使迁移前保存的卦例仍可解析（旧 canonical 字符串本身不再复用）。
  static RelationEndpoint fromJson(Map<String, Object?> json) {
    final kind = json['kind'] as String?;
    if (kind == null) {
      return YaoEndpoint(
        LineScope.values.byName(json['scope'] as String),
        json['position'] as int,
      );
    }
    return switch (RelationEndpointKind.fromMachineName(kind)) {
      RelationEndpointKind.yao => YaoEndpoint(
        LineScope.values.byName(json['scope'] as String),
        json['position'] as int,
      ),
      RelationEndpointKind.month => const MonthEndpoint(),
      RelationEndpointKind.day => const DayEndpoint(),
    };
  }
}

/// 爻端点：卦侧 + 爻位（1 = 初爻 … 6 = 上爻）。
class YaoEndpoint extends RelationEndpoint {
  const YaoEndpoint._(this.scope, this.position);

  factory YaoEndpoint(LineScope scope, int position) {
    if (position < 1 || position > 6) {
      throw ArgumentError.value(position, 'position', '爻位必须在 1..6');
    }
    return YaoEndpoint._(scope, position);
  }

  final LineScope scope;
  final int position;

  @override
  RelationEndpointKind get kind => RelationEndpointKind.yao;

  @override
  String get semanticId => 'yao:${scope.machineName}:$position';

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.machineName,
    'scope': scope.machineName,
    'position': position,
  };

  @override
  bool operator ==(Object other) =>
      other is YaoEndpoint && other.semanticId == semanticId;

  @override
  int get hashCode => semanticId.hashCode;

  @override
  String toString() => semanticId;
}

/// 月建端点：**无 position**（它不是爻）。
class MonthEndpoint extends RelationEndpoint {
  const MonthEndpoint();

  @override
  RelationEndpointKind get kind => RelationEndpointKind.month;

  @override
  String get semanticId => 'month';

  @override
  Map<String, Object?> toJson() => {'kind': kind.machineName};

  @override
  bool operator ==(Object other) => other is MonthEndpoint;

  @override
  int get hashCode => semanticId.hashCode;

  @override
  String toString() => semanticId;
}

/// 日辰端点：**无 position**（它不是爻）。
class DayEndpoint extends RelationEndpoint {
  const DayEndpoint();

  @override
  RelationEndpointKind get kind => RelationEndpointKind.day;

  @override
  String get semanticId => 'day';

  @override
  Map<String, Object?> toJson() => {'kind': kind.machineName};

  @override
  bool operator ==(Object other) => other is DayEndpoint;

  @override
  int get hashCode => semanticId.hashCode;

  @override
  String toString() => semanticId;
}
