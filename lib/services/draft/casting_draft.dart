/// 排卦草稿 —— 排卦页自动保存的持久化边界模型（任务书 §15）。
///
/// 本轮只有内存实现；接口边界（[DraftRepository]）与数据结构在此定型，
/// 后续接入本地存储时保证「历史草稿不丢规则版本信息（ruleRef）」。
library;

import '../../domain/line_state.dart';
import '../../domain/rule_execution_context.dart';

/// 一卦六爻 + 问事 + 起卦时间 + 规则版本的完整草稿快照。
class CastingDraft {
  const CastingDraft({
    this.questionTitle = '',
    this.questionBody = '',
    this.questionObject = '',
    this.questionNote = '',
    this.castingTime,
    this.lines = const [null, null, null, null, null, null],
    this.ruleRef = const RuleVersionRef('sys.default', 1),
  });

  /// 视觉定稿基准（任务书总 SVG）的演示初始草稿：
  /// 4/6 爻、两动爻、起卦时间与问事信息已完成、三爻为当前编辑爻。
  /// 正式版本可改为空草稿起步（构造 `CastingDraft()`）。
  factory CastingDraft.demo() => CastingDraft(
        questionTitle: '事业发展 · 项目推进',
        questionBody: '事业发展 · 项目推进是否顺利？',
        questionObject: '项目组',
        questionNote: '已补充对象、背景与补充说明',
        castingTime: DateTime(2026, 8, 30, 9, 30),
        lines: [
          LineState(position: 6, movementType: MovementType.shaoYin), // 上爻
          LineState(position: 5, movementType: MovementType.shaoYang), // 五爻
          LineState(position: 4, movementType: MovementType.laoYin), // 四爻
          LineState(position: 3, movementType: MovementType.laoYang), // 三爻
          null, // 二爻 待录
          null, // 初爻 待录
        ],
      );

  /// 主题标题（DraftContext 标题）。
  final String questionTitle;

  /// 问事正文。
  final String questionBody;

  /// 问事对象。
  final String questionObject;

  /// 背景 / 补充说明。
  final String questionNote;

  /// 起卦时间（含小时，用于时辰显示）；null = 未设置。
  final DateTime? castingTime;

  /// 六爻：index = position - 1（1 初爻 .. 6 上爻），null = 待录。
  final List<LineState?> lines;

  /// 规则包版本引用（历史卦例可追溯生成时规则版本，任务书 §13）。
  final RuleVersionRef ruleRef;
}
