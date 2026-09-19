import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../domain/relation_endpoint.dart';
import '../../../domain/relation_type.dart';
import '../../../domain/relations/relation_record.dart';
import '../relation_geometry.dart';
import '../relation_label_placer.dart';
import '../relation_debug_painter.dart';
import '../relation_render_plan.dart';
import '../relation_route_cache.dart';
import '../relation_visual_tokens.dart';
import '../return_relation_glyph.dart';
import '../review_relation_filter.dart';

class RelationOverlay extends StatefulWidget {
  const RelationOverlay({
    super.key,
    required this.records,
    this.focus,
    this.selectedId,
    this.onRelationTap,
    this.anchorKeys = const {},
    this.rowKeys = const {},
    this.obstacleKeys = const {},
    this.category,
    this.debugMode = false,
  });

  final List<RelationRecord> records;
  final RelationEndpoint? focus;
  final String? selectedId;
  final ValueChanged<String>? onRelationTap;
  final Map<String, GlobalKey> anchorKeys;
  final Map<int, GlobalKey> rowKeys;
  final Map<String, GlobalKey> obstacleKeys;
  final String? category;
  final bool debugMode;

  static List<RelationRecord> visibleRecords(
    Iterable<RelationRecord> records, {
    RelationEndpoint? focus,
    String? category,
  }) {
    if (focus == null) return const [];
    return drawableRecords(filterReviewRelationRecords(
      records,
      focus: focus,
      category: category ?? '全部',
    ));
  }

  static List<RelationRecord> drawableRecords(Iterable<RelationRecord> records) {
    final result = records.where((record) {
      final type = record.relationType;
      return record.kind == RelationKind.relation &&
          type != null &&
          (type == RelationType.sheng ||
              type == RelationType.ke ||
              type == RelationType.huiTouSheng ||
              type == RelationType.huiTouKe);
    }).toList()..sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  static RelationRenderPlan planForBounds({
    required Iterable<RelationRecord> records,
    required Map<String, Rect> bounds,
    required Map<String, Rect> anchorBounds,
    required Size viewportSize,
  }) => RelationRenderPlanner.build(
    records: drawableRecords(records),
    bounds: bounds,
    anchorBounds: anchorBounds,
    viewportSize: viewportSize,
  );

  @override
  State<RelationOverlay> createState() => _RelationOverlayState();
}

class _RelationOverlayState extends State<RelationOverlay> {
  final _cache = RelationRouteCache();

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      ignoring: widget.onRelationTap == null,
      child: CustomPaint(
        painter: _RelationPainter(
          records: RelationOverlay.visibleRecords(
            widget.records,
            focus: widget.focus,
            category: widget.category,
          ),
          selectedId: widget.selectedId,
          anchorKeys: widget.anchorKeys,
          rowKeys: widget.rowKeys,
          obstacleKeys: widget.obstacleKeys,
          context: context,
          debugMode: widget.debugMode,
          cache: _cache,
        ),
      ),
    ),
  );
}

class _RelationPainter extends CustomPainter {
  const _RelationPainter({
    required this.records,
    required this.selectedId,
    required this.anchorKeys,
    required this.rowKeys,
    required this.obstacleKeys,
    required this.context,
    required this.debugMode,
    required this.cache,
  });

  final List<RelationRecord> records;
  final String? selectedId;
  final Map<String, GlobalKey> anchorKeys;
  final Map<int, GlobalKey> rowKeys;
  final Map<String, GlobalKey> obstacleKeys;
  final BuildContext context;
  final bool debugMode;
  final RelationRouteCache cache;

  @override
  void paint(Canvas canvas, Size size) {
    final anchorBounds = _collect(anchorKeys);
    final obstacleBounds = <String, Rect>{
      ...anchorBounds,
      ..._collect(obstacleKeys),
    };
    final key = RelationRouteCacheKey(_fingerprint(
      records,
      obstacleBounds,
      anchorBounds,
      size,
    ));
    final plan = cache.resolve(key, () => RelationOverlay.planForBounds(
      records: records,
      bounds: obstacleBounds,
      anchorBounds: anchorBounds,
      viewportSize: size,
      )
    );
    for (var i = 0; i < plan.routes.length; i++) {
      final record = plan.records[i];
      final active = selectedId == record.id;
      final color = RelationVisualTokens.colorFor(record.relationType!);
      final paint = Paint()
        ..color = color.withValues(alpha: active ? 1 : .82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = active
            ? RelationVisualTokens.strokeFocused
            : RelationVisualTokens.strokeNormal
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(plan.routes[i].path, paint);
      _drawArrow(canvas, plan.routes[i].path, color);
      _drawLabel(canvas, plan.labels[i], color);
    }
    for (final record in records.where(_isReturn)) {
      _drawReturn(canvas, record, anchorBounds);
    }
    if (debugMode) _drawDebug(canvas, size, anchorBounds, obstacleBounds, plan);
  }

  String _fingerprint(
    List<RelationRecord> records,
    Map<String, Rect> obstacles,
    Map<String, Rect> anchors,
    Size size,
  ) => [
    size.width,
    size.height,
    for (final record in records) record.id,
    for (final entry in obstacles.entries) '${entry.key}:${entry.value}',
    for (final entry in anchors.entries) '${entry.key}:${entry.value}',
  ].join('|');

  Map<String, Rect> _collect(Map<String, GlobalKey> keys) {
    final result = <String, Rect>{};
    for (final entry in keys.entries) {
      final rect = _rect(entry.value);
      if (rect != null) result[entry.key] = rect;
    }
    return result;
  }

  Rect? _rect(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final overlay = context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null || !box.hasSize) return null;
    final topLeft = overlay.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }

