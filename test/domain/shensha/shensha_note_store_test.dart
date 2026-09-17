import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/shensha/shensha_note_store.dart';

void main() {
  test('shen sha notes are isolated by case and shen sha id', () {
    final store = ShenShaNoteStore();
    store.save(
      caseId: 'case-a',
      shenShaId: 'shensha.tao_hua',
      content: '卯木桃花，小女孩',
    );

    expect(
      store.noteFor(caseId: 'case-a', shenShaId: 'shensha.tao_hua'),
      '卯木桃花，小女孩',
    );
    expect(
      store.noteFor(caseId: 'case-b', shenShaId: 'shensha.tao_hua'),
      isNull,
    );
    expect(
      store.noteFor(caseId: 'case-a', shenShaId: 'shensha.tian_lu'),
      isNull,
    );
  });

  test('shen sha notes survive json round trip', () {
    final store = ShenShaNoteStore();
    store.save(caseId: 'case-a', shenShaId: 'shensha.tao_hua', content: '备注');

    final restored = ShenShaNoteStore.fromJson(store.toJson());
    expect(
      restored.noteFor(caseId: 'case-a', shenShaId: 'shensha.tao_hua'),
      '备注',
    );
  });
}
