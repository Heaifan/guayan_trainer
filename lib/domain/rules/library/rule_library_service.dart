import '../core/rule_definition.dart';
import 'rule_folder.dart';
import 'rule_library_index.dart';
import 'rule_library_store.dart';

class RuleLibraryService {
  RuleLibraryService(this.store);

  final RuleLibraryStore store;
  RuleLibraryIndex _index = RuleLibraryIndex.defaults();

  RuleLibraryIndex get index => _index;

  Future<RuleLibraryIndex> load() async {
    _index = await store.load();
    return _index;
  }

  Future<RuleLibraryIndex> ensureMigrated(Iterable<RuleDefinition> customRules) async {
    if (_index.folders.isEmpty) _index = RuleLibraryIndex.defaults();
    final knownFolders = _index.folders.map((folder) => folder.folderId).toSet();
    final next = <String, String>{};
    for (final rule in customRules) {
      final folderId = _index.ruleFolderIds[rule.ruleId.id];
      next[rule.ruleId.id] = knownFolders.contains(folderId)
          ? folderId!
          : RuleFolder.uncategorizedId;
    }
    _index = RuleLibraryIndex(
      folders: _index.folders,
      ruleFolderIds: next,
      expandedFolderIds: _index.expandedFolderIds,
      schemaVersion: _index.schemaVersion,
    );
    await store.save(_index);
    return _index;
  }

  Future<RuleFolder> createFolder(String name, {String? parentFolderId}) async {
    _index = _index.createFolder(name, parentFolderId: parentFolderId);
    await store.save(_index);
    return _index.folders.last;
  }

  Future<void> renameFolder(String folderId, String name) async {
    final folder = _index.folderById(folderId);
    if (folder == null) throw ArgumentError('文件夹不存在: $folderId');
    _index = RuleLibraryIndex(
      folders: [for (final item in _index.folders) item.folderId == folderId ? item.copyWith(name: name) : item],
      ruleFolderIds: _index.ruleFolderIds,
      expandedFolderIds: _index.expandedFolderIds,
    );
    await store.save(_index);
  }

  Future<void> moveFolder(String folderId, String? parentFolderId) async {
    _index = _index.moveFolder(folderId, parentFolderId);
    await store.save(_index);
  }

  Future<void> moveRule(String ruleId, String folderId) async {
    _index = _index.moveRule(ruleId, folderId);
    await store.save(_index);
  }

  Future<void> setFolderEnabled(String folderId, bool enabled) async {
    _index = _index.setFolderEnabled(folderId, enabled);
    await store.save(_index);
  }

  Future<void> setExpanded(String folderId, bool expanded) async {
    _index = _index.setExpanded(folderId, expanded);
    await store.save(_index);
  }

  Future<void> deleteFolder(String folderId, {bool deleteContents = false}) async {
    final folder = _index.folderById(folderId);
    if (folder == null) throw ArgumentError('文件夹不存在: $folderId');
    if (folder.isUncategorized) throw ArgumentError('未分类不可删除');
    final parentId = folder.parentFolderId ?? RuleFolder.uncategorizedId;
    final descendants = _descendants(folderId);
    final removed = {folderId, ...descendants};
    final nextFolders = _index.folders.where((item) => !removed.contains(item.folderId)).toList();
    final nextRules = <String, String>{};
    for (final entry in _index.ruleFolderIds.entries) {
      if (!removed.contains(entry.value)) {
        nextRules[entry.key] = entry.value;
      } else if (!deleteContents) {
        nextRules[entry.key] = parentId;
      }
    }
    _index = RuleLibraryIndex(
      folders: nextFolders,
      ruleFolderIds: nextRules,
      expandedFolderIds: _index.expandedFolderIds.difference(removed),
    );
    await store.save(_index);
  }

  Set<String> _descendants(String folderId) {
    final result = <String>{};
    var changed = true;
    while (changed) {
      changed = false;
      for (final folder in _index.folders) {
        if (folder.parentFolderId != null &&
            (folder.parentFolderId == folderId || result.contains(folder.parentFolderId)) &&
            result.add(folder.folderId)) {
          changed = true;
        }
      }
    }
    return result;
  }
}
