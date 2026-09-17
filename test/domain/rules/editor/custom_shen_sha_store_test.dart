import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_shen_sha_definition.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_shen_sha_store.dart';

void main() {
  test(
    'custom ShenSha persists in the user store and protects references',
    () async {
      final store = CustomShenShaStore();
      const item = CustomShenShaDefinition(
        id: 'shensha.custom.morning_star',
        name: '晨星',
        description: '用户自定义神煞',
      );
      store.seedForTest([item]);
      expect(store.getAll().single.name, '晨星');
      expect(
        () => store.delete(item.id, referencedIds: {item.id}),
        throwsStateError,
      );
    },
  );
}
