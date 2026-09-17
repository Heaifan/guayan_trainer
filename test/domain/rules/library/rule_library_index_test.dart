import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/rules/library/rule_folder.dart';
import 'package:guayan_trainer/domain/rules/library/rule_library_index.dart';

void main() {
  test('creates stable reserved folders and counts descendants recursively', () {
    final index = RuleLibraryIndex.defaults();
    final home = index.createFolder('家宅', parentFolderId: RuleFolder.uncategorizedId);
    final homeId = home.folders.firstWhere((folder) => folder.name == '家宅').folderId;
    final room = home.createFolder('宅内取象', parentFolderId: homeId);
    final roomId = room.folders.firstWhere((folder) => folder.name == '宅内取象').folderId;
    final withRules = room.assignRule('rule-a', folderId: roomId);

    expect(withRules.folderById(RuleFolder.uncategorizedId), isNotNull);
    expect(withRules.recursiveRuleCount(homeId), 1);
    expect(withRules.recursiveRuleCount(roomId), 1);
  });

  test('rejects moving a folder into itself or its descendant', () {
    final root = RuleLibraryIndex.defaults().createFolder(
      'A',
      parentFolderId: RuleFolder.uncategorizedId,
    );
    final rootId = root.folders.firstWhere((folder) => folder.name == 'A').folderId;
    final child = root.createFolder('B', parentFolderId: rootId);
    final childId = child.folders.firstWhere((folder) => folder.name == 'B').folderId;

    expect(
      () => child.moveFolder(rootId, childId),
      throwsArgumentError,
    );
  });

  test('folder switch does not overwrite rule enabled state', () {
    final index = RuleLibraryIndex.defaults()
        .createFolder('家宅', parentFolderId: RuleFolder.uncategorizedId)
        .assignRule('rule-a', folderId: 'system:uncategorized');

    final disabled = index.setFolderEnabled(RuleFolder.uncategorizedId, false);
    expect(disabled.effectiveEnabled('rule-a', ruleEnabled: true), isFalse);
    expect(disabled.ruleFolderIds['rule-a'], 'system:uncategorized');

    final reopened = disabled.setFolderEnabled(RuleFolder.uncategorizedId, true);
    expect(reopened.effectiveEnabled('rule-a', ruleEnabled: true), isTrue);
  });
}
