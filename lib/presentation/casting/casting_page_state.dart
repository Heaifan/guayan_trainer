/// 排卦页状态模型（纯 Dart，无 Flutter 依赖）。
///
/// 提供任务书 §7 要求的全部字段：questionTitle / questionDescription /
/// castingTime / rulePack / lines / movingLineCount / completedLineCount /
/// generationState / draftState。
library;

import '../../domain/hexagram_case.dart';
import '../../domain/line_state.dart';

/// 生成排盘状态（任务书 §14）。
enum GenerationState {
  /// 六爻未完整：尚未就绪。
  locked,

  /// 六爻完整：可以生成。
  ready,

  /// 已生成：排盘已生成，修改后不自动清空（标记需重新生成）。
  generated,
}

/// 草稿状态（本轮固定为草稿中：自动保存）。
enum DraftState { drafting }

/// 排卦页完整状态快照（纯数据，供页面与测试使用）。
class CastingPageState {
  const CastingPageState({
    required this.questionTitle,
    required this.questionBody,
    required this.questionObject,
    required this.questionNote,
    required this.castingTime,
    required this.rulePackName,
    required this.ruleVersion,
    required this.lines,
    required this.editingPosition,
    required this.generationState,
    required this.draftState,
    required this.regenerateNeeded,
    this.generatedCase,
  });

  final String questionTitle;
  final String questionBody;
  final String questionObject;
  final String questionNote;

  /// 起卦时间；null = 未设置。
  final DateTime? castingTime;

  /// 规则包名（如「默认规则包」）。
  final String rulePackName;

  /// 规则包版本（>= 1，历史卦例可追溯，任务书 §13）。
  final int ruleVersion;

  /// 六爻：index = position - 1（1 初爻 .. 6 上爻），null = 待录。
  final List<LineState?> lines;

  /// 当前编辑爻位（1..6），null = 无。
  final int? editingPosition;

  final GenerationState generationState;
  final DraftState draftState;

  /// 生成后关键数据被修改 → 需重新生成（不清空已生成排盘）。
  final bool regenerateNeeded;

  /// 生成成功后的卦例（连接 Domain：HexagramCase 六爻不变量 + 规则版本上下文）。
  final HexagramCase? generatedCase;

  String get rulePackVersionLabel => 'v$ruleVersion';

  String get rulePackLabel => '$rulePackName · $rulePackVersionLabel';

  int get completedLineCount => lines.where((l) => l != null).length;

  int get movingLineCount =>
      lines.where((l) => l != null && l.movementType.isMoving).length;

  bool get isLinesComplete => completedLineCount == 6;

  bool get isTimeSet => castingTime != null;

  bool get isQuestionComplete => questionTitle.trim().isNotEmpty;

  LineState? lineAt(int position) => lines[position - 1];
}

/// 爻位展示名（1 初爻 .. 6 上爻）。
String linePositionName(int position) {
  const names = {1: '初爻', 2: '二爻', 3: '三爻', 4: '四爻', 5: '五爻', 6: '上爻'};
  return names[position] ?? '爻';
}

/// 时辰名（两小时一辰）。仅小时 → 时辰的基础映射；
/// 完整干支历法（年月日干支 / 旬空 / 纳甲）属后续排盘引擎，不在本轮范围。
String shichenForHour(int hour) {
  const names = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
  return names[((hour + 1) % 24) ~/ 2];
}

/// 农历占位展示（GAP：真实农历换算属后续排盘引擎，本轮不做假算法）。
///
/// 仅提供 presentation mock：按公历日期 + 时辰生成占位文本，
/// 明确标注「农历换算待接入」，不得伪装成真实换算结果。
/// 未来接入排盘引擎后替换为本 helper 的实现即可，UI 签名不变。
String lunarPlaceholder(DateTime time) {
  final shichen = shichenForHour(time.hour);
  return '农历：${time.year}年${time.month}月${time.day}日 '
      '$shichen时 · 农历换算待接入';
}

/// 爻象的「阴阳 · 动静」展示文案（如「阴 · 静」「阳 · 动」）。
String movementDisplay(MovementType type) {
  final yin = type == MovementType.shaoYin || type == MovementType.laoYin;
  return '${yin ? '阴' : '阳'} · ${type.isMoving ? '动' : '静'}';
}

/// 已录一爻的「阴阳 · 动静」展示文案。
String lineStatusText(LineState line) => movementDisplay(line.movementType);
