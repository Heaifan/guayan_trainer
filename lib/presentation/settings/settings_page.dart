import 'package:flutter/material.dart';

/// 设置（Settings）Skeleton。
///
/// 本阶段仅占位，设置项将在后续阶段按需加入。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: const Center(
        child: Text('设置项将在后续阶段提供。'),
      ),
    );
  }
}
