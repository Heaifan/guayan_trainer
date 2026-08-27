import 'package:flutter/material.dart';

import '../shared/module_placeholder.dart';

/// 审卦（Review）Skeleton。
///
/// 未来负责：完整排盘、关系连线、关系聚焦、关系筛选。
/// 本阶段不实现 CustomPainter。
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: '审卦工作台',
      description: '完整排盘、关系连线、聚焦与筛选将在后续阶段实现。',
      features: ['完整排盘', '关系连线', '关系聚焦', '关系筛选'],
    );
  }
}
