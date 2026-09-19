import '../../domain/relation_endpoint.dart';
import '../../domain/relations/relation_record.dart';

enum RelationRouteTrack { calendar, main, mixed, changed }

class RelationRoutePlacement {
  const RelationRoutePlacement({
    required this.id,
    required this.track,
    required this.lane,
    required this.trunkLane,
    required this.trackOffset,
    required this.trunkGroup,
    required this.branchIndex,
    required this.branchOffset,
  });

  final String id;
  final RelationRouteTrack track;
  final int lane;
  final int trunkLane;
  final double trackOffset;
  final String trunkGroup;
  final int branchIndex;
  final double branchOffset;
}

abstract final class RelationRouteLayout {
  static const laneSpacing = 16.0;
  static const branchSpacing = 4.0;

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
    final groupCounts = <String, int>{};
    final trunkLanes = <String, int>{};
    for (final record in ordered) {
      final group = _groupKey(record);
      groupCounts[group] = (groupCounts[group] ?? 0) + 1;
      if (!trunkLanes.containsKey(group)) {
        final track = _track(record);
        trunkLanes[group] = trunkLanes.keys
            .where((key) => key.startsWith('${track.name}:'))
            .length;
      }
    }
    return [
      for (final record in ordered)
        (() {
          final track = _track(record);
          final group = _group(record);
          final groupKey = _groupKey(record);
          final branch = branches[group] ?? 0;
          branches[group] = branch + 1;
          final lane = lanes[track] ?? 0;
          lanes[track] = lane + 1;
          final count = groupCounts[groupKey]!;
          return RelationRoutePlacement(
            id: record.id,
            track: track,
            lane: lane,
            trunkLane: trunkLanes[groupKey]!,
            trackOffset: track.index * laneSpacing,
            trunkGroup: group,
            branchIndex: branch,
            branchOffset: (branch - (count - 1) / 2) * branchSpacing,
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

  static String _groupKey(RelationRecord record) =>
      '${_track(record).name}:${_group(record)}';
}
