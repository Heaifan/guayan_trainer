import '../../calendar/day/ganzhi_day.dart';
import '../../casting/casting_engine.dart';
import '../../casting/cast_chart.dart';
import '../../hexagram_case.dart';
import '../../tian_gan.dart';
import 'fact_record.dart';
import 'fact_snapshot.dart';
import 'rule_value.dart';
import 'semantic_ref.dart';

/// Builds the immutable rule facts from the same Case input used by review.
class CanonicalFactSnapshotBuilder {
  CanonicalFactSnapshotBuilder._();

  static FactSnapshot build(HexagramCase hexagramCase) {
    if (hexagramCase.lines.length != 6 ||
        hexagramCase.lines.any((line) => line.branch == null)) {
      throw StateError('测试卦例缺少完整六爻地支事实');
    }
    final dayGan = _dayGan(hexagramCase);
    final chart = CastingEngine.cast(
      [for (final line in hexagramCase.lines) line.movementType],
      dayGan: dayGan,
    );
    final facts = <FactRecord>[];
    for (final line in chart.lines) {
      final ref = SemanticRef.line(line.position);
      _add(facts, 'branch', ref, line.branch.label);
      _add(facts, 'element', ref, line.branch.wuXing.label);
      _add(facts, 'relative', ref, _relativeId(line));
      _add(facts, 'movement', ref, line.isMoving ? 'moving' : 'still');
      _add(facts, 'shi_ying', ref, line.isShi ? 'shi' : 'ying',
          only: line.isShi || line.isYing);
      if (line.spirit != null) {
        _add(facts, 'spirit', ref, 'spirit.${line.spirit!.name.snakeCase}');
      }
    }
    return FactSnapshot.build(facts);
  }

  static TianGan _dayGan(HexagramCase hexagramCase) {
    final calendar = hexagramCase.calendar;
    return calendar == null
        ? ganzhiDayOfDate(
            hexagramCase.createdAt.year,
            hexagramCase.createdAt.month,
            hexagramCase.createdAt.day,
          ).gan
        : TianGan.fromLabel(calendar.dayGan);
  }

  static String _relativeId(CastLine line) => switch (line.relative.name) {
    'fuMu' => 'relative.parent',
    'xiongDi' => 'relative.sibling',
    'ziSun' => 'relative.child',
    'guanGui' => 'relative.official',
    'qiCai' => 'relative.spouse',
    _ => line.relative.name,
  };

  static void _add(
    List<FactRecord> facts,
    String predicate,
    SemanticRef subject,
    String value, {
    bool only = true,
  }) {
    if (!only) return;
    facts.add(FactRecord(
      factId: '$predicate-${subject.key}',
      subject: subject,
      predicateId: predicate,
      value: RuleValue.string(value),
      origin: FactOrigin.original,
    ));
  }
}

extension on String {
  String get snakeCase => replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      );
}
