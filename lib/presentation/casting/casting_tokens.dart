import 'package:flutter/material.dart';

/// GUAYAN-2.0 排卦页 XYUI 视觉 Token（任务书 §3 核心 Token + 各组件 SVG）。
///
/// 所有排卦页组件与共享底部导航统一引用本类颜色，禁止在 Widget 内散写色值。
/// 值为任务书定稿值，若文字描述与 SVG 冲突以 SVG 为准。
abstract final class CastingTokens {
  // 页面与表面
  static const page = Color(0xFFF5F8F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF8FBF9);
  static const surfaceActive = Color(0xFFEEF5F1);

  // 边框与分割线
  static const border = Color(0xFFDCE5E1);
  static const borderActive = Color(0xFF91AC9D);
  static const divider = Color(0xFFE5ECE8);

  // 文字
  static const textPrimary = Color(0xFF243744);
  static const textBody = Color(0xFF405E6C);
  static const textSecondary = Color(0xFF71838B);
  static const textMuted = Color(0xFF7C8D94);

  // 强调色（Accent）
  static const accent = Color(0xFF567866);
  static const accentSurface = Color(0xFFE6F0EB);
  static const accentBorder = Color(0xFF83A491);

  // 完成态
  static const completeSurface = Color(0xFFEDF5F0);
  static const completeBorder = Color(0xFFAAC4B5);

  // 锁定态
  static const lockedSurface = Color(0xFFF1F4F3);
  static const lockedBorder = Color(0xFFD8E1DD);

  // 录入占位 chip
  static const chipSurface = Color(0xFFF3F7F5);
  static const chipBorder = Color(0xFFD6E1DC);

  // 当前编辑爻行
  static const editSurface = Color(0xFFF4FAF7);
  static const editBorder = Color(0xFF9FB7AA);

  // 爻线与动爻标记（老阴空心圆 / 老阳 X）
  static const yao = Color(0xFF243744);
  static const movingCircle = traditionalGold;

  // 关系 / 传统语义色（任务书 §4 补充 Token：Relation / Traditional / Pillar）
  static const relationRed = Color(0xFFB66F6F);
  static const relationRedSurface = Color(0xFFFAEFEF);
  static const relationRedBorder = Color(0xFFD9ABAB);
  static const relationBlue = Color(0xFF718AA5);
  static const relationBlueSurface = Color(0xFFEEF3F7);
  static const relationBlueBorder = Color(0xFFAFC0CF);
  static const traditionalGold = Color(0xFFB0905F);
  static const pillarTeal = Color(0xFF4F8685); // 四柱 teal（审卦一屏版总 SVG .teal）

  // 审卦一屏版（GUAYAN-2.0 审卦首屏总基准）补充色
  static const pillarWarm = Color(0xFFA8605C); // 月/日柱 warm（.warm）

  // R2 卦盘 / 爻 / 动爻定稿色（GUAYAN-2.0-UI-CORRECTION-R2 总 SVG）
  static const guaNameGold = Color(0xFF927848); // 卦名（.gua）
  static const spiritGold = Color(0xFFA17F45); // 六神（.spirit）与动爻圆（.moveO）
  static const shiYingRed = Color(0xFFA85F5F); // 世/应（.shi）
  static const voidYaoStroke = Color(0xFF7E9098); // 空亡爻描边（.yaoVoid）
  static const arrowTeal = Color(0xFF4F8685); // 动爻箭头（.arrow）
}