  void _drawArrow(Canvas canvas, Path path, Color color) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length);
    if (tangent == null) return;
    final tip = tangent.position;
    final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);
    final arrowSize = RelationVisualTokens.arrowSizeFocused;
    final arrow = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - math.cos(angle - .55) * arrowSize,
          tip.dy - math.sin(angle - .55) * arrowSize)
      ..lineTo(tip.dx - math.cos(angle + .55) * arrowSize,
          tip.dy - math.sin(angle + .55) * arrowSize)
      ..close();
    canvas.drawPath(arrow, Paint()..color = color);
  }

  void _drawLabel(Canvas canvas, PlacedRelationLabel label, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: label.text,
        style: TextStyle(
          color: color,
          fontSize: RelationVisualTokens.relationLabelFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, label.center - Offset(painter.width / 2, painter.height / 2));
  }

  void _drawReturn(Canvas canvas, RelationRecord record, Map<String, Rect> bounds) {
    final source = bounds[record.fromRef!.semanticId];
    final target = bounds[record.toRef!.semanticId];
    final position = _position(record);
    final row = position == null ? null : _rect(rowKeys[position]!);
    if (source == null || target == null || row == null) return;
    final original = record.fromRef is YaoEndpoint &&
            (record.fromRef! as YaoEndpoint).scope == LineScope.original
        ? source
        : target;
    final changed = identical(original, source) ? target : source;
    final geometry = ReturnRelationGlyph.layout(
      rowRect: row,
      originalRect: original,
      changedRect: changed,
      type: record.relationType!,
    );
    final color = RelationVisualTokens.colorFor(record.relationType!);
    canvas.drawPath(
      geometry.path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = RelationVisualTokens.strokeNormal
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(geometry.arrow, Paint()..color = color);
    final labelPainter = TextPainter(
      text: TextSpan(
        text: geometry.label,
        style: TextStyle(
          color: color,
          fontSize: RelationVisualTokens.relationLabelFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(
        (original.center.dx + changed.center.dx - labelPainter.width) / 2,
        row.top + 2,
      ),
    );
  }

  void _drawDebug(
    Canvas canvas,
    Size size,
    Map<String, Rect> anchors,
    Map<String, Rect> obstacles,
    RelationRenderPlan plan,
  ) {
    final data = RelationDebugPainter.data(
      enabled: true,
      nodeBounds: anchors,
      anchorBounds: {
        for (final entry in anchors.entries)
          entry.key: RelationAnchors.fromRect(entry.value).all
              .map((anchor) => anchor.point)
              .toList(),
      },
      obstacleBounds: obstacles,
      selectedAnchors: [
        for (final route in plan.routes)
          route.sourceAnchor.point,
        for (final route in plan.routes)
          route.targetAnchor.point,
      ],
      routeSegments: [for (final route in plan.routes) route.points],
      labelBounds: [for (final label in plan.labels) label.bounds],
    );
    final nodePaint = Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: .35)
      ..style = PaintingStyle.stroke;
    final obstaclePaint = Paint()
      ..color = const Color(0xFFD9342B).withValues(alpha: .35)
      ..style = PaintingStyle.stroke;
    for (final rect in data.nodeBounds.values) {
      canvas.drawRect(rect, nodePaint);
    }
    for (final rect in data.obstacleBounds.values) {
      canvas.drawRect(rect.inflate(RelationVisualTokens.safePadding), obstaclePaint);
    }
    for (final points in data.routeSegments) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, nodePaint);
    }
    for (final point in data.selectedAnchors) {
      canvas.drawCircle(point, RelationVisualTokens.anchorRadius, obstaclePaint);
    }
    for (final rect in data.labelBounds) {
      canvas.drawRect(rect, obstaclePaint);
    }
  }

  bool _isReturn(RelationRecord record) =>
      record.relationType == RelationType.huiTouSheng ||
      record.relationType == RelationType.huiTouKe;

  int? _position(RelationRecord record) {
    for (final endpoint in record.participants) {
      if (endpoint is YaoEndpoint && endpoint.scope == LineScope.original) {
        return endpoint.position;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant _RelationPainter oldDelegate) =>
      oldDelegate.records != records || oldDelegate.selectedId != selectedId;
}
