import 'package:flutter/material.dart';

class WuxingColors {
  static const Map<String, Color> mainColor = {
    '木': Color(0xFF2F8F5B),
    '火': Color(0xFFC0392B),
    '土': Color(0xFFB8863B),
    '金': Color(0xFFD6B46A),
    '水': Color(0xFF2F5F8F),
  };

  static const Map<String, Color> softColor = {
    '木': Color(0xFFE7F4EC),
    '火': Color(0xFFFBEAE7),
    '土': Color(0xFFF7EEDC),
    '金': Color(0xFFF8F0D8),
    '水': Color(0xFFE6EEF7),
  };

  static Color getColor(String wuxing) {
    return mainColor[wuxing] ?? const Color(0xFF3B2A1A);
  }

  static Color getSoftColor(String wuxing) {
    return softColor[wuxing] ?? const Color(0xFFFFF4DC);
  }

  static String? getWuxingByBranch(String branch) {
    const map = {
      '子': '水', '亥': '水',
      '寅': '木', '卯': '木',
      '巳': '火', '午': '火',
      '申': '金', '酉': '金',
      '辰': '土', '戌': '土', '丑': '土', '未': '土',
    };
    return map[branch];
  }

  static Color getColorByBranch(String branch) {
    final wuxing = getWuxingByBranch(branch);
    return wuxing != null ? getColor(wuxing) : const Color(0xFF3B2A1A);
  }

  static Color getSoftColorByBranch(String branch) {
    final wuxing = getWuxingByBranch(branch);
    return wuxing != null ? getSoftColor(wuxing) : const Color(0xFFFFF4DC);
  }

  static Color textOnColor(String wuxing) {
    final c = getColor(wuxing);
    return c.computeLuminance() > 0.5 ? const Color(0xFF3B2A1A) : Colors.white;
  }

  static Color textOnColorByBranch(String branch) {
    final wuxing = getWuxingByBranch(branch);
    return wuxing != null ? textOnColor(wuxing) : const Color(0xFF3B2A1A);
  }
}
