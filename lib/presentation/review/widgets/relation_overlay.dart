import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../domain/relation_endpoint.dart';
import '../../../domain/relation_type.dart';
import '../../../domain/relations/relation_record.dart';
import '../relation_geometry.dart';
import '../relation_label_placer.dart';
import '../relation_label_visual.dart';
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
    this.returnAnchorKeys = const {},
    this.rowKeys = const {},
    this.obstacleKeys = const {},
    this.category,
    this.debugMode = false,
  });

  final List<RelationRecord> records;
  final RelationEndpoint? focus;
  final String? selectedId;
  final ValueChanged<String>? onRelationTap;
  /// 普通生克锚在主卦正文；回头生克锚在真实爻象，二者禁止共用。
  final Map<String, GlobalKey> anchorKeys;
  final Map<String, GlobalKey> returnAnchorKeys;
  final Map<int, GlobalKey> rowKeys;
  final Map<String, GlobalKey> obstacleKeys;
  final String? category;
  final bool debugMode;

  static List<RelationRecord> visibleRecords(
    Iterable<RelationRecord> records, {
    RelationEndpoint? focus,
    String? category,
  }) {
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
          returnAnchorKeys: widget.returnAnchorKeys,
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
    required this.returnAnchorKeys,
    required this.rowKeys,
    required this.obstacleKeys,
    required this.context,
    required this.debugMode,
    required this.cache,
  });

  final List<RelationRecord> records;
  final String? selectedId;
  final Map<String, GlobalKey> anchorKeys;
  final Map<String, GlobalKey> returnAnchorKeys;
  final Map<int, GlobalKey> rowKeys;
  final Map<String, GlobalKey> obstacleKeys;
  final BuildContext context;
  final bool debugMode;
  final RelationRouteCache cache;

  @override
  void paint(Canvas canvas, Size size) {
    final anchorBounds = _collect(anchorKeys);
    final returnAnchorBounds = _collect(returnAnchorKeys);
    final obstacleBounds = <String, Rect>{
      ...anchorBounds,
      // 回头关系的真实爻象也参与普通 Router 避障，但使用独立 ID，
      // 不能覆盖同 semanticId 的“正文锚点”。
      for (final entry in returnAnchorBounds.entries)
        'yao_glyph:${entry.key}': entry.value,
      ..._collect(obstacleKeys),
    };
    final key = RelationRouteCacheKey(_fingerprint(
      records,
      obstacleBounds,
      anchorBounds,
      returnAnchorBounds,
      size,
    ));
    final plan = cache.resolve(key, () => RelationOverlay.planForBounds(
      records: records,
      bounds: obstacleBounds,
      anchorBounds: anchorBounds,
      viewportSize: size,
      )
    );
    final protectedBounds = <Rect>[
      ...obstacleBounds.values,
      for (final label in plan.labels)
        if (label != null) label.bounds,
    ];
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
      _drawSoftPath(
        canvas,
        plan.routes[i].path,
        paint,
        protectedBounds,
      );
      // 标签先画、箭头最后画：文字胶囊不能盖住箭头。
      final label = plan.labels[i];
      if (label != null) _drawLabel(canvas, label, color);
      _drawArrow(
        canvas,
        plan.routes[i].path,
        color,
        protectedBounds,
      );
    }
    for (final record in records.where(_isReturn)) {
      _drawReturn(
        canvas,
        record,
        returnAnchorBounds,
        protectedBounds,
      );
    }
    if (debugMode) _drawDebug(canvas, size, anchorBounds, obstacleBounds, plan);
  }

  String _fingerprint(
    List<RelationRecord> records,
    Map<String, Rect> obstacles,
    Map<String, Rect> anchors,
    Map<String, Rect> returnAnchors,
    Size size,
  ) => [
    size.width,
    size.height,
    for (final record in records) record.id,
    for (final entry in obstacles.entries) '${entry.key}:${entry.value}',
    for (final entry in anchors.entries) '${entry.key}:${entry.value}',
    for (final entry in returnAnchors.entries)
      'return:${entry.key}:${entry.value}',
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

  void _drawArrow(
    Canvas canvas,
    Path path,
    Color color,
    Iterable<Rect> protectedBounds,
  ) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.last;
    final tangent = metric.getTangentForOffset(metric.length);
    if (tangent == null) return;
    final tip = tangent.position;
    final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);
    final arrowSize = RelationVisualTokens.arrowSizeFocused;
    final arrow = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - math.cos(angle - .55) * arrowSize,
        tip.dy - math.sin(angle - .55) * arrowSize,
      )
      ..lineTo(
        tip.dx - math.cos(angle + .55) * arrowSize,
        tip.dy - math.sin(angle + .55) * arrowSize,
      )
      ..close();
    final overlapsProtected = protectedBounds.any(
      (rect) => rect.overlaps(arrow.getBounds()),
    );
    canvas.drawPath(
      arrow,
      Paint()
        ..color = color.withValues(alpha: overlapsProtected ? .48 : .96),
    );
  }

  /// 关系线允许穿过卦盘元素。先整条画一层低透明底线，再把未覆盖元素
  /// 的区段恢复正常透明度，因此“穿字”不会遮住正文，也不会把关系删掉。
  void _drawSoftPath(
    Canvas canvas,
    Path path,
    Paint normalPaint,
    Iterable<Rect> protectedBounds,
  ) {
    final bounds = [
      for (final rect in protectedBounds)
        rect.inflate(
          normalPaint.strokeWidth / 2 + RelationVisualTokens.occlusionPadding,
        ),
    ];
    final dimPaint = Paint()
      ..color = normalPaint.color.withValues(
        alpha: normalPaint.color.a * RelationVisualTokens.opacityOccluded,
      )
      ..style = normalPaint.style
      ..strokeWidth = normalPaint.strokeWidth
      ..strokeCap = normalPaint.strokeCap
      ..strokeJoin = normalPaint.strokeJoin;
    canvas.drawPath(path, dimPaint);

    final visible = Path();
    const step = 1.75;
    for (final metric in path.computeMetrics()) {
      var drawing = false;
      for (var distance = 0.0; distance <= metric.length; distance += step) {
        final tangent = metric.getTangentForOffset(
          math.min(distance, metric.length),
        );
        if (tangent == null) continue;
        final point = tangent.position;
        final occluded = bounds.any((rect) => rect.contains(point));
        if (occluded) {
          drawing = false;
          continue;
        }
        if (!drawing) {
          visible.moveTo(point.dx, point.dy);
          drawing = true;
        } else {
          visible.lineTo(point.dx, point.dy);
        }
      }
      final end = metric.getTangentForOffset(metric.length)?.position;
      if (end != null &&
          !bounds.any((rect) => rect.contains(end))) {
        visible.lineTo(end.dx, end.dy);
      }
    }
    canvas.drawPath(visible, normalPaint);
  }

  void _drawLabel(Canvas canvas, PlacedRelationLabel label, Color color) {
    RelationLabelVisual.paint(
      canvas,
      text: label.text,
      center: label.center,
      color: color,
    );
  }

  void _drawReturn(
    Canvas canvas,
    RelationRecord record,
    Map<String, Rect> bounds,
    Iterable<Rect> protectedBounds,
  ) {
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
    _drawSoftPath(
      canvas,
      geometry.path,
      Paint()
        ..color = color.withValues(alpha: .88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = RelationVisualTokens.strokeNormal
        ..strokeCap = StrokeCap.round,
      protectedBounds,
    );
    RelationLabelVisual.paint(
      canvas,
      text: geometry.label,
      center: geometry.labelCenter,
      color: color,
    );
    // 箭头最后绘制。若恰好经过高优先级元素则降透明，但方向仍可辨。
    final arrowOccluded = protectedBounds.any(
      (rect) => rect.overlaps(geometry.arrow.getBounds()),
    );
    canvas.drawPath(
      geometry.arrow,
      Paint()
        ..color = color.withValues(alpha: arrowOccluded ? .48 : .96),
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
      labelBounds: [
        for (final label in plan.labels)
          if (label != null) label.bounds,
      ],
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
