import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/wuxing_colors.dart';
import 'effects/generate_relation_effects_layer.dart';
import 'wuxing_arrow_painter.dart';

/// Five-element wheel selector.
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
  final bool autoPlayAccumulate;

  const WuxingWheel({
    super.key,
    required this.selected,
    required this.correctAnswer,
    required this.hasAnswered,
    this.sourceElement,
    this.showArrow = false,
    this.onTap,
    this.autoPlayAccumulate = false,
  });

  @override
  State<WuxingWheel> createState() => _WuxingWheelState();
}

class _WuxingWheelState extends State<WuxingWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  /// Accumulation-mode state
  int _activeEdgeIndex = 0;
  final List<WuxingEdge> _completedEdges = [];
  final Set<String> _activatedElements = {'木'};
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.addListener(_onTick);
    _ctrl.addStatusListener(_onStatus);
    if (widget.autoPlayAccumulate) _startCycle();
  }

  @override
  void didUpdateWidget(WuxingWheel old) {
    super.didUpdateWidget(old);
    if (!old.autoPlayAccumulate && widget.autoPlayAccumulate) _startCycle();
    final qc = old.sourceElement != widget.sourceElement ||
        old.correctAnswer != widget.correctAnswer;
    if (qc) _ctrl.reset();
    if (!old.hasAnswered && widget.hasAnswered && widget.showArrow) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _ctrl.removeListener(_onTick);
    _ctrl.removeStatusListener(_onStatus);
    _ctrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Accumulation logic
  // ---------------------------------------------------------------------------
  void _startCycle() {
    _autoTimer?.cancel();
    _completedEdges.clear();
    _activatedElements
      ..clear()
      ..add('木');
    _activeEdgeIndex = 0;
    _ctrl.forward(from: 0);
  }

  /// Fires every animation frame — used for 50% target activation and
  /// rebuilding the center effect visibility check.
  void _onTick() {
    if (!widget.autoPlayAccumulate) return;
    setState(() {
      if (_activeEdgeIndex >= generateEdges.length) return;
      if (_anim.value >= 0.5) {
        _activatedElements.add(generateEdges[_activeEdgeIndex].to);
      }
    });
  }

  /// Fires on status changes — used for edge-complete scheduling.
  void _onStatus(AnimationStatus status) {
    if (!widget.autoPlayAccumulate) return;
    if (status != AnimationStatus.completed) return;

    if (_activeEdgeIndex < generateEdges.length) {
      // Accumulate the just-completed edge
      setState(() {
        _completedEdges.add(generateEdges[_activeEdgeIndex]);
        _activeEdgeIndex++;
      });
    }

    if (_activeEdgeIndex >= generateEdges.length) {
      // All 5 edges done → pause, then reset
      _autoTimer?.cancel();
      _autoTimer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(_startCycle);
      });
    } else {
      // More edges to play → pause, then next
      _autoTimer?.cancel();
      _autoTimer = Timer(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        setState(() {});
        _ctrl.forward(from: 0);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  static const _elements = ['木', '火', '土', '金', '水'];

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

        // Practice mode (single arrow)
        final isPractice = !widget.autoPlayAccumulate &&
            widget.hasAnswered && widget.showArrow &&
            widget.sourceElement != null && widget.correctAnswer != null;

        // Accumulation: active edge only while actually animating
        final bool isAnimating = _ctrl.isAnimating;
        final WuxingEdge? activeEdge = widget.autoPlayAccumulate && isAnimating &&
                _activeEdgeIndex < generateEdges.length
            ? generateEdges[_activeEdgeIndex]
            : null;

        // Visible effect edges for the 5-slot layer
        final List<WuxingEdge> visibleEffectEdges = widget.autoPlayAccumulate
            ? ([..._completedEdges] +
                (activeEdge != null && _anim.value > 0.05
                    ? [activeEdge]
                    : []))
            : isPractice
                ? [WuxingEdge(widget.sourceElement!, widget.correctAnswer!)]
                : [];

        // Center title — follows activeEdge (not _activeEdgeIndex) so it
        // tracks the currently-animating edge, not the soon-to-play one.
        // Delayed until arrow progress >= 18% to avoid "text outruns arrow".
        final double activeProgress = _anim.value;
        final String? centerTitle;
        if (widget.autoPlayAccumulate && activeEdge != null) {
          centerTitle = '${activeEdge.from}生${activeEdge.to}';
        } else if (isPractice) {
          centerTitle = '${widget.sourceElement}生${widget.correctAnswer}';
        } else {
          centerTitle = null;
        }
        final bool showTitle = widget.autoPlayAccumulate
            ? activeEdge != null && activeProgress >= 0.18
            : isPractice;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // ---- Arrow layer ----
                if (isPractice)
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, _) => CustomPaint(
                      size: Size(size, size),
                      painter: WuxingArrowPainter(
                        completedEdges: const [],
                        activeEdge: WuxingEdge(
                            widget.sourceElement!, widget.correctAnswer!),
                        activeProgress: _anim.value,
                        containerSize: size,
                        nodeSize: nodeSize,
                      ),
                    ),
                  )
                else if (widget.autoPlayAccumulate)
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, _) => CustomPaint(
                      size: Size(size, size),
                      painter: WuxingArrowPainter(
                        completedEdges: _completedEdges,
                        activeEdge: activeEdge,
                        activeProgress: _anim.value,
                        containerSize: size,
                        nodeSize: nodeSize,
                      ),
                    ),
                  ),

                // ---- 5 fixed effect slots ----
                GenerateRelationEffectsLayer(
                  visibleEdges: visibleEffectEdges,
                  wheelSize: size,
                ),

                // ---- Node layer ----

                // ---- Center title (current relationship, topmost) ----
                Positioned(
                  left: 0,
                  right: 0,
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
                        color: const Color(0xFF2F6F5E),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
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
                    child: _NodeWidget(
                      element: e,
                      size: nodeSize,
                      isDimmed: isDimmed,
                      isCurrentSource: isCurSource,
                      isCurrentTarget: isCurTarget,
                      onTap: widget.autoPlayAccumulate || widget.onTap == null
                          ? null
                          : () => widget.onTap!(e),
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

// ---------------------------------------------------------------------------
// Node widget
// ---------------------------------------------------------------------------
class _NodeWidget extends StatelessWidget {
  final String element;
  final double size;
  final bool isDimmed;
  final bool isCurrentSource;
  final bool isCurrentTarget;
  final VoidCallback? onTap;

  const _NodeWidget({
    required this.element,
    required this.size,
    required this.isDimmed,
    required this.isCurrentSource,
    required this.isCurrentTarget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = WuxingColors.getColor(element);
    final bc = WuxingColors.getBorderColor(element);
    final tc = WuxingColors.textOnColor(element);

    final glow = isCurrentSource || isCurrentTarget;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isDimmed ? 0.25 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: glow ? const Color(0xFF2F6F5E) : element == '金' ? bc : Colors.white,
              width: glow ? 4.0 : element == '金' ? 2.5 : 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: glow
                    ? const Color(0xFF2F6F5E).withValues(alpha: 0.7)
                    : bc.withValues(alpha: 0.5),
                blurRadius: glow ? 6 : 0,
                spreadRadius: glow ? 4 : 2.5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(element,
                style: TextStyle(color: tc, fontSize: size * 0.48, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }
}
