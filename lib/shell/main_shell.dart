import 'package:flutter/material.dart';

import '../pages/home/home_page.dart';
import '../pages/study/study_page.dart';
import '../pages/practice/practice_page.dart';
import '../pages/review/review_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  void switchTab(int index) {
    if (index < 0 || index > 3) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onNavigateTab: switchTab),
      const StudyPage(),
      const PracticePage(),
      const ReviewPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: switchTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '首页'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: '学习'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), label: '练习'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), label: '回炉'),
        ],
      ),
    );
  }
}
