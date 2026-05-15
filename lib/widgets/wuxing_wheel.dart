import 'dart:async';
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

// ---------------------------------------------------------------------------
// Accumulation data
// ---------------------------------------------------------------------------
const _generateCycle = [
  GenerateEdge('木', '火'),
  GenerateEdge('火', '土'),
  GenerateEdge('土', '金'),
  GenerateEdge('金', '水'),
  GenerateEdge('水', '木'),
];

class _WuxingWheelState extends State<WuxingWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  // Accumulation mode state
  int _edgeIndex = 0;
  List<GenerateEdge> _completedEdges = [];
  Timer? _loopTimer;

  /// Elements that are currently "activated" (highlighted).
  Set<String> _activeElements = {};

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _arrowAnimation = CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    );
    _arrowController.addListener(_onArrowTick);

    if (widget.autoPlayAccumulate) {
      _startAccumulation();
    }
  }

  @override
  void didUpdateWidget(WuxingWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.autoPlayAccumulate && widget.autoPlayAccumulate) {
      _startAccumulation();
    }

    // Practice mode
    final qChanged = oldWidget.sourceElement != widget.sourceElement ||
        oldWidget.correctAnswer != widget.correctAnswer;
    if (qChanged) _arrowController.reset();
    if (!oldWidget.hasAnswered && widget.hasAnswered && widget.showArrow) {
      _arrowController.forward(from: 0);
    }
  }

  // -----------------------------------------------------------------------
  // Accumulation logic
  // -----------------------------------------------------------------------
  void _startAccumulation() {
    _edgeIndex = 0;
    _completedEdges = [];
    _activeElements = {'木'}; // first source is always highlighted
    _arrowController.forward(from: 0);
  }

  void _onArrowTick() {
    if (!widget.autoPlayAccumulate) return;

    // Activate target node at 50% progress
    if (_edgeIndex < _generateCycle.length) {
      final edge = _generateCycle[_edgeIndex];
      if (_arrowAnimation.value >= 0.5) {
        _activeElements = {..._activeElements, edge.to};
      }
    }

    // Edge complete → accumulate
    if (_arrowController.isCompleted) {
      if (_edgeIndex < _generateCycle.length) {
        _completedEdges = [..._completedEdges, _generateCycle[_edgeIndex]];
        _edgeIndex++;
      }

      if (_edgeIndex >= _generateCycle.length) {
        // All 5 edges done → pause then restart
        _loopTimer?.cancel();
        _loopTimer = Timer(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(_startAccumulation);
        });
      } else {
        // More edges to play → short pause then next
        _loopTimer?.cancel();
        _loopTimer = Timer(const Duration(milliseconds: 350), () {
          if (!mounted) return;
          setState(() {
            _activeElements = {..._activeElements, _generateCycle[_edgeIndex - 1].to};
          });
          _arrowController.forward(from: 0);
        });
      }
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _arrowController.removeListener(_onArrowTick);
    _arrowController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------
  static const _elements = ['木', '火', '土', '金', '水'];

  static const Map<String, Offset> positions = {
    '木': Offset(0.50, 0.14),
    '火': Offset(0.84, 0.39),
    '土': Offset(0.71, 0.79),
    '金': Offset(0.29, 0.79),
    '水': Offset(0.16, 0.39),
  };

  GenerateEdge? get _activeEdge =>
      _edgeIndex < _generateCycle.length ? _generateCycle[_edgeIndex] : null;

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final nodeSize = size * 0.17;

        // Practice mode: single arrow
        final isPractice = !widget.autoPlayAccumulate &&
            widget.hasAnswered &&
            widget.showArrow &&
            widget.sourceElement != null &&
            widget.correctAnswer != null;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // ── Arrow layer ──
                if (isPractice)
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) => CustomPaint(
                      size: Size(size, size),
                      painter: WuxingArrowPainter(
                        completedEdges: const [],
                        activeEdge: GenerateEdge(
                            widget.sourceElement!, widget.correctAnswer!),
                        activeProgress: _arrowAnimation.value,
                        containerSize: size,
                        nodeSize: nodeSize,
                      ),
                    ),
                  )
                else if (widget.autoPlayAccumulate)
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) => CustomPaint(
                      size: Size(size, size),
                      painter: WuxingArrowPainter(
                        completedEdges: _completedEdges,
                        activeEdge: _activeEdge,
                        activeProgress: _arrowAnimation.value,
                        containerSize: size,
                        nodeSize: nodeSize,
                      ),
                    ),
                  ),

                // ── Node layer ──
                ..._elements.map((e) {
                  final pos = positions[e]!;
                  final left = pos.dx * size - nodeSize / 2;
                  final top = pos.dy * size - nodeSize / 2;

                  final isActive = _activeElements.contains(e);
                  final isCurrentSource = widget.autoPlayAccumulate &&
                      _activeEdge != null &&
                      _activeEdge!.from == e;
                  final isCurrentTarget = widget.autoPlayAccumulate &&
                      _activeEdge != null &&
                      _activeEdge!.to == e &&
                      _arrowAnimation.value >= 0.5;

                  return Positioned(
                    left: left,
                    top: top,
                    width: nodeSize,
                    height: nodeSize,
                    child: _NodeWidget(
                      element: e,
                      size: nodeSize,
                      isActive: isActive,
                      isCurrentSource: isCurrentSource,
                      isCurrentTarget: isCurrentTarget,
                      hasAnswered: widget.hasAnswered || widget.autoPlayAccumulate,
                      onTap: (widget.autoPlayAccumulate || widget.onTap == null)
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
  final bool isActive;
  final bool isCurrentSource;
  final bool isCurrentTarget;
  final bool hasAnswered;
  final VoidCallback? onTap;

  const _NodeWidget({
    required this.element,
    required this.size,
    required this.isActive,
    required this.isCurrentSource,
    required this.isCurrentTarget,
    required this.hasAnswered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = WuxingColors.getColor(element);
    final borderColor = WuxingColors.getBorderColor(element);
    final textColor = WuxingColors.textOnColor(element);

    // Dim if not active and in accumulation mode
    final bool dimmed = hasAnswered && !isActive;

    return GestureDetector(
      onTap: (hasAnswered || onTap == null) ? null : onTap,
      child: AnimatedOpacity(
        opacity: dimmed ? 0.30 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentSource
                  ? const Color(0xFF2F6F5E)
                  : isCurrentTarget
                      ? const Color(0xFF2F6F5E)
                      : element == '金'
                          ? borderColor
                          : Colors.white,
              width: isCurrentSource
                  ? 4.0
                  : isCurrentTarget
                      ? 4.0
                      : element == '金'
                          ? 2.5
                          : 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isCurrentSource
                    ? const Color(0xFF2F6F5E).withValues(alpha: 0.7)
                    : isCurrentTarget
                        ? const Color(0xFF2F6F5E).withValues(alpha: 0.7)
                        : borderColor.withValues(alpha: 0.5),
                blurRadius: isCurrentSource || isCurrentTarget ? 6 : 0,
                spreadRadius: isCurrentSource || isCurrentTarget ? 4 : 2.5,
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
