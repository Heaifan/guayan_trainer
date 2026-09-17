import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/services/cases/case_metadata_autosaver.dart';
import 'package:guayan_trainer/services/cases/case_recompute_service.dart';
import 'package:guayan_trainer/services/cases/json_case_repository.dart';
import 'case_test_fixtures.dart';

void main() {
  test('metadata autosave flush persists subject and note without changing snapshot', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = await JsonCaseRepository.open();
    final original = recordFixture('metadata', DateTime(2026, 9, 18));
    await repository.create(original);
    final autosaver = CaseMetadataAutosaver(repository, 'metadata');

    autosaver.setSubject('新事项');
    autosaver.setNote('总备注');
    await autosaver.flush();
    final restored = (await repository.read('metadata'))!;

    expect(restored.subject, '新事项');
    expect(restored.note, '总备注');
    expect(restored.snapshot, original.snapshot);
    expect(restored.ruleRuns, original.ruleRuns);
  });

  test('recompute appends RuleRun without changing Case or Original RuleRun', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = await JsonCaseRepository.open();
    final original = recordFixture('recompute', DateTime(2026, 9, 18));
    await repository.create(original);
    final service = CaseRecomputeService(repository, clock: () => DateTime(2026, 9, 19));

    await service.recompute(
      caseId: 'recompute',
      ruleContext: RuleExecutionContext([RuleVersionRef('sys.default', 2)]),
      result: const {'title': '新结果'},
      evidence: const [{'text': '新证据'}],
    );
    final restored = (await repository.read('recompute'))!;

    expect(restored.snapshot, original.snapshot);
    expect(restored.ruleRuns.first, original.ruleRuns.first);
    expect(restored.ruleRuns, hasLength(2));
    expect(restored.ruleRuns.last.result['title'], '新结果');
  });
}
