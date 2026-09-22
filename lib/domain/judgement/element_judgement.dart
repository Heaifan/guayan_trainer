library;

import '../line_state.dart';
import '../rules/facts/semantic_ref.dart';

/// 卦盘对象类型。它描述“对象是谁”，不是状态标签。
enum JudgementElementKind {
  originalLine,
  changedLine,
  hiddenSpirit,
  month,
  day,
}

/// 状态标签 ID。
///
/// 约束：这里只允许放“对单个对象做状态判断后的结果”。
/// 六合、六冲、生、克、回头生、回头克等均属于关系账本，不得放入这里。
abstract final class JudgementStateIds {
  static const hidden = 'state.hidden';
  static const kongWang = 'state.kong_wang';

  static const chong = 'state.chong';
  static const monthChong = 'state.month_chong';
  static const dayChong = 'state.day_chong';
  static const movingChong = 'state.moving_chong';
}

/// 卦盘元素的结构身份。
///
/// 身份是稳定结构信息，不通过字符串标签表达。
class ElementIdentity {
  const ElementIdentity({
    required this.ref,
    required this.kind,
    this.position,
    this.movementType,
  });

  final SemanticRef ref;
  final JudgementElementKind kind;
  final int? position;

  /// 仅原卦爻使用。变爻、伏神、月、日不借此伪装成“动/静标签”。
  final MovementType? movementType;

  bool get isMovingOriginal =>
      kind == JudgementElementKind.originalLine &&
      movementType?.isMoving == true;

  bool get isStillOriginal =>
      kind == JudgementElementKind.originalLine &&
      movementType != null &&
      movementType!.isMoving == false;
}

/// 单个卦盘对象的判定结果。
///
/// - [identity]：对象是谁；
/// - [attributes]：地支、六亲等固有/记录属性；
/// - [states]：状态判断算法产出的状态标签；
///
/// 关系由 RelationInstance / RelationRecord 负责；
/// 行为与作用资格由后续 ActionResolution 负责，不进入本对象的状态标签。
class ElementJudgement {
  ElementJudgement({
    required this.identity,
    this.branch,
    Iterable<String> states = const [],
    Map<String, String> attributes = const {},
  })  : states = Set.unmodifiable(states),
        attributes = Map.unmodifiable(attributes);

  final ElementIdentity identity;
  final String? branch;
  final Set<String> states;
  final Map<String, String> attributes;

  SemanticRef get ref => identity.ref;
  JudgementElementKind get kind => identity.kind;
  int? get position => identity.position;
  MovementType? get movementType => identity.movementType;

  bool hasState(String state) => states.contains(state);
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
