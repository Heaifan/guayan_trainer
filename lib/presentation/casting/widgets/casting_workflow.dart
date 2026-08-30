import 'package:flutter/material.dart';

import '../casting_page_state.dart';
import 'casting_flow_rail.dart';
import 'casting_generate_step.dart';
import 'casting_step_card.dart';
import 'casting_step_node.dart';

/// 纵向流程轨工作区（任务书 §1 总 SVG 的 Flow Rail + 步骤卡区域）。
///
/// 左侧竖线贯穿全部步骤（CastingFlowRail），每行 = 节点 + 卡片。
/// 前四步为 [CastingStepCard]，第五步为 [CastingGenerateStep]。
class CastingWorkflow extends StatelessWidget {
  const CastingWorkflow({
    super.key,
    required this.steps,
    this.onStepTap,
    this.onStepCta,
    this.onGenerate,
    this.onRegenerate,
  });

  /// 五个步骤数据（顺序固定）。
  final List<CastingStepData> steps;

  /// 点击步骤卡片主体（重新进入 / 修改已完成步骤）。
  final ValueChanged<CastingStepId>? onStepTap;

  /// 点击当前步骤 CTA（「立即填写」推进）。
  final ValueChanged<CastingStepId>? onStepCta;

  final VoidCallback? onGenerate;
  final VoidCallback? onRegenerate;

  static const double _nodeColumnWidth = 56;
  static const double _rowGap = 12;

  @override
  Widget build(BuildContext context) {
    final inputSteps = steps.take(4).toList();
    final generate = steps[4];

    return Stack(
      children: [
        Positioned(
          left: (_nodeColumnWidth - 2) / 2,
          top: _rowGap,
          bottom: _rowGap,
          child: const CastingFlowRail(),
        ),
        Column(
          children: [
            for (final step in inputSteps)
              Padding(
                padding: const EdgeInsets.only(bottom: _rowGap),
                child: _StepRow(
                  node: CastingStepNode(data: step),
                  card: CastingStepCard(
                    data: step,
                    onTap: onStepTap == null
                        ? null
                        : () => onStepTap!(step.id),
                    onCta: (step.isCurrent && onStepCta != null)
                        ? () => onStepCta!(step.id)
                        : null,
                  ),
                ),
              ),
            _StepRow(
              node: CastingStepNode(data: generate),
              card: CastingGenerateStep(
                state: generate.state,
                onGenerate: onGenerate,
                onRegenerate: onRegenerate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.node, required this.card});

  final Widget node;
  final Widget card;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: CastingWorkflow._nodeColumnWidth,
          child: Center(child: node),
        ),
        Expanded(child: card),
      ],
    );
  }
}
