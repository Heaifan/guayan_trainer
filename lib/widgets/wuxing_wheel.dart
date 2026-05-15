import 'package:flutter/material.dart';

import '../theme/wuxing_colors.dart';
import 'wuxing_arrow_painter.dart';
import 'wuxing_effect_painter.dart';

/// Five-element wheel selector for wuxing training.
///
/// Layout (positions are fixed for spatial memory):
///         木
///    水        火
///       金   土
class WuxingWheel extends StatefulWidget {
  final String? selected;
  final String? correctAnswer;
  final bool hasAnswered;
  final String? sourceElement;
  final bool showArrow;
  final ValueChanged<String>? onTap;
  final bool showEffect;

  const WuxingWheel({
    super.key,
    required this.selected,
    required this.correctAnswer,
    required this.hasAnswered,
    this.sourceElement,
    this.showArrow = false,
    this.onTap,
    this.showEffect = false,
  });

  @override
  State<WuxingWheel> createState() => _WuxingWheelState();
}

class _WuxingWheelState extends State<WuxingWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  bool _wasAnswered = false;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _arrowAnimation = CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(WuxingWheel old) {
    super.didUpdateWidget(old);
    if (!_wasAnswered && widget.hasAnswered && widget.showArrow) {
      _arrowController.forward();
    }
    _wasAnswered = widget.hasAnswered;
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  static const _elements = ['木', '火', '土', '金', '水'];

  static const Map<String, Offset> positions = {
    '木': Offset(0.50, 0.14),
    '火': Offset(0.84, 0.39),
    '土': Offset(0.71, 0.79),
    '金': Offset(0.29, 0.79),
    '水': Offset(0.16, 0.39),
  };

  /// Whether this wheel should show the flame effect (木→火).
  bool get _showFlame {
    if (!widget.showEffect) return false;
    final src = widget.sourceElement;
    final tgt = widget.correctAnswer;
    return src == '木' && tgt == '火';
  }

  /// Position at 70% along source→target for the effect icon.
  Offset _effectPosition(double size) {
    if (widget.sourceElement == null || widget.correctAnswer == null) {
      return Offset(size * 0.5, size * 0.5);
    }
    final from = positions[widget.sourceElement]!;
    final to = positions[widget.correctAnswer]!;
    final mx = from.dx + (to.dx - from.dx) * 0.7;
    final my = from.dy + (to.dy - from.dy) * 0.7;
    return Offset(mx * size, my * size);
  }

  /// Flame size (relative to container)
  double _flameSize(double containerSize) => containerSize * 0.18;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final nodeSize = size * 0.17;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Arrow layer (behind nodes)
                if (widget.hasAnswered &&
                    widget.showArrow &&
                    widget.sourceElement != null &&
                    widget.correctAnswer != null)
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) {
                      // Flame effect opacity tied to arrow progress
                      final effectOpacity = _showFlame
                          ? ((_arrowAnimation.value - 0.3) / 0.7).clamp(0.0, 1.0)
                          : 0.0;
                      final effectPos = _effectPosition(size);

                      return CustomPaint(
                        size: Size(size, size),
                        painter: CombinedArrowPainter(
                          sourceElement: widget.sourceElement!,
                          targetElement: widget.correctAnswer!,
                          progress: _arrowAnimation.value,
                          containerSize: size,
                          nodeSize: nodeSize,
                          showFlame: _showFlame,
                          flameCenter: effectPos,
                          flameSize: _flameSize(size),
                          flameOpacity: effectOpacity,
                        ),
                      );
                    },
                  ),

                // Static effect for study page
                if (!widget.hasAnswered && _showFlame)
                  CustomPaint(
                    size: Size(size, size),
                    painter: FlameEffectPainter(
                      center: _effectPosition(size),
                      size: _flameSize(size),
                      opacity: 0.9,
                    ),
                  ),

                // Node layer
                ..._elements.map((e) {
                  final pos = positions[e]!;
                  final left = pos.dx * size - nodeSize / 2;
                  final top = pos.dy * size - nodeSize / 2;

                  return Positioned(
                    left: left,
                    top: top,
                    width: nodeSize,
                    height: nodeSize,
                    child: _NodeWidget(
                      element: e,
                      size: nodeSize,
                      isSelected: widget.selected == e,
                      isCorrect: widget.correctAnswer == e,
                      isSource: widget.sourceElement == e,
                      hasAnswered: widget.hasAnswered,
                      onTap: widget.onTap != null ? () => widget.onTap!(e) : null,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Combines arrow drawing + flame effect in one CustomPainter
/// so they share the same animation timing.
class CombinedArrowPainter extends CustomPainter {
  final String sourceElement;
  final String targetElement;
  final double progress;
  final double containerSize;
  final double nodeSize;
  final bool showFlame;
  final Offset flameCenter;
  final double flameSize;
  final double flameOpacity;

  CombinedArrowPainter({
    required this.sourceElement,
    required this.targetElement,
    required this.progress,
    required this.containerSize,
    required this.nodeSize,
    required this.showFlame,
    required this.flameCenter,
    required this.flameSize,
    required this.flameOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw arrow first
    final arrow = WuxingArrowPainter(
      sourceElement: sourceElement,
      targetElement: targetElement,
      progress: progress,
      containerSize: containerSize,
      nodeSize: nodeSize,
    );
    arrow.paint(canvas, size);

    // Draw flame overlay
    if (showFlame && flameOpacity > 0.01) {
      final flame = FlameEffectPainter(
        center: flameCenter,
        size: flameSize,
        opacity: flameOpacity,
      );
      flame.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(CombinedArrowPainter old) => old.progress != progress;
}

class _NodeWidget extends StatelessWidget {
  final String element;
  final double size;
  final bool isSelected;
  final bool isCorrect;
  final bool isSource;
  final bool hasAnswered;
  final VoidCallback? onTap;

  const _NodeWidget({
    required this.element,
    required this.size,
    required this.isSelected,
    required this.isCorrect,
    required this.isSource,
    required this.hasAnswered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = WuxingColors.getColor(element);
    final borderColor = WuxingColors.getBorderColor(element);
    final textColor = WuxingColors.textOnColor(element);

    final bool dimmed = hasAnswered && !isCorrect && !isSelected && !isSource;

    return GestureDetector(
      onTap: (hasAnswered || onTap == null) ? null : onTap,
      child: AnimatedOpacity(
        opacity: dimmed ? 0.35 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSource && hasAnswered
                  ? const Color(0xFF2F6F5E)
                  : element == '金'
                      ? borderColor
                      : Colors.white,
              width: isSource && hasAnswered ? 3.5 : element == '金' ? 2.5 : 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isCorrect && hasAnswered
                    ? const Color(0xFF2F6F5E).withValues(alpha: 0.8)
                    : isSelected && hasAnswered && !isCorrect
                        ? const Color(0xFFC0392B).withValues(alpha: 0.8)
                        : borderColor.withValues(alpha: 0.6),
                blurRadius: 0,
                spreadRadius: isCorrect && hasAnswered
                    ? 4
                    : isSelected && hasAnswered && !isCorrect
                        ? 4
                        : 2.5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              element,
              style: TextStyle(
                color: textColor,
                fontSize: size * 0.48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
