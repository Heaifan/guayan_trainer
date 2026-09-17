import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/services/cases/case_query.dart';
import 'package:guayan_trainer/services/cases/json_case_repository.dart';
import 'case_test_fixtures.dart' as fixtures;

void main() {
  test('search, date range, and pagination are applied to metadata before details', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = await JsonCaseRepository.open();
    await repository.create(fixtures.recordFixture('1', DateTime(2026, 9, 18, 22)));
    await repository.create(fixtures.recordFixture('2', DateTime(2026, 9, 17, 22)));
    await repository.create(fixtures.recordFixture('3', DateTime(2026, 9, 1, 22)));

    final page = await repository.list(CaseQuery(
      keyword: '雷水解',
      from: DateTime(2026, 9, 17),
      to: DateTime(2026, 9, 18, 23, 59, 59, 999),
      offset: 0,
      limit: 1,
    ));

    expect(page.items.map((record) => record.id), ['1']);
    expect(page.hasMore, isTrue);
  });
}
