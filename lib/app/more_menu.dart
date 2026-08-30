import 'package:flutter/material.dart';

import '../presentation/about/about_page.dart';
import '../presentation/rules/rule_library_page.dart';
import '../presentation/settings/settings_page.dart';

/// AppBar 右上角「更多」入口。
///
/// 规则库位于此处，而不是底部主导航。
class MoreMenuButton extends StatelessWidget {
  const MoreMenuButton({super.key, this.icon});

  /// 自定义图标（排卦页使用 XYUI 三点样式时传入）。
  final Widget? icon;

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: icon ?? const Icon(Icons.more_vert),
      tooltip: '更多',
      onSelected: (value) {
        switch (value) {
          case 'rules':
            _open(context, const RuleLibraryPage());
          case 'settings':
            _open(context, const SettingsPage());
          case 'about':
            _open(context, const AboutPage());
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'rules', child: Text('规则库')),
        PopupMenuItem(value: 'settings', child: Text('设置')),
        PopupMenuItem(value: 'about', child: Text('关于')),
      ],
    );
  }
}
