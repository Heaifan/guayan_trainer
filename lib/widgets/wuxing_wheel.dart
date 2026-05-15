import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/wuxing_colors.dart';
import 'wuxing_arrow_painter.dart';

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

  const WuxingWheel({
    super.key,
    required this.selected,
    required this.correctAnswer,
    required this.hasAnswered,
    this.sourceElement,
    this.showArrow = false,
    this.onTap,
  });

  @override
  State<WuxingWheel> createState() => _WuxingWheelState();
}

class _WuxingWheelState extends State<WuxingWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

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
  void didUpdateWidget(WuxingWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final questionChanged =
        oldWidget.sourceElement != widget.sourceElement ||
        oldWidget.correctAnswer != widget.correctAnswer;

    // Reset animation when question changes
    if (questionChanged) {
      _arrowController.reset();
    }

    // Start animation when newly answered
    if (!oldWidget.hasAnswered && widget.hasAnswered && widget.showArrow) {
      _arrowController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  static const _elements = ['木', '火', '土', '金', '水'];

  /// Node center positions as fraction of container size (shared with painter).
  static const Map<String, Offset> positions = {
    '木': Offset(0.50, 0.14),
    '火': Offset(0.84, 0.39),
    '土': Offset(0.71, 0.79),
    '金': Offset(0.29, 0.79),
    '水': Offset(0.16, 0.39),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
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
                      return CustomPaint(
                        size: Size(size, size),
                        painter: WuxingArrowPainter(
                          sourceElement: widget.sourceElement!,
                          targetElement: widget.correctAnswer!,
                          progress: _arrowAnimation.value,
                          containerSize: size,
                          nodeSize: nodeSize,
                        ),
                      );
                    },
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
