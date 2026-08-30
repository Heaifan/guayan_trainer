/// 卦中某一爻：稳定位置身份 + 记录的必要状态。
///
/// 明确区分：
/// - 爻的位置身份（初爻..上爻）—— 稳定定位信息，永不漂移；
/// - 爻当前的状态 —— 本轮只保留 Stable Relation Identity 需要的必要状态
///   （动爻判定 [MovementType.isMoving] 与所值地支 [LineState.branch]）。
/// 六亲/旺衰/旬空/六神等计算属性，待排盘引擎（R3）落地后再扩展。
library;

/// 爻象与动静：老阴/老阳为动爻。
enum MovementType {
  shaoYin('少阴', false),
  shaoYang('少阳', false),
  laoYin('老阴', true),
  laoYang('老阳', true);

  const MovementType(this.displayName, this.isMoving);

  /// 展示名（仅 UI 用，不参与任何身份构造）。
  final String displayName;

  /// 是否为动爻（老阴/老阳发动）。
  final bool isMoving;
}

class LineState {
  const LineState({
    required this.position,
    required this.movementType,
    this.branch,
  }) : assert(position >= 1 && position <= 6, '爻位必须在 1..6');

  /// 爻位：1 = 初爻 … 6 = 上爻（稳定身份）。
  final int position;

  final MovementType movementType;

  /// 所值地支。本阶段作为已记录状态输入；
  /// R3 排盘引擎落地后由纳甲计算产出，Domain 不关心其来源。
  final String? branch;

  Map<String, Object?> toJson() => {
        'position': position,
        'movementType': movementType.name,
        if (branch != null) 'branch': branch,
      };

  factory LineState.fromJson(Map<String, Object?> json) => LineState(
        position: json['position'] as int,
        movementType:
            MovementType.values.byName(json['movementType'] as String),
        branch: json['branch'] as String?,
      );

  @override
  String toString() =>
      'LineState(position: $position, movement: ${movementType.name})';
}
