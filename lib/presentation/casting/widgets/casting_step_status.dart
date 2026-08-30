import 'package:flutter/material.dart';

import '../casting_tokens.dart';

/// 步骤状态徽标（任务书 SVG 中的小圆角标签）。
///
/// 视觉严格对齐 SVG：底色 + 文字，圆角 6，高 22。
class CastingStepStatus extends StatelessWidget {
  const CastingStepStatus({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.strong = false,
  });

  /// 徽标文字。
  final String label;

  final Color background;
  final Color foreground;

  /// 是否强调字重（当前步骤 CTA 使用 600）。
  final bool strong;

  const CastingStepStatus.complete(String label, {Key? key})
      : this(
          key: key,
          label: label,
          background: CastingTokens.badgeComplete,
          foreground: CastingTokens.accent,
        );

  const CastingStepStatus.pending(String label, {Key? key})
      : this(
          key: key,
          label: label,
          background: CastingTokens.badgePending,
          foreground: CastingTokens.textSecondary,
        );

  const CastingStepStatus.warning(String label, {Key? key})
      : this(
          key: key,
          label: label,
          background: CastingTokens.badgeWarning,
          foreground: CastingTokens.warningText,
        );

  const CastingStepStatus.locked(String label, {Key? key})
      : this(
          key: key,
          label: label,
          background: CastingTokens.badgeDefault,
          foreground: CastingTokens.textSecondary,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
          color: foreground,
          height: 1.2,
        ),
      ),
    );
  }
}

/// SVG 风格右侧 chevron（path: M276 38L281 43L276 48）。
class CastingChevron extends StatelessWidget {
  const CastingChevron({super.key, this.color = CastingTokens.textMuted});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(10, 14),
      painter: _ChevronPainter(color),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(0, 1)
      ..lineTo(size.width / 2, size.height / 2)
      ..lineTo(0, size.height - 1);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}
