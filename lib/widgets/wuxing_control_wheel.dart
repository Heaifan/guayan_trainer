import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/wuxing_colors.dart';
import 'wuxing_arrow_painter.dart';
import 'wuxing_control_arrow_painter.dart';

/// 五行相克五角星轮盘。
///
/// 学习页（autoPlay=true）：按 activeIndex 轮播，5 秒一条。
/// 练习页（autoPlay=false）：交互式点击答题，答题后显示箭头+特效。
class WuxingControlWheel extends StatefulWidget {
  final bool autoPlay;
  final int activeIndex;
  final String? selected;
  final String? correctAnswer;
  final bool hasAnswered;
  final String? sourceElement;
  final ValueChanged<String>? onTap;

  const WuxingControlWheel({
    super.key,
    this.autoPlay = false,
    this.activeIndex = 0,
    this.selected,
    this.correctAnswer,
    this.hasAnswered = false,
    this.sourceElement,
    this.onTap,
  });

  @override
  State<WuxingControlWheel> createState() => _WuxingControlWheelState();
}

class _WuxingControlWheelState extends State<WuxingControlWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  static const _elements = ['木', '火', '土', '金', '水'];

  static const Map<String, Offset> positions = {
    '木': Offset(0.50, 0.14),
    '火': Offset(0.84, 0.39),
    '土': Offset(0.71, 0.79),
    '金': Offset(0.29, 0.79),
    '水': Offset(0.16, 0.39),
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.autoPlay) _ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(WuxingControlWheel old) {
    super.didUpdateWidget(old);
    if (widget.autoPlay && old.activeIndex != widget.activeIndex) {
      _ctrl.forward(from: 0);
    }
    if (!widget.autoPlay && !old.hasAnswered && widget.hasAnswered) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// 当前高亮的边（练习答题后或学习页自播时）。
  WuxingEdge? get _activeEdge {
    if (widget.autoPlay && _ctrl.isAnimating && widget.activeIndex < 5) {
      return _controlEdges[widget.activeIndex];
    }
    if (!widget.autoPlay && widget.hasAnswered && widget.sourceElement != null && widget.correctAnswer != null) {
      return WuxingEdge(widget.sourceElement!, widget.correctAnswer!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final nodeSize = size * 0.17;
        final activeEdge = _activeEdge;

        final bool showArrow = widget.autoPlay
            ? (_ctrl.isAnimating && activeEdge != null)
            : (widget.hasAnswered && activeEdge != null);

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Control arrow layer
                if (showArrow)
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, _) => CustomPaint(
                      size: Size(size, size),
                      painter: WuxingControlArrowPainter(
                        activeEdge: activeEdge,
                        activeProgress: _anim.value,
                        containerSize: size,
                        nodeSize: nodeSize,
                      ),
                    ),
                  )
                else
                  // Static faint pentagram background
                  CustomPaint(
                    size: Size(size, size),
                    painter: WuxingControlArrowPainter(
                      containerSize: size,
                      nodeSize: nodeSize,
                    ),
                  ),

                // Node layer
                ..._elements.map((e) {
                  final pos = positions[e]!;
                  final left = pos.dx * size - nodeSize / 2;
                  final top = pos.dy * size - nodeSize / 2;
                  final isActive = activeEdge != null &&
                      (activeEdge.from == e || activeEdge.to == e);
                  final isDimmed = widget.autoPlay && !isActive;

                  return Positioned(
                    left: left, top: top,
                    width: nodeSize, height: nodeSize,
                    child: _ControlNode(
                      element: e,
                      size: nodeSize,
                      isDimmed: widget.autoPlay ? isDimmed : false,
                      isGlowing: isActive,
                      onTap: widget.autoPlay ? null : () => widget.onTap?.call(e),
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

const _controlEdges = [
  WuxingEdge('木', '土'),
  WuxingEdge('土', '水'),
  WuxingEdge('水', '火'),
  WuxingEdge('火', '金'),
  WuxingEdge('金', '木'),
];

class _ControlNode extends StatelessWidget {
  final String element;
  final double size;
  final bool isDimmed;
  final bool isGlowing;
  final VoidCallback? onTap;

  const _ControlNode({
    required this.element,
    required this.size,
    required this.isDimmed,
    required this.isGlowing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = WuxingColors.getColor(element);
    final bc = WuxingColors.getBorderColor(element);
    final tc = WuxingColors.textOnColor(element);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isDimmed ? 0.25 : 1.0,
        duration: const Duration(milliseconds: 400),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: isGlowing
                  ? const Color(0xFF9C3B2E)
                  : element == '金' ? bc : Colors.white,
              width: isGlowing ? 4.0 : element == '金' ? 2.5 : 3.0,
            ),
            boxShadow: [
              if (isGlowing)
                BoxShadow(
                  color: const Color(0xFF9C3B2E).withValues(alpha: 0.7),
                  blurRadius: 6,
                  spreadRadius: 4,
                )
              else
                BoxShadow(
                  color: bc.withValues(alpha: 0.5),
                  blurRadius: 0,
                  spreadRadius: 2.5,
                ),
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(element,
                style: TextStyle(
                    color: tc,
                    fontSize: size * 0.48,
                    fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }
}
