import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/wuxing_colors.dart';
import 'wuxing_arrow_painter.dart';
import 'wuxing_control_arrow_painter.dart';

/// 五行相克五角星轮盘 — 单条轮播，不累计。
///
/// 每次只显示当前一条相克关系：高亮箭头 + 高亮节点。
/// 背景有五角星淡线作为参考地图。
class WuxingControlWheel extends StatefulWidget {
  final bool autoPlay;

  /// 当前正在播放的关系索引（由父组件控制）。
  final int activeIndex;

  const WuxingControlWheel({
    super.key,
    this.autoPlay = false,
    this.activeIndex = 0,
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
    // Reset animation when activeIndex changes
    if (old.activeIndex != widget.activeIndex && widget.autoPlay) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final nodeSize = size * 0.17;

        final isAnimating = _ctrl.isAnimating;
        final activeEdge = isAnimating && widget.activeIndex < 5
            ? _controlEdges[widget.activeIndex]
            : null;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Control arrow layer (faint pentagram + active arrow)
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
                      isDimmed: isDimmed,
                      isGlowing: isActive,
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

  const _ControlNode({
    required this.element,
    required this.size,
    required this.isDimmed,
    required this.isGlowing,
  });

  @override
  Widget build(BuildContext context) {
    final bg = WuxingColors.getColor(element);
    final bc = WuxingColors.getBorderColor(element);
    final tc = WuxingColors.textOnColor(element);

    return AnimatedOpacity(
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
    );
  }
}
