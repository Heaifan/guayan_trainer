import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/rules/library/rule_folder.dart';
import 'package:guayan_trainer/domain/rules/library/rule_library_service.dart';
import 'package:guayan_trainer/domain/rules/library/rule_library_store.dart';

void main() {
  test('persists folders and rules across a fresh service', () async {
    SharedPreferences.setMockInitialValues({});
    final store = RuleLibraryStore(preferences: await SharedPreferences.getInstance());
    final first = RuleLibraryService(store);
    await first.load();
    final folder = await first.createFolder('家宅', parentFolderId: RuleFolder.uncategorizedId);
    await first.moveRule('rule-a', folder.folderId);
    await first.setFolderEnabled(folder.folderId, false);

    final second = RuleLibraryService(store);
    await second.load();
    expect(second.index.folderById(folder.folderId)?.enabled, isFalse);
    expect(second.index.ruleFolderIds['rule-a'], folder.folderId);
  });

  test('deleting a non-empty folder moves content to its parent by default', () async {
    SharedPreferences.setMockInitialValues({});
    final store = RuleLibraryStore(preferences: await SharedPreferences.getInstance());
    final service = RuleLibraryService(store);
    await service.load();
    final folder = await service.createFolder('临时', parentFolderId: RuleFolder.uncategorizedId);
    await service.moveRule('rule-a', folder.folderId);
    await service.deleteFolder(folder.folderId);

    expect(service.index.folderById(folder.folderId), isNull);
    expect(service.index.ruleFolderIds['rule-a'], RuleFolder.uncategorizedId);
  });
}
