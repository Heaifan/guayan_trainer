import 'package:flutter/material.dart';

import '../../../app/more_menu.dart';
import '../casting_tokens.dart';

/// 排卦页顶部栏（任务书 §3 CastingTopBar SVG）。
///
/// 替代全局 AppBar：标题「排卦」+ 副标题 + 右侧三点（触发「更多」菜单）。
class CastingTopBar extends StatelessWidget {
  const CastingTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: CastingTokens.header,
        border: Border(bottom: BorderSide(color: CastingTokens.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '排卦',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: CastingTokens.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '一步一步完成，不丢上下文',
                  style: TextStyle(
                    fontSize: 10,
                    color: CastingTokens.textMuted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const MoreMenuButton(key: Key('casting_more_button'), icon: _CastingDots()),
        ],
      ),
    );
  }
}

/// SVG 风格三点（任务书 CastingTopBar：cx=357, cy=23/31/39, r=1.7）。
class _CastingDots extends StatelessWidget {
  const _CastingDots();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _DotsPainter(),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = CastingTokens.textSecondary;
    for (final dy in [7.0, 12.0, 17.0]) {
      canvas.drawCircle(Offset(12, dy), 1.7, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => false;
}
