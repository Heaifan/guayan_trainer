import 'package:flutter/material.dart';

import '../../presentation/cases/cases_page.dart';
import '../../presentation/casting/casting_page.dart';
import '../../presentation/relations/relations_page.dart';
import '../../presentation/review/review_page.dart';
import '../../presentation/training/training_page.dart';

/// 卦眼 2.0 主导航的正式产品 IA。
///
/// 顺序固定且不可更改：
/// Index 0 → 排卦
/// Index 1 → 审卦
/// Index 2 → 关系
/// Index 3 → 卦例
/// Index 4 → 训练
class MainTab {
  const MainTab({
    required this.title,
    required this.icon,
    required this.builder,
  });

  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

/// 主选项卡定义（构建器为闭包，故列表非 const）。
final List<MainTab> mainTabs = [
  MainTab(
    title: '排卦',
    icon: Icons.grid_view_rounded,
    builder: (context) => const CastingPage(),
  ),
  MainTab(
    title: '审卦',
    icon: Icons.visibility_rounded,
    builder: (context) => const ReviewPage(),
  ),
  MainTab(
    title: '关系',
    icon: Icons.hub_rounded,
    builder: (context) => const RelationsPage(),
  ),
  MainTab(
    title: '卦例',
    icon: Icons.library_books_rounded,
    builder: (context) => const CasesPage(),
  ),
  MainTab(
    title: '训练',
    icon: Icons.school_rounded,
    builder: (context) => const TrainingPage(),
  ),
];
