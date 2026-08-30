import 'package:flutter/material.dart';

import '../casting_page_state.dart';
import '../casting_tokens.dart';

/// 流程轨左侧节点（任务书 §6 CastingStepNode 状态全集）。
///
/// Current 放大（r14）、Pending 收小（r12），Completed / Warning / Locked
/// 使用对应图形（对勾 / ! / 锁），全部为真实矢量绘制，不用 Unicode 占位。
class CastingStepNode extends StatelessWidget {
  const CastingStepNode({super.key, required this.data});

  final CastingStepData data;

  @override
  Widget build(BuildContext context) {
    final state = data.state;
    final radius = state == CastingStepState.current ? 14.0 : 12.0;
    final (background, stroke, glyph) = _visual(state);

    return SizedBox(
      width: radius * 2 + 4,
      height: radius * 2 + 4,
      child: Center(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            border: Border.all(color: stroke, width: 1.5),
          ),
          child: glyph,
        ),
      ),
    );
  }

  (Color, Color, Widget) _visual(CastingStepState state) {
    switch (state) {
      case CastingStepState.current:
        return (
          CastingTokens.active,
          const Color(0xFF8DB4A5),
          Center(
            child: Text(
              '${data.index}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: CastingTokens.textPrimary,
              ),
            ),
          ),
        );
      case CastingStepState.completed:
        return (
          CastingTokens.activeStrong,
          CastingTokens.borderActive,
          const Center(
            child: _CheckGlyph(key: Key('node-check')),
          ),
        );
      case CastingStepState.warning:
        return (
          CastingTokens.nodeWarning,
          CastingTokens.nodeWarningStroke,
          const Center(
            child: Text(
              '!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: CastingTokens.warningText,
              ),
            ),
          ),
        );
      case CastingStepState.locked:
        return (
          CastingTokens.nodeLocked,
          CastingTokens.nodeLockedStroke,
          const Center(
            child: _LockGlyph(key: Key('node-lock')),
          ),
        );
      case CastingStepState.pending:
        return (
          CastingTokens.nodePending,
          CastingTokens.rail,
          Center(
            child: Text(
              '${data.index}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: CastingTokens.textSecondary,
              ),
            ),
          ),
        );
    }
  }
}

/// SVG 对勾 path：M166 27L170 31L178 23。
class _CheckGlyph extends StatelessWidget {
  const _CheckGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 8),
      painter: _GlyphPainter((canvas, paint) {
        final path = Path()
          ..moveTo(0, 4)
          ..lineTo(4, 8)
          ..lineTo(12, 0);
        canvas.drawPath(path, paint);
      }),
    );
  }
}

/// SVG 锁：矩形 + 弧形锁梁。
class _LockGlyph extends StatelessWidget {
  const _LockGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(9, 11),
      painter: _GlyphPainter((canvas, paint) {
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 3.5, 9, 7),
          const Radius.circular(1.5),
        );
        canvas.drawRRect(body, paint);
        final shackle = Path()
          ..moveTo(1.2, 3.5)
          ..lineTo(1.2, 1.5)
          ..arcToPoint(const Offset(7.8, 1.5),
              radius: const Radius.circular(3.3), clockwise: false)
          ..lineTo(7.8, 3.5);
        canvas.drawPath(shackle, paint);
      }),
    );
  }
}

typedef _GlyphDraw = void Function(Canvas canvas, Paint paint);

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.draw);

  final _GlyphDraw draw;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CastingTokens.nodeLockedIcon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    draw(canvas, paint);
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) => true;
}
