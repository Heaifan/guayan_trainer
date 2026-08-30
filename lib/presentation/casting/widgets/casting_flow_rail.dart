import 'package:flutter/material.dart';

import '../casting_tokens.dart';

/// 流程轨竖线（任务书 §5 CastingFlowRail SVG）。
///
/// 纵向贯穿全部步骤，是工作流状态的视觉连接，不是装饰。
class CastingFlowRail extends StatelessWidget {
  const CastingFlowRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 2, color: CastingTokens.rail);
  }
}
