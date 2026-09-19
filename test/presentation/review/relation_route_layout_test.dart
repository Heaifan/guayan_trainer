import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/domain/relations/relation_record.dart';
import 'package:guayan_trainer/presentation/review/relation_route_layout.dart';

RelationRecord _record(String id, RelationEndpoint from, RelationEndpoint to) =>
    RelationRecord.relation(
      id: id,
      sourceKind: RelationSourceKind.fact,
      relationType: RelationType.sheng,
      fromRef: from,
      toRef: to,
      title: id,
    );

void main() {
  test('same source uses one trunk group and deterministic fan-out order', () {
    final source = const MonthEndpoint();
    final placements = RelationRouteLayout.layout([
      _record('month-3', source, YaoEndpoint(LineScope.original, 3)),
      _record('month-1', source, YaoEndpoint(LineScope.original, 1)),
      _record('month-2', source, YaoEndpoint(LineScope.original, 2)),
    ]);

    expect(placements.map((item) => item.id), [
      'month-1',
      'month-2',
      'month-3',
    ]);
    expect(placements.map((item) => item.trunkGroup).toSet(), {'month'});
    expect(placements.map((item) => item.trunkLane).toSet(), {0});
    expect(placements.map((item) => item.branchIndex), [0, 1, 2]);
    expect(placements.map((item) => item.branchOffset), [-4.0, 0.0, 4.0]);
  });

  test('route families keep independent lanes with fixed spacing', () {
    final placements = RelationRouteLayout.layout([
      _record(
        'main',
        YaoEndpoint(LineScope.original, 1),
        YaoEndpoint(LineScope.original, 2),
      ),
      _record(
        'changed',
        YaoEndpoint(LineScope.changed, 1),
        YaoEndpoint(LineScope.changed, 2),
      ),
      _record(
        'calendar',
        const DayEndpoint(),
        YaoEndpoint(LineScope.original, 3),
      ),
    ]);

    expect(placements.map((item) => item.track), [
      RelationRouteTrack.calendar,
      RelationRouteTrack.main,
      RelationRouteTrack.changed,
    ]);
    expect(placements.map((item) => item.trackOffset).toSet().length, 3);
    expect(RelationRouteLayout.laneSpacing, greaterThan(0));
  });
}
