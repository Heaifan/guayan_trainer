import 'package:flutter/material.dart';

import '../shared/module_placeholder.dart';

/// 卦例（Cases）Skeleton。
///
/// 未来负责：历史案例、搜索、收藏、复盘、后验。
class CasesPage extends StatelessWidget {
  const CasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: '卦例工作台',
      description: '历史案例、搜索、收藏、复盘与后验将在后续阶段实现。',
      features: ['历史案例', '搜索', '收藏', '复盘', '后验'],
    );
  }
}
