import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/presentation/cases/cases_page.dart';
import 'package:guayan_trainer/services/cases/json_case_repository.dart';
import '../../services/cases/case_test_fixtures.dart' as fixtures;

void main() {
  testWidgets('case library shows minimal fields and favorite action', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = await JsonCaseRepository.open();
    final base = fixtures.recordFixture('case-ui', DateTime(2026, 9, 18, 22, 30));
    await repository.create(CaseRecord.create(
      id: base.id,
      snapshot: base.snapshot.copyWith(subject: ''),
      createdAt: base.createdAt,
      originalRuleRun: base.ruleRuns.single,
    ));

    await tester.pumpWidget(MaterialApp(home: CasesPage(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.textContaining('未填写事项'), findsOneWidget);
    expect(find.textContaining('雷水解'), findsOneWidget);
    expect(find.textContaining('规则'), findsNothing);
    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();
    expect((await repository.read('case-ui'))!.isFavorite, isTrue);
  });
}
