import 'package:flutter/material.dart';

/// 排卦流程轨 XYUI 视觉 Token（对齐任务书 §18 与各 SVG）。
///
/// 所有排卦页组件统一引用本类颜色，禁止在 Widget 内散写色值。
/// 若后续项目引入全局 XYUI Token 体系，本类应迁移为对其的引用。
abstract final class CastingTokens {
  // 页面与面板
  static const page = Color(0xFFF6F8F7);
  static const header = Color(0xFFF0F4F3);
  static const panel = Color(0xFFFCFDFC);
  static const panelSubtle = Color(0xFFF9FBFA);

  // 激活态
  static const active = Color(0xFFD9EAE3);
  static const activeStrong = Color(0xFFDDEBE6);

  // 边框
  static const border = Color(0xFFD9E3DF);
  static const borderActive = Color(0xFFAFCBC0);
  static const rail = Color(0xFFC9D8D2);

  // 文字
  static const textPrimary = Color(0xFF243744);
  static const textSecondary = Color(0xFF5C6F7A);
  static const textMuted = Color(0xFF7C9099);
  static const accent = Color(0xFF406556);

  // 警示
  static const warningBackground = Color(0xFFFBF8F2);
  static const warningBorder = Color(0xFFE4D4BC);
  static const warningText = Color(0xFF9B7547);

  // 节点状态补充
  static const nodePending = Color(0xFFEEF3F2);
  static const nodeWarning = Color(0xFFF2ECE2);
  static const nodeWarningStroke = Color(0xFFCFB893);
  static const nodeLocked = Color(0xFFF0F2F1);
  static const nodeLockedStroke = Color(0xFFD7DEDB);
  static const nodeLockedIcon = Color(0xFF8C999E);
  static const nodeComplete = Color(0xFF406556);

  // 徽标
  static const badgePending = Color(0xFFEEF3F4);
  static const badgeComplete = Color(0xFFDDEBE6);
  static const badgeWarning = Color(0xFFF2E9DC);
  static const badgeDefault = Color(0xFFE7EFEA);

  // 生成步骤
  static const generateLocked = Color(0xFFF1F6F4);
  static const generateReady = Color(0xFFECF4F1);
  static const generateStrong = Color(0xFFD4E7DF);
  static const completedCard = Color(0xFFF7FAF8);
  static const completedStroke = Color(0xFFD8E5DF);
}
