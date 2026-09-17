import 'package:flutter/material.dart';
import '../../../domain/relation_type.dart';
import '../../review/relation_visual_tokens.dart';

class RelationGlyph extends StatelessWidget {
  const RelationGlyph({super.key, required this.type});

  final RelationType type;

  @override
  Widget build(BuildContext context) {
    final color = RelationVisualTokens.colorFor(type);
    return SizedBox(
      key: const Key('relation_glyph'),
      width: 78,
      height: 35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
            child: Text(
              type.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 2),
          CustomPaint(
            key: const Key('relation_glyph_arrow'),
            size: const Size(78, 18),
            painter: _RelationGlyphPainter(
              color: color,
              bidirectional: RelationVisualTokens.isBidirectional(type),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationGlyphPainter extends CustomPainter {
  const _RelationGlyphPainter({
    required this.color,
    required this.bidirectional,
  });

  final Color color;
  final bool bidirectional;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = RelationVisualTokens.strokeNormal
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    final left = 7.0;
    final right = size.width - 7.0;
    canvas.drawLine(Offset(left, y), Offset(right, y), paint);
    _arrow(canvas, Offset(right, y), false, paint);
    if (bidirectional) _arrow(canvas, Offset(left, y), true, paint);
  }

  void _arrow(Canvas canvas, Offset tip, bool reverse, Paint paint) {
    final direction = reverse ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(
        tip.dx + direction * RelationVisualTokens.arrowSize,
        tip.dy - 3.2,
      )
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx + direction * RelationVisualTokens.arrowSize,
        tip.dy + 3.2,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RelationGlyphPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.bidirectional != bidirectional;
}
