import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/relation_endpoint.dart';
import '../../../domain/relation_type.dart';
import '../../../domain/relations/relation_record.dart';
import '../relation_visual_tokens.dart';
import '../review_relation_filter.dart';

enum _Route { mainToMain, mainToChanged, changedToChanged, calendarToYao }

class RelationOverlay extends StatelessWidget {
  const RelationOverlay({
    super.key,
    required this.records,
    this.focus,
    this.selectedId,
    this.onRelationTap,
    this.anchorKeys = const {},
    this.category,
  });
  final List<RelationRecord> records;
  final RelationEndpoint? focus;
  final String? selectedId;
  final ValueChanged<String>? onRelationTap;
  final Map<String, GlobalKey> anchorKeys;
  final String? category;
  static List<RelationRecord> visibleRecords(
    Iterable<RelationRecord> records, {
    RelationEndpoint? focus,
    String? category,
  }) {
    if (focus == null) return const [];
    final result = filterReviewRelationRecords(
      records,
      focus: focus,
      category: category ?? '全部',
    );
    result.sort((a, b) => _rank(a) - _rank(b));
    return result;
  }

  static int _rank(RelationRecord r) => r.fromRef is MonthEndpoint
      ? 0
      : r.fromRef is DayEndpoint
      ? 1
      : r.sourceKind == RelationSourceKind.user
      ? 6
      : r.fromRef is YaoEndpoint &&
            (r.fromRef! as YaoEndpoint).scope == LineScope.changed
      ? 5
      : 4;
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      ignoring: onRelationTap == null,
      child: CustomPaint(
        painter: _Painter(
          visibleRecords(records, focus: focus, category: category),
          selectedId,
          anchorKeys,
          context,
        ),
      ),
    ),
  );
}

class _Painter extends CustomPainter {
  const _Painter(this.records, this.selectedId, this.anchorKeys, this.context);
  final List<RelationRecord> records;
  final String? selectedId;
  final Map<String, GlobalKey> anchorKeys;
  final BuildContext context;
  @override
  void paint(Canvas canvas, Size size) {
    final lanes = <_Route, int>{};
    for (var i = 0; i < records.length; i++) {
      final r = records[i];
      final type = r.relationType!;
      final route = _route(r);
      final lane = lanes[route] ?? 0;
      lanes[route] = lane + 1;
      final slotOffset = (lane - (lanes[route]! / 2)) * 3.0;
      final from = _anchor(r.fromRef!, route, slotOffset);
      final to = _anchor(r.toRef!, route, -slotOffset);
      if (from == null || to == null) continue;
      final active = selectedId == r.id;
      final paint = Paint()
        ..color = RelationVisualTokens.colorFor(
          type,
        ).withValues(alpha: active ? 1 : RelationVisualTokens.opacityAll)
        ..style = PaintingStyle.stroke
        ..strokeWidth = active
            ? RelationVisualTokens.strokeFocused
            : RelationVisualTokens.strokeNormal;
      final path = _path(from, to, route, lane, size);
      if (type == RelationType.liuChong) {
        final metric = path.computeMetrics().first;
        for (var d = 0.0; d < metric.length; d += 10) {
          canvas.drawPath(
            metric.extractPath(d, math.min(d + 5, metric.length)),
            paint,
          );
        }
      } else {
        canvas.drawPath(path, paint);
      }
      _drawPathArrow(canvas, path, paint.color, atEnd: true);
      if (RelationVisualTokens.isBidirectional(type)) {
        _drawPathArrow(canvas, path, paint.color, atEnd: false);
      }
      _label(canvas, type.displayName, _labelCenter(path, route), paint.color);
    }
  }

  _Route _route(RelationRecord r) {
    final a = r.fromRef!;
    final b = r.toRef!;
    if (a is MonthEndpoint ||
        a is DayEndpoint ||
        b is MonthEndpoint ||
        b is DayEndpoint) {
      return _Route.calendarToYao;
    }
    final ac = a is YaoEndpoint && a.scope == LineScope.changed;
    final bc = b is YaoEndpoint && b.scope == LineScope.changed;
    if (ac && bc) return _Route.changedToChanged;
    if (!ac && !bc) return _Route.mainToMain;
    return _Route.mainToChanged;
  }

  Offset? _anchor(RelationEndpoint endpoint, _Route route, double slotOffset) {
    final key = anchorKeys[endpoint.semanticId];
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final overlay = context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null || !box.hasSize) return null;
    final topLeft = overlay.globalToLocal(box.localToGlobal(Offset.zero));
    final rect = topLeft & box.size;
    if (endpoint is MonthEndpoint || endpoint is DayEndpoint) {
      return rect.center + Offset(0, slotOffset);
    }
    final changed =
        endpoint is YaoEndpoint && endpoint.scope == LineScope.changed;
    final useLeft = route == _Route.mainToMain
        ? true
        : route == _Route.changedToChanged
        ? false
        : changed;
    return Offset(
      useLeft ? rect.left : rect.right,
      rect.center.dy + slotOffset,
    );
  }

  Path _path(Offset from, Offset to, _Route route, int lane, Size size) {
    final spacing = 12.0;
    if (route == _Route.mainToChanged) {
      final bow = (lane - 1) * 8.0;
      return Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(
          from.dx + (to.dx - from.dx) * .34,
          from.dy + bow,
          from.dx + (to.dx - from.dx) * .66,
          to.dy + bow,
          to.dx,
          to.dy,
        );
    }
    final right = route == _Route.changedToChanged;
    final gutter = math.min(110.0, 18.0 + lane * spacing);
    final outer = route == _Route.calendarToYao
        ? (from.dx < to.dx ? 8.0 : size.width - 8.0)
        : right
        ? size.width - gutter
        : gutter;
    final sign = outer < from.dx ? -1.0 : 1.0;
    final bend = math.max(28.0, (from.dy - to.dy).abs() * .28);
    return Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx + sign * bend,
        from.dy,
        outer + sign * bend,
        to.dy,
        to.dx,
        to.dy,
      );
  }

  Offset _labelCenter(Path path, _Route route) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * .5)!;
    final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
    final direction = route == _Route.changedToChanged ? 1.0 : -1.0;
    return tangent.position + normal * (10 * direction);
  }

  void _label(Canvas canvas, String text, Offset center, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: RelationVisualTokens.relationLabelFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromCenter(
      center: center,
      width: tp.width + 12,
      height: RelationVisualTokens.relationLabelHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(RelationVisualTokens.relationLabelRadius),
      ),
      Paint()..color = const Color(0xFFFAF7F2).withValues(alpha: .08),
    );
    tp.paint(canvas, Offset(rect.left + 6, rect.top + 3));
  }

  void _drawPathArrow(
    Canvas canvas,
    Path path,
    Color color, {
    required bool atEnd,
  }) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(atEnd ? metric.length : 0);
    if (tangent == null) return;
    final tip = tangent.position;
    final vector = atEnd ? tangent.vector : -tangent.vector;
    final angle = math.atan2(vector.dy, vector.dx);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final a =
        tip -
        Offset(
          math.cos(angle - .55) * RelationVisualTokens.arrowSize,
          math.sin(angle - .55) * RelationVisualTokens.arrowSize,
        );
    final b =
        tip -
        Offset(
          math.cos(angle + .55) * RelationVisualTokens.arrowSize,
          math.sin(angle + .55) * RelationVisualTokens.arrowSize,
        );
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _Painter oldDelegate) =>
      oldDelegate.records != records || oldDelegate.selectedId != selectedId;
}
