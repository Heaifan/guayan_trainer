import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/services/cases/generated_case_recorder.dart';
import 'package:guayan_trainer/services/cases/case_query.dart';
import 'package:guayan_trainer/services/cases/json_case_repository.dart';

void main() {
  test('each generated casting creates a new CaseRecord', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = await JsonCaseRepository.open();
    var id = 0;
    final recorder = GeneratedCaseRecorder(
      repository,
      idFactory: () => 'case-${++id}',
      clock: () => DateTime(2026, 9, 18, 22, 31),
    );
    final input = HexagramCase(
      id: 'generated',
      question: '项目交付',
      lines: [
        for (var position = 1; position <= 6; position++)
          LineState(position: position, movementType: MovementType.shaoYin),
      ],
      createdAt: DateTime(2026, 9, 18, 22, 30),
    );
    final chart = CastingEngine.cast(
      [for (final line in input.lines) line.movementType],
    );

    await recorder.record(input, chart);
    await recorder.record(input, chart);
    await recorder.record(input, chart);

    final page = await repository.list(const CaseQuery(limit: 20));
    expect(page.items.map((record) => record.id), ['case-1', 'case-2', 'case-3']);
  });
}
