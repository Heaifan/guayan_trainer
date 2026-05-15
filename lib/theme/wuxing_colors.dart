import 'package:flutter/material.dart';

class WuxingColors {
  /// Element main colors (matching HTML wheel design)
  static const Map<String, Color> mainColor = {
    '木': Color(0xFF528747),
    '火': Color(0xFFCE3E30),
    '土': Color(0xFFE1AC24),
    '金': Color(0xFFFFFFFF),
    '水': Color(0xFF3E7DBF),
  };

  /// Soft background tints
  static const Map<String, Color> softColor = {
    '木': Color(0xFFE7F4EC),
    '火': Color(0xFFFBEAE7),
    '土': Color(0xFFFFF2C2),
    '金': Color(0xFFF8F5EC),
    '水': Color(0xFFE6EEF7),
  };

  /// Border/ring colors for each element
  static const Map<String, Color> borderColor = {
    '木': Color(0xFF528747),
    '火': Color(0xFFCE3E30),
    '土': Color(0xFFE1AC24),
    '金': Color(0xFFD5B274),
    '水': Color(0xFF3E7DBF),
  };

  /// Text color for gold element (white bg needs dark text)
  static const Map<String, Color> textColor = {
    '木': Color(0xFFFFFFFF),
    '火': Color(0xFFFFFFFF),
    '土': Color(0xFFFFFFFF),
    '金': Color(0xFFA47631),
    '水': Color(0xFFFFFFFF),
  };

  static Color getColor(String wuxing) {
    return mainColor[wuxing] ?? const Color(0xFF3B2A1A);
  }

  static Color getSoftColor(String wuxing) {
    return softColor[wuxing] ?? const Color(0xFFFFF4DC);
  }

  static Color getBorderColor(String wuxing) {
    return borderColor[wuxing] ?? getColor(wuxing);
  }

  static Color getTextColor(String wuxing) {
    return textColor[wuxing] ?? Colors.white;
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
    return textColor[wuxing] ?? Colors.white;
  }

  static Color textOnColorByBranch(String branch) {
    final wuxing = getWuxingByBranch(branch);
    return wuxing != null ? textOnColor(wuxing) : const Color(0xFF3B2A1A);
  }
}
