import '../../domain/relation_endpoint.dart';
import '../../domain/relations/relation_record.dart';

enum RelationRouteTrack { calendar, main, mixed, changed }

class RelationRoutePlacement {
  const RelationRoutePlacement({
    required this.id,
    required this.track,
    required this.lane,
    required this.trackOffset,
    required this.trunkGroup,
    required this.branchIndex,
  });

  final String id;
  final RelationRouteTrack track;
  final int lane;
  final double trackOffset;
  final String trunkGroup;
  final int branchIndex;
}

abstract final class RelationRouteLayout {
  static const laneSpacing = 16.0;

  static List<RelationRoutePlacement> layout(Iterable<RelationRecord> records) {
    final ordered = records.where(_isDrawable).toList()
      ..sort((a, b) {
        final track = _track(a).index.compareTo(_track(b).index);
        if (track != 0) return track;
        final source = a.fromRef!.semanticId.compareTo(b.fromRef!.semanticId);
        if (source != 0) return source;
        final target = a.toRef!.semanticId.compareTo(b.toRef!.semanticId);
        if (target != 0) return target;
        return a.id.compareTo(b.id);
      });
    final lanes = <RelationRouteTrack, int>{};
    final branches = <String, int>{};
    return [
      for (final record in ordered)
        (() {
          final track = _track(record);
          final group = _group(record);
          final branch = branches[group] ?? 0;
          branches[group] = branch + 1;
          final lane = lanes[track] ?? 0;
          lanes[track] = lane + 1;
          return RelationRoutePlacement(
            id: record.id,
            track: track,
            lane: lane,
            trackOffset: track.index * laneSpacing,
            trunkGroup: group,
            branchIndex: branch,
          );
        })(),
    ];
  }

  static bool _isDrawable(RelationRecord record) =>
      record.relationType != null &&
      record.fromRef != null &&
      record.toRef != null;

  static RelationRouteTrack _track(RelationRecord record) {
    final from = record.fromRef!;
    final to = record.toRef!;
    if (from is MonthEndpoint ||
        from is DayEndpoint ||
        to is MonthEndpoint ||
        to is DayEndpoint) {
      return RelationRouteTrack.calendar;
    }
    final fromChanged = from is YaoEndpoint && from.scope == LineScope.changed;
    final toChanged = to is YaoEndpoint && to.scope == LineScope.changed;
    if (fromChanged && toChanged) return RelationRouteTrack.changed;
    if (fromChanged || toChanged) return RelationRouteTrack.mixed;
    return RelationRouteTrack.main;
  }

  static String _group(RelationRecord record) => record.fromRef!.semanticId;
}
