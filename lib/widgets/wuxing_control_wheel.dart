import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/wuxing_colors.dart';
import 'effects/control/control_relation_effects_layer.dart';
import 'wuxing_arrow_painter.dart';
import 'wuxing_control_arrow_painter.dart';

/// 五行相克五角星轮盘，自动累计播放。
///
/// Layout (same positions as generate wheel):
///         木
///    水        火
///       金   土
class WuxingControlWheel extends StatefulWidget {
  final bool autoPlayAccumulate;

  const WuxingControlWheel({
    super.key,
    this.autoPlayAccumulate = false,
  });

  @override
  State<WuxingControlWheel> createState() => _WuxingControlWheelState();
}

class _WuxingControlWheelState extends State<WuxingControlWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  // Accumulation state
  int _activeEdgeIndex = 0;
  final List<WuxingEdge> _completedEdges = [];
  final Set<String> _activatedElements = {'木'};
  Timer? _autoTimer;

  // Control edges in order
  static const _controlEdges = [
    WuxingEdge('木', '土'),
    WuxingEdge('土', '水'),
    WuxingEdge('水', '火'),
    WuxingEdge('火', '金'),
    WuxingEdge('金', '木'),
  ];

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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.addListener(_onTick);
    _ctrl.addStatusListener(_onStatus);
    if (widget.autoPlayAccumulate) _startCycle();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _ctrl.removeListener(_onTick);
    _ctrl.removeStatusListener(_onStatus);
    _ctrl.dispose();
    super.dispose();
  }

  void _startCycle() {
    _autoTimer?.cancel();
    _completedEdges.clear();
    _activatedElements..clear()..add('木');
    _activeEdgeIndex = 0;
    _ctrl.forward(from: 0);
  }

  void _onTick() {
    if (!widget.autoPlayAccumulate) return;
    setState(() {
      if (_activeEdgeIndex >= _controlEdges.length) return;
      if (_anim.value >= 0.5) {
        _activatedElements.add(_controlEdges[_activeEdgeIndex].to);
      }
    });
  }

  void _onStatus(AnimationStatus status) {
    if (!widget.autoPlayAccumulate) return;
    if (status != AnimationStatus.completed) return;

    if (_activeEdgeIndex < _controlEdges.length) {
      setState(() {
        _completedEdges.add(_controlEdges[_activeEdgeIndex]);
        _activeEdgeIndex++;
      });
    }

    if (_activeEdgeIndex >= _controlEdges.length) {
      _autoTimer?.cancel();
      _autoTimer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(_startCycle);
      });
    } else {
      _autoTimer?.cancel();
      _autoTimer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {});
        _ctrl.forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final nodeSize = size * 0.17;

        final bool isAnimating = _ctrl.isAnimating;
        final WuxingEdge? activeEdge = widget.autoPlayAccumulate && isAnimating &&
                _activeEdgeIndex < _controlEdges.length
            ? _controlEdges[_activeEdgeIndex]
            : null;

        // Visible effect edges for slot layer
        final List<WuxingEdge> visibleEffectEdges = [..._completedEdges] +
            (activeEdge != null && _anim.value > 0.05 ? [activeEdge] : []);

        // Center title
        final String? centerTitle = activeEdge != null
            ? '${activeEdge.from}克${activeEdge.to}'
            : null;
        final double activeProgress = _anim.value;
        final bool showTitle = activeEdge != null && activeProgress >= 0.18;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Control arrow layer
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, _) => CustomPaint(
                    size: Size(size, size),
                    painter: WuxingControlArrowPainter(
                      completedEdges: _completedEdges,
                      activeEdge: activeEdge,
                      activeProgress: _anim.value,
                      containerSize: size,
                      nodeSize: nodeSize,
                    ),
                  ),
                ),

                // 5 control effect slots
                ControlRelationEffectsLayer(
                  visibleEdges: visibleEffectEdges,
                  wheelSize: size,
                ),

                // Node layer
                ..._elements.map((e) {
                  final pos = positions[e]!;
                  final left = pos.dx * size - nodeSize / 2;
                  final top = pos.dy * size - nodeSize / 2;

                  final isActivated = _activatedElements.contains(e);
                  final isCurSource = activeEdge?.from == e;
                  final isCurTarget = activeEdge?.to == e && _anim.value >= 0.5;
                  final isDimmed = widget.autoPlayAccumulate && !isActivated;

                  return Positioned(
                    left: left, top: top,
                    width: nodeSize, height: nodeSize,
                    child: _ControlNode(
                      element: e,
                      size: nodeSize,
                      isDimmed: isDimmed,
                      isCurrentSource: isCurSource,
                      isCurrentTarget: isCurTarget,
                    ),
                  );
                }),

                // Center title (topmost)
                Positioned(
                  left: 0, right: 0,
                  top: size * 0.46,
                  child: AnimatedOpacity(
                    opacity: showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      centerTitle ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size * 0.075,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9C3B2E),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Control node (same visual as generate nodes but dims differently).
class _ControlNode extends StatelessWidget {
  final String element;
  final double size;
  final bool isDimmed;
  final bool isCurrentSource;
  final bool isCurrentTarget;

  const _ControlNode({
    required this.element,
    required this.size,
    required this.isDimmed,
    required this.isCurrentSource,
    required this.isCurrentTarget,
  });

  @override
  Widget build(BuildContext context) {
    final bg = WuxingColors.getColor(element);
    final bc = WuxingColors.getBorderColor(element);
    final tc = WuxingColors.textOnColor(element);
    final glow = isCurrentSource || isCurrentTarget;

    return AnimatedOpacity(
      opacity: isDimmed ? 0.25 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: glow
                ? const Color(0xFF9C3B2E)
                : element == '金' ? bc : Colors.white,
            width: glow ? 4.0 : element == '金' ? 2.5 : 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: glow
                  ? const Color(0xFF9C3B2E).withValues(alpha: 0.7)
                  : bc.withValues(alpha: 0.5),
              blurRadius: glow ? 6 : 0,
              spreadRadius: glow ? 4 : 2.5,
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
