library;

import '../rules/facts/semantic_ref.dart';

/// 卦盘对象类型。对象身份与运行时状态分离。
enum JudgementElementKind {
  originalLine,
  changedLine,
  hiddenSpirit,
  month,
  day,
}

/// 判定区标签 ID。后续状态/关系/资格只追加，不覆盖身份标签。
abstract final class JudgementTagIds {
  static const originalLine = 'identity.original_line';
  static const changedLine = 'identity.changed_line';
  static const hiddenSpirit = 'identity.hidden_spirit';
  static const month = 'identity.month';
  static const day = 'identity.day';
  static const moving = 'identity.moving';
  static const still = 'identity.still';

  static const hidden = 'state.hidden';
  static const kongWang = 'state.kong_wang';

  static const chong = 'state.chong';
  static const monthChong = 'state.month_chong';
  static const dayChong = 'state.day_chong';
  static const movingChong = 'state.moving_chong';
}

/// 单个卦盘对象的判定区。
///
/// 四区彼此独立：身份不会被状态覆盖，状态不会直接删除关系或资格。
class ElementJudgement {
  ElementJudgement({
    required this.ref,
    required this.kind,
    this.position,
    this.branch,
    Iterable<String> identityTags = const [],
    Iterable<String> stateTags = const [],
    Iterable<String> relationTags = const [],
    Iterable<String> qualificationTags = const [],
    Map<String, String> attributes = const {},
  })  : identityTags = Set.unmodifiable(identityTags),
        stateTags = Set.unmodifiable(stateTags),
        relationTags = Set.unmodifiable(relationTags),
        qualificationTags = Set.unmodifiable(qualificationTags),
        attributes = Map.unmodifiable(attributes);

  final SemanticRef ref;
  final JudgementElementKind kind;
  final int? position;
  final String? branch;

  final Set<String> identityTags;
  final Set<String> stateTags;
  final Set<String> relationTags;
  final Set<String> qualificationTags;
  final Map<String, String> attributes;

  bool hasIdentity(String tag) => identityTags.contains(tag);
  bool hasState(String tag) => stateTags.contains(tag);
  bool hasRelation(String tag) => relationTags.contains(tag);
  bool hasQualification(String tag) => qualificationTags.contains(tag);
}

/// 一次卦盘判定的不可变对象快照。
class ElementJudgementSnapshot {
  ElementJudgementSnapshot._(this._elements);

  factory ElementJudgementSnapshot(Iterable<ElementJudgement> elements) {
    final map = <SemanticRef, ElementJudgement>{};
    for (final element in elements) {
      if (map.containsKey(element.ref)) {
        throw StateError('重复卦盘对象身份: ${element.ref}');
      }
      map[element.ref] = element;
    }
    return ElementJudgementSnapshot._(Map.unmodifiable(map));
  }

  final Map<SemanticRef, ElementJudgement> _elements;

  Iterable<ElementJudgement> get elements => _elements.values;

  ElementJudgement? of(SemanticRef ref) => _elements[ref];

  Iterable<ElementJudgement> byKind(JudgementElementKind kind) =>
      _elements.values.where((element) => element.kind == kind);
}
