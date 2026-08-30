import 'package:flutter/material.dart';

import 'more_menu.dart';
import 'navigation/guayan_main_tab_bar.dart';
import 'navigation/main_tabs.dart';

/// 卦眼 2.0 应用壳。
///
/// 持有唯一权威的底部导航状态 [AppShellState.selectedIndex]，
/// 通过 IndexedStack 保持五个主页面在切换时不被销毁。
/// 排卦页自带 XYUI TopBar（无全局 AppBar）；其余页面沿用全局 AppBar。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  /// 底部导航唯一权威来源；默认进入排卦（Index 0）。
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isCasting = selectedIndex == 0;
    return Scaffold(
      appBar: isCasting
          ? null
          : AppBar(
              title: Text(mainTabs[selectedIndex].title),
              actions: const [MoreMenuButton()],
            ),
      body: IndexedStack(
        index: selectedIndex,
        children: [for (final tab in mainTabs) tab.builder(context)],
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
