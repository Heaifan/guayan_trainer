import '../../domain/cases/case_record.dart';
import '../../domain/cases/casting_snapshot.dart';
import '../../domain/cases/rule_run.dart';
import '../../domain/hexagram_case.dart';
import '../../domain/casting/cast_chart.dart';
import 'case_repository.dart';

/// 把一次已经完成的排盘写成新的 CaseRecord。
class GeneratedCaseRecorder {
  GeneratedCaseRecorder(
    this._repository, {
    String Function()? idFactory,
    DateTime Function()? clock,
  })  : _idFactory = idFactory ?? _defaultId,
        _clock = clock ?? DateTime.now;

  final CaseRepository _repository;
  final String Function() _idFactory;
  final DateTime Function() _clock;

  Future<CaseRecord> record(HexagramCase generated, CastChart chart) async {
    final snapshot = CastingSnapshot(
      castingTime: generated.createdAt,
      subject: generated.question,
      lines: generated.lines,
      originalHexagramName: chart.original.name,
      changedHexagramName: chart.changed?.name,
      movingPositions: chart.movingPositions,
      calendar: generated.calendar,
    );
    final ruleRun = RuleRun.original(
      executedAt: _clock(),
      ruleContext: generated.ruleContext,
      result: {
        'originalHexagramName': chart.original.name,
        'changedHexagramName': chart.changed?.name,
        'movingPositions': chart.movingPositions,
      },
      evidence: [
        for (final line in chart.lines)
          {'position': line.position, 'text': line.ganZhi},
      ],
    );
    final record = CaseRecord.create(
      id: _idFactory(),
      snapshot: snapshot,
      createdAt: _clock(),
      originalRuleRun: ruleRun,
    );
    await _repository.create(record);
    return record;
  }
}

String _defaultId() => 'case-${DateTime.now().microsecondsSinceEpoch}';
