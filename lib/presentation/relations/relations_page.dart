import 'package:flutter/material.dart';

import '../shared/module_placeholder.dart';

/// 关系（Relations）Skeleton。
///
/// 未来负责：关系总账、统计、对象筛选、Relation Note。
/// 本阶段不得提前建立关系算法。
class RelationsPage extends StatelessWidget {
  const RelationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: '关系工作台',
      description: '关系总账、统计、对象筛选与关系笔记将在后续阶段实现。',
      features: ['关系总账', '关系类型统计', '对象筛选', '关系笔记'],
    );
  }
}
