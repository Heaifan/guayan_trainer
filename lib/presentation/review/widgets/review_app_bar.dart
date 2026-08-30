import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';

/// 审卦页顶部栏（任务书 §1 AppBar SVG）。
///
/// 白底 + 底部分割线；左侧返回 chevron（矢量）、居中标题「审卦」+
/// 副标题「排盘结果」。属于审卦工作台自带顶栏（App Shell 对审卦不叠加全局
/// AppBar）。返回按钮仅在可 pop 时生效，主 Tab 场景下为装饰。
class ReviewAppBar extends StatelessWidget {
  const ReviewAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: CastingTokens.surface,
        border: Border(bottom: BorderSide(color: CastingTokens.divider)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          _BackButton(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '审卦',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: CastingTokens.textPrimary,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  '排盘结果',
                  style: TextStyle(
                    fontSize: 9,
                    color: CastingTokens.textMuted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 46), // 平衡左侧返回按钮宽度，保持标题居中
        ],
      ),
    );
  }
}

/// 矢量返回 chevron（‹，SVG §1 左侧箭头）。
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: InkWell(
        key: const Key('review_back_button'),
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
        child: const CustomPaint(
          size: Size(20, 20),
          painter: _BackChevronPainter(),
        ),
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  const _BackChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CastingTokens.textBody
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.75);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackChevronPainter oldDelegate) => false;
}
