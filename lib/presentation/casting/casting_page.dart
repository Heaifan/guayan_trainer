import 'package:flutter/material.dart';

import 'casting_page_state.dart';
import 'casting_tokens.dart';
import 'widgets/casting_context_strip.dart';
import 'widgets/casting_flow_header.dart';
import 'widgets/casting_top_bar.dart';
import 'widgets/casting_workflow.dart';

/// 排卦页 —— 纵向排卦流程轨（GUAYAN-2.0 方案 2）。
///
/// 工作流：起卦时间 → 问事信息 → 六爻输入 → 规则包 → 生成排盘。
/// 状态进入真实 State（[CastingStepState]），不是从颜色反推。
///
/// 本轮为视觉阶段：步骤摘要为演示占位值，完整表单与排盘算法属后续阶段。
class CastingPage extends StatefulWidget {
  const CastingPage({super.key});

  @override
  State<CastingPage> createState() => _CastingPageState();
}

class _CastingPageState extends State<CastingPage> {
  static const _totalSteps = 5;

  /// 状态保持探针（Foundation §35 语义，保留在 Context Strip 中）。
  int _probeCount = 0;

  /// 已完成的输入步骤（前四步）。
  final Set<CastingStepId> _completed = {};

  /// 排盘是否已生成。
  bool _generated = false;

  /// 生成后关键数据被修改 → 需重新生成。
  bool _regenerateNeeded = false;

  static const _stepMeta = [
    (CastingStepId.time, '起卦时间', '记录起卦日期、时辰与来源', '2026-08-30 · 巳时'),
    (CastingStepId.question, '问事信息', '主题 / 对象 / 背景', '事业 · 项目发展'),
    (CastingStepId.lines, '六爻输入', '阴阳 / 动静 / 爻位', '6 / 6 · 动爻 2'),
    (CastingStepId.rules, '规则包', '默认规则 / 自定义规则', '默认规则包 · v1'),
  ];

  CastingFlowState _buildState() {
    final firstUnfinished =
        _stepMeta.indexWhere((m) => !_completed.contains(m.$1));
    final inputComplete = firstUnfinished == -1;

    final steps = <CastingStepData>[];
    for (var i = 0; i < _stepMeta.length; i++) {
      final (id, title, description, summary) = _stepMeta[i];
      final isCompleted = _completed.contains(id);
      steps.add(CastingStepData(
        id: id,
        index: i + 1,
        title: title,
        description: description,
        state: isCompleted
            ? CastingStepState.completed
            : (i == firstUnfinished
                ? CastingStepState.current
                : CastingStepState.pending),
        summary: isCompleted ? summary : null,
        badgeText: isCompleted
            ? '已完成'
            : (i == firstUnfinished ? '立即填写' : '待录入'),
      ));
    }

    final generateState = _generateState(inputComplete);
    steps.add(CastingStepData(
      id: CastingStepId.generate,
      index: 5,
      title: '生成排盘',
      description: '四步完成后生成本卦与变卦',
      state: generateState,
    ));

    final completedCount = _completed.length +
        (_generated && !_regenerateNeeded ? 1 : 0);

    return CastingFlowState(
      steps: steps,
      probeCount: _probeCount,
      completedCount: completedCount,
      currentIndex: inputComplete ? _totalSteps : firstUnfinished + 1,
      generated: _generated,
      regenerateNeeded: _regenerateNeeded,
    );
  }

  CastingStepState _generateState(bool inputComplete) {
    // 已生成：按「需重新生成」与否显示 Warning / Completed（任务书 §16：
    // 生成后关键数据被修改 → 标记需重新生成，不清空已有排盘）。
    if (_generated) {
      return _regenerateNeeded
          ? CastingStepState.warning
          : CastingStepState.completed;
    }
    return inputComplete
        ? CastingStepState.current
        : CastingStepState.locked;
  }

  void _onStepCta(CastingStepId id) {
    setState(() {
      _completed.add(id);
      if (_generated) _regenerateNeeded = true;
    });
  }

  void _onStepTap(CastingStepId id) {
    if (id == CastingStepId.generate) return;
    setState(() {
      if (_completed.remove(id) && _generated) {
        _regenerateNeeded = true;
      }
    });
  }

  void _onGenerate() {
    setState(() {
      _generated = true;
      _regenerateNeeded = false;
    });
  }

  void _onRegenerate() {
    setState(() {
      _generated = false;
      _regenerateNeeded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _buildState();

    return Scaffold(
      backgroundColor: CastingTokens.page,
      body: SafeArea(
        child: Column(
          children: [
            const CastingTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CastingFlowHeader(
                      currentIndex: state.currentIndex,
                      totalSteps: _totalSteps,
                    ),
                    const SizedBox(height: 12),
                    CastingWorkflow(
                      steps: state.steps,
                      onStepTap: _onStepTap,
                      onStepCta: _onStepCta,
                      onGenerate: _generated ? null : _onGenerate,
                      onRegenerate: _onRegenerate,
                    ),
                    const SizedBox(height: 12),
                    CastingContextStrip(
                      probeCount: state.probeCount,
                      completedCount: state.completedCount,
                      totalSteps: _totalSteps,
                      onProbeTap: () =>
                          setState(() => _probeCount++),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
