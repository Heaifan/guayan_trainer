import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/relation_endpoint.dart';
import '../../../domain/relation_type.dart';
import '../../../domain/relations/relation_record.dart';
import '../back_relation_glyph.dart';
import '../relation_route_layout.dart';
import '../relation_route_path.dart';
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
    this.rowKeys = const {},
    this.category,
  });
  final List<RelationRecord> records;
  final RelationEndpoint? focus;
  final String? selectedId;
  final ValueChanged<String>? onRelationTap;
  final Map<String, GlobalKey> anchorKeys;
  final Map<int, GlobalKey> rowKeys;
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
          rowKeys,
          context,
        ),
      ),
    ),
  );
}

class _Painter extends CustomPainter {
  const _Painter(
    this.records,
    this.selectedId,
    this.anchorKeys,
    this.rowKeys,
    this.context,
  );
  final List<RelationRecord> records;
  final String? selectedId;
  final Map<String, GlobalKey> anchorKeys;
  final Map<int, GlobalKey> rowKeys;
  final BuildContext context;
  @override
  void paint(Canvas canvas, Size size) {
    for (final r in records.where(_isBackRelation)) {
      _drawBackHook(canvas, r);
    }
    final backPositions = records
        .where(_isBackRelation)
        .map(_originalPosition)
        .whereType<int>()
        .toSet();
    final placements = {
      for (final placement in RelationRouteLayout.layout(
        records.where(
          (record) =>
              !_isBackRelation(record) &&
              !_isMovingRelationAt(record, backPositions),
        ),
      ))
        placement.id: placement,
    };
    for (final r in records) {
      if (_isBackRelation(r) || _isMovingRelationAt(r, backPositions)) continue;
      final type = r.relationType!;
      final route = _route(r);
      final placement = placements[r.id];
      if (placement == null) continue;
      final slotOffset = placement.branchOffset;
      final from = _anchor(r.fromRef!, route, slotOffset);
      final to = _anchor(r.toRef!, route, -slotOffset);
      if (from == null || to == null) continue;
      final active = selectedId == r.id;
      final color = RelationVisualTokens.colorFor(type);
      final paint = Paint()
        ..color = color.withValues(
          alpha: active
              ? RelationVisualTokens.opacityFocused
              : RelationVisualTokens.opacityAll,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = active
            ? RelationVisualTokens.strokeFocused
            : RelationVisualTokens.strokeNormal;
      final path = buildRelationRoutePath(
        from: from,
        to: to,
        route: _routeKind(route),
        trunkLane: placement.trunkLane,
        branchOffset: placement.branchOffset,
        viewportWidth: size.width,
      );
      _drawStyledPath(canvas, path, type, paint);
      _drawPathArrow(canvas, path, paint.color, atEnd: true, active: active);
      if (RelationVisualTokens.isBidirectional(type)) {
        _drawPathArrow(canvas, path, paint.color, atEnd: false, active: active);
      }
      if (active) {
        canvas.drawCircle(
          from,
          RelationVisualTokens.anchorRadius,
          Paint()..color = color,
        );
        canvas.drawCircle(
          to,
          RelationVisualTokens.anchorRadius,
          Paint()..color = color,
        );
      }
      _label(canvas, type.displayName, _labelCenter(path, route), paint.color);
    }
  }

  void _drawStyledPath(
    Canvas canvas,
    Path path,
    RelationType type,
    Paint paint,
  ) {
    final metric = path.computeMetrics().first;
    if (type == RelationType.liuChong || RelationVisualTokens.isDashed(type)) {
      for (var distance = 0.0; distance < metric.length; distance += 10) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 5, metric.length)),
          paint,
        );
      }
      return;
    }
    if (RelationVisualTokens.isDotted(type)) {
      for (var distance = 0.0; distance < metric.length; distance += 7) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) canvas.drawCircle(tangent.position, 1.15, paint);
      }
      return;
    }
    canvas.drawPath(path, paint);
  }

  bool _isBackRelation(RelationRecord record) =>
      record.relationType != null &&
      RelationVisualTokens.isBackRelation(record.relationType!);

  bool _isMovingRelationAt(RelationRecord record, Set<int> positions) =>
      record.relationType == RelationType.dongBian &&
      positions.contains(_originalPosition(record));

  int? _originalPosition(RelationRecord record) {
    for (final endpoint in record.participants) {
      if (endpoint is YaoEndpoint && endpoint.scope == LineScope.original) {
        return endpoint.position;
      }
    }
    return null;
  }

  void _drawBackHook(Canvas canvas, RelationRecord record) {
    final type = record.relationType!;
    final from = _endpointRect(record.fromRef!);
    final to = _endpointRect(record.toRef!);
    if (from == null || to == null) return;
    final original =
        record.fromRef is YaoEndpoint &&
            (record.fromRef! as YaoEndpoint).scope == LineScope.original
        ? from
        : to;
    final changed = identical(original, from) ? to : from;
    final position = _originalPosition(record);
    final row = position == null ? null : _rowRect(position);
    if (row == null) return;
    final geometry = BackRelationGlyph.layout(
      rowRect: row,
      mainLineRect: original,
      changedLineRect: changed,
    );
    final active = selectedId == record.id;
    final color = RelationVisualTokens.colorFor(type);
    final paint = Paint()
      ..color = color.withValues(alpha: RelationVisualTokens.opacityAll)
      ..style = PaintingStyle.stroke
      ..strokeWidth = active
          ? RelationVisualTokens.backHookStroke + .4
          : RelationVisualTokens.backHookStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final metric = geometry.path.computeMetrics().first;
    for (var distance = 0.0; distance < metric.length; distance += 10) {
      canvas.drawPath(
        metric.extractPath(distance, math.min(distance + 5, metric.length)),
        paint,
      );
    }
    canvas.drawPath(geometry.arrow, Paint()..color = color);
    if (active) {
      canvas.drawCircle(
        geometry.arrowTip,
        RelationVisualTokens.anchorRadius,
        Paint()..color = color,
      );
      canvas.drawCircle(
        geometry.arrowBaseCenter,
        RelationVisualTokens.anchorRadius,
        Paint()..color = color,
      );
    }
    _label(
      canvas,
      RelationVisualTokens.backHookLabel(type),
      geometry.labelCenter,
      color,
      fontSize: 10,
    );
  }

  Rect? _endpointRect(RelationEndpoint endpoint) {
    final key = anchorKeys[endpoint.semanticId];
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final overlay = context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null || !box.hasSize) return null;
    final topLeft = overlay.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }

  Rect? _rowRect(int position) {
    final key = rowKeys[position];
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final overlay = context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null || !box.hasSize) return null;
    final topLeft = overlay.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
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

  RelationRouteKind _routeKind(_Route route) => switch (route) {
    _Route.mainToMain => RelationRouteKind.mainToMain,
    _Route.mainToChanged => RelationRouteKind.mainToChanged,
    _Route.changedToChanged => RelationRouteKind.changedToChanged,
    _Route.calendarToYao => RelationRouteKind.calendarToYao,
  };

  Offset _labelCenter(Path path, _Route route) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * .5)!;
    final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
    final direction = route == _Route.changedToChanged ? 1.0 : -1.0;
    return tangent.position + normal * (10 * direction);
  }

  void _label(
    Canvas canvas,
    String text,
    Offset center,
    Color color, {
    double fontSize = RelationVisualTokens.relationLabelFontSize,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
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
    required bool active,
  }) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(atEnd ? metric.length : 0);
    if (tangent == null) return;
    final tip = tangent.position;
    final vector = atEnd ? tangent.vector : -tangent.vector;
    final angle = math.atan2(vector.dy, vector.dx);
    final arrowSize = active
        ? RelationVisualTokens.arrowSizeFocused
        : RelationVisualTokens.arrowSize;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final a =
        tip -
        Offset(
          math.cos(angle - .55) * arrowSize,
          math.sin(angle - .55) * arrowSize,
        );
    final b =
        tip -
        Offset(
          math.cos(angle + .55) * arrowSize,
          math.sin(angle + .55) * arrowSize,
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
