import 'package:flutter/material.dart';

import '../casting_tokens.dart';

/// XYUI 圆角小徽标（任务书各 SVG 的 rx 11/12 小标签）。
///
/// 圆角 = 高度的一半（胶囊）；可点击时文字加粗并渲染 InkWell。
class CastingChip extends StatelessWidget {
  const CastingChip({
    super.key,
    required this.label,
    required this.background,
    required this.border,
    this.foreground = CastingTokens.textSecondary,
    this.fontSize = 10,
    this.width,
    this.height = 22,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color border;
  final Color foreground;
  final double fontSize;
  final double? width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;
    final chip = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: foreground,
          height: 1.1,
          fontWeight: onTap != null ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
    if (onTap == null) return chip;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: chip,
      ),
    );
  }
}

/// 矢量 chevron（›）。任务书要求图标一律矢量绘制，不使用 Unicode 充当图标。
class CastingChevron extends StatelessWidget {
  const CastingChevron({
    super.key,
    this.color = CastingTokens.textSecondary,
    this.size = const Size(8, 12),
  });

  final Color color;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: size, painter: _ChevronPainter(color));
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
