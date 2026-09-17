import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/services/cases/json_shensha_note_store.dart';

void main() {
  test('神煞备注跨 store 重启恢复并按 case 隔离', () async {
    SharedPreferences.setMockInitialValues({});
    final first = await JsonShenShaNoteStore.open();
    final persistent = first.persistentStore();
    persistent.save(caseId: 'case-a', shenShaId: 'x', content: '保留');
    await Future<void>.delayed(Duration.zero);

    final second = await JsonShenShaNoteStore.open();
    expect(second.store.noteFor(caseId: 'case-a', shenShaId: 'x'), '保留');
    expect(second.store.noteFor(caseId: 'case-b', shenShaId: 'x'), isNull);
  });
}
