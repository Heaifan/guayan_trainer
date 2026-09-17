import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/domain/cases/casting_snapshot.dart';
import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/services/cases/case_repository.dart';
import 'package:guayan_trainer/services/cases/case_query.dart';
import 'package:guayan_trainer/services/cases/json_case_repository.dart';

void main() {
  late CaseRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = await JsonCaseRepository.open();
  });

  test('create and read preserve snapshot while index stores only metadata', () async {
    final record = _record('case-1', DateTime(2026, 9, 18, 22, 30));

    await repository.create(record);
    final restored = await repository.read('case-1');
    final page = await repository.list(const CaseQuery(limit: 20));

    expect(restored, record);
    expect(page.items.single.id, 'case-1');
    expect(page.items.single.snapshot, isNotNull);
    expect(await repository.metadataJsonForTest('case-1'), isNot(contains('lines')));
  });

  test('soft delete, restore, favorite, and stable casting-time ordering work', () async {
    await repository.create(_record('b', DateTime(2026, 9, 18, 22, 30)));
    await repository.create(_record('a', DateTime(2026, 9, 18, 22, 30)));
    await repository.create(_record('c', DateTime(2026, 9, 17, 22, 30)));

    expect(
      (await repository.list(const CaseQuery(limit: 20))).items.map((e) => e.id),
      ['a', 'b', 'c'],
    );
    await repository.setFavorite('b', true);
    expect(
      (await repository.list(const CaseQuery(favoritesOnly: true, limit: 20)))
          .items.single.id,
      'b',
    );
    await repository.softDelete('b');
    expect((await repository.list(const CaseQuery(limit: 20))).items, hasLength(2));
    expect((await repository.list(const CaseQuery(deletedOnly: true, limit: 20))).items.single.id, 'b');
    await repository.restore('b');
    expect((await repository.read('b'))!.deletedAt, isNull);
    await repository.permanentlyDelete('b');
    expect(await repository.read('b'), isNull);
  });
}

CaseRecord _record(String id, DateTime time) => CaseRecord.create(
      id: id,
      snapshot: CastingSnapshot(
        castingTime: time,
        subject: '',
        lines: [
          for (var position = 1; position <= 6; position++)
            LineState(position: position, movementType: MovementType.shaoYin),
        ],
        originalHexagramName: '雷水解',
        movingPositions: const [],
      ),
      createdAt: time.add(const Duration(minutes: 1)),
      originalRuleRun: RuleRun.original(
        executedAt: time,
        ruleContext: const RuleExecutionContext.empty(),
        result: const {},
        evidence: const [],
      ),
    );
