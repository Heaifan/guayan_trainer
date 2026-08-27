import 'package:flutter/material.dart';

import '../core/constants/app_info.dart';
import 'app_shell.dart';

/// 卦眼 2.0 应用根组件。
///
/// 只负责 MaterialApp 组装与全局主题，不持有导航状态。
class GuayanApp extends StatelessWidget {
  const GuayanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(AppInfo.seedColor)),
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
      ),
      home: const AppShell(),
    );
  }
}
