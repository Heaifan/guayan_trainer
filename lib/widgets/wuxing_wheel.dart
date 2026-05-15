import 'package:flutter/material.dart';

import '../theme/wuxing_colors.dart';

/// Five-element wheel selector for wuxing training.
///
/// Layout (positions are fixed for spatial memory):
///         木
///    水        火
///       金   土
class WuxingWheel extends StatelessWidget {
  final String? selected;
  final String? correctAnswer;
  final bool hasAnswered;
  final ValueChanged<String> onTap;

  const WuxingWheel({
    super.key,
    required this.selected,
    required this.correctAnswer,
    required this.hasAnswered,
    required this.onTap,
  });

  static const _elements = ['木', '火', '土', '金', '水'];

  /// Node center positions as fraction of container size.
  static const _positions = {
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
        final size = constraints.maxWidth;
        final nodeSize = size * 0.17;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: _elements.map((e) {
                final pos = _positions[e]!;
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
                    isSelected: selected == e,
                    isCorrect: correctAnswer == e,
                    hasAnswered: hasAnswered,
                    onTap: () => onTap(e),
                  ),
                );
              }).toList(),
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
  final bool hasAnswered;
  final VoidCallback onTap;

  const _NodeWidget({
    required this.element,
    required this.size,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = WuxingColors.getColor(element);
    final borderColor = WuxingColors.getBorderColor(element);
    final textColor = WuxingColors.textOnColor(element);

    final bool dimmed = hasAnswered && !isCorrect && !isSelected;

    return GestureDetector(
      onTap: hasAnswered ? null : onTap,
      child: AnimatedOpacity(
        opacity: dimmed ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: element == '金'
                  ? borderColor
                  : Colors.white,
              width: element == '金' ? 2.5 : 3.0,
            ),
            boxShadow: [
              // Outer ring colored border effect
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
              // Drop shadow
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
                decoration: element == '金'
                    ? TextDecoration.none
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
