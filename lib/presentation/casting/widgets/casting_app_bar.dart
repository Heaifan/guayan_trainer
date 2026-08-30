import 'package:flutter/material.dart';

import '../../../app/more_menu.dart';
import '../casting_tokens.dart';

/// 排卦页顶部栏（任务书 §5.1 AppBar SVG）。
///
/// 白底 + 底部分割线；标题「卦眼」+ 副标题「排卦」+ 右侧三点（更多菜单）。
/// 仅排卦页使用（App Shell 对其余页面使用全局 AppBar）。
class CastingAppBar extends StatelessWidget {
  const CastingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: CastingTokens.surface,
        border: Border(bottom: BorderSide(color: CastingTokens.divider)),
      ),
      child: Row(
        children: [
          const Text(
            '卦眼',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CastingTokens.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '排卦',
            style: TextStyle(
              fontSize: 10,
              color: CastingTokens.textSecondary,
              height: 1.4,
            ),
          ),
          const Spacer(),
          const MoreMenuButton(
            key: Key('casting_more_button'),
            icon: _DotsGlyph(),
          ),
        ],
      ),
    );
  }
}

/// SVG 三点（AppBar：cx 394/402/410 cy 50 r2，等比缩放）。
class _DotsGlyph extends StatelessWidget {
  const _DotsGlyph();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(18, 18),
      painter: _DotsPainter(),
    );
  }
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = CastingTokens.textBody;
    const r = 2.0;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(size.width / 2 - 8, cy), r, paint);
    canvas.drawCircle(Offset(size.width / 2, cy), r, paint);
    canvas.drawCircle(Offset(size.width / 2 + 8, cy), r, paint);
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => false;
}
