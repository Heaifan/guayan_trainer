import 'package:flutter/material.dart';

import '../../domain/hexagram_case.dart';
import 'more_menu.dart';
import 'navigation/guayan_main_tab_bar.dart';
import 'navigation/main_tabs.dart';
import '../presentation/casting/casting_page.dart';
import '../presentation/review/review_page.dart';

/// 卦眼 2.0 应用壳。
///
/// 持有唯一权威的底部导航状态 [AppShellState.selectedIndex]，
/// 通过 IndexedStack 保持五个主页面在切换时不被销毁。
/// 排卦页与审卦页自带 XYUI TopBar（无全局 AppBar）；其余页面沿用全局 AppBar。
/// 排卦生成结果经 [AppShellState._latestCase] 桥接给审卦页（T12 数据接入）。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  /// 底部导航唯一权威来源；默认进入排卦（Index 0）。
  int selectedIndex = 0;

  /// 最近一次排卦生成结果（排卦 → 审卦 数据桥接）。
  HexagramCase? _latestCase;

  @override
  Widget build(BuildContext context) {
    final useCustomTopBar = selectedIndex == 0 || selectedIndex == 1;
    return Scaffold(
      appBar: useCustomTopBar
          ? null
          : AppBar(
              title: Text(mainTabs[selectedIndex].title),
              actions: const [MoreMenuButton()],
            ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          CastingPage(
            onGenerated: (case_) {
              setState(() => _latestCase = case_);
            },
          ),
          ReviewPage(latestCase: _latestCase),
          for (final tab in mainTabs.skip(2)) tab.builder(context),
        ],
      ),
      bottomNavigationBar: GuayanMainTabBar(
        tabs: mainTabs,
        selectedIndex: selectedIndex,
        onSelect: (index) {
          setState(() => selectedIndex = index);
        },
      ),
    );
  }
}
