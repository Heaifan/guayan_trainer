/// 排卦流程轨的状态模型（真实 ViewModel 数据，不是从颜色反推状态）。
library;

/// 工作流步骤状态（任务书 §16）。
enum CastingStepState {
  /// 当前正在进行的步骤（视觉上展开、可操作）。
  current,

  /// 等待后续进行的步骤（低存在感）。
  pending,

  /// 已完成（可重新进入修改，显示结果摘要）。
  completed,

  /// 需要检查（例如关键数据被修改后）。
  warning,

  /// 锁定（前序未完成，尚不可用）。
  locked,
}

/// 五个工作流步骤的稳定身份。
enum CastingStepId { time, question, lines, rules, generate }

/// 单个步骤的展示数据。
class CastingStepData {
  const CastingStepData({
    required this.id,
    required this.index,
    required this.title,
    required this.description,
    required this.state,
    this.summary,
    this.badgeText,
  });

  final CastingStepId id;

  /// 1..5（SVG 节点序号）。
  final int index;

  final String title;
  final String description;
  final CastingStepState state;

  /// 完成后的结果摘要（任务书 §9：完成态必须显示摘要，而不是简单写已完成）。
  final String? summary;

  /// 右侧状态徽标文字（立即填写 / 待录入 / 已完成 / 需检查 / 尚未就绪…）。
  final String? badgeText;

  bool get isCurrent => state == CastingStepState.current;

  bool get isCompleted => state == CastingStepState.completed;

  bool get isLocked => state == CastingStepState.locked;
}

/// 排卦流程的完整状态快照（纯数据，供页面与测试使用）。
class CastingFlowState {
  const CastingFlowState({
    required this.steps,
    required this.probeCount,
    required this.completedCount,
    required this.currentIndex,
    required this.generated,
    required this.regenerateNeeded,
  });

  /// 五个步骤（顺序固定：时间 / 问事 / 六爻 / 规则包 / 生成）。
  final List<CastingStepData> steps;

  /// 状态保持探针（Foundation §35 语义保留在 Context Strip 中）。
  final int probeCount;

  /// 已完成步骤数（含生成步骤）。
  final int completedCount;

  /// 当前步骤序号（1..5）。
  final int currentIndex;

  /// 排盘是否已生成。
  final bool generated;

  /// 生成后关键数据被修改 → 需重新生成。
  final bool regenerateNeeded;

  CastingStepData step(CastingStepId id) =>
      steps.firstWhere((s) => s.id == id);
}
