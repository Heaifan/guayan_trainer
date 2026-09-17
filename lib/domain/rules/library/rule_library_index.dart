import 'rule_folder.dart';

class RuleLibraryIndex {
  const RuleLibraryIndex({
    required this.folders,
    required this.ruleFolderIds,
    required this.expandedFolderIds,
    this.schemaVersion = 1,
  });

  final List<RuleFolder> folders;
  final Map<String, String> ruleFolderIds;
  final Set<String> expandedFolderIds;
  final int schemaVersion;

  factory RuleLibraryIndex.defaults() => const RuleLibraryIndex(
    folders: [
      RuleFolder(folderId: RuleFolder.uncategorizedId, name: '未分类', reservedKind: 'uncategorized'),
      RuleFolder(folderId: RuleFolder.importedId, name: '导入规则', reservedKind: 'imported'),
    ],
    ruleFolderIds: {},
    expandedFolderIds: {RuleFolder.uncategorizedId, RuleFolder.importedId},
  );

  Map<String, RuleFolder> get _byId => {
    for (final folder in folders) folder.folderId: folder,
  };

  RuleFolder? folderById(String id) => _byId[id];

  RuleLibraryIndex createFolder(String name, {String? parentFolderId}) {
    if (parentFolderId != null && folderById(parentFolderId) == null) {
      throw ArgumentError('父文件夹不存在: $parentFolderId');
    }
    final id = 'folder:${DateTime.now().microsecondsSinceEpoch}';
    return _replace(
      folders: [
      ...folders,
      RuleFolder(folderId: id, name: name, parentFolderId: parentFolderId, sortOrder: folders.length),
      ],
      expandedFolderIds: {...expandedFolderIds, id},
    );
  }

  RuleLibraryIndex assignRule(String ruleId, {String? folderId}) {
    final target = folderId ?? RuleFolder.uncategorizedId;
    return _replace(ruleFolderIds: {
      ...ruleFolderIds,
      ruleId: folderById(target) == null ? RuleFolder.uncategorizedId : target,
    });
  }

  RuleLibraryIndex moveRule(String ruleId, String folderId) => assignRule(ruleId, folderId: folderId);

  RuleLibraryIndex moveFolder(String folderId, String? newParentFolderId) {
    final folder = folderById(folderId);
    if (folder == null) throw ArgumentError('文件夹不存在: $folderId');
    if (folderId == RuleFolder.uncategorizedId) throw ArgumentError('未分类不可移动');
    if (newParentFolderId == folderId || _descendants(folderId).contains(newParentFolderId)) {
      throw ArgumentError('不能移动到自身或子文件夹');
    }
    if (newParentFolderId != null && folderById(newParentFolderId) == null) {
      throw ArgumentError('父文件夹不存在: $newParentFolderId');
    }
    return _replace(folders: [
      for (final item in folders)
        item.folderId == folderId
            ? item.copyWith(parentFolderId: newParentFolderId, clearParent: newParentFolderId == null)
            : item,
    ]);
  }

  RuleLibraryIndex setFolderEnabled(String folderId, bool enabled) {
    if (folderById(folderId) == null) throw ArgumentError('文件夹不存在: $folderId');
    return _replace(folders: [
      for (final folder in folders)
        folder.folderId == folderId ? folder.copyWith(enabled: enabled) : folder,
    ]);
  }

  RuleLibraryIndex setExpanded(String folderId, bool expanded) {
    final next = {...expandedFolderIds};
    expanded ? next.add(folderId) : next.remove(folderId);
    return _replace(expandedFolderIds: next);
  }

  bool effectiveEnabled(String ruleId, {required bool ruleEnabled}) {
    if (!ruleEnabled) return false;
    var folderId = ruleFolderIds[ruleId];
    if (folderId == null) return false;
    while (folderId != null) {
      final folder = folderById(folderId);
      if (folder == null || !folder.enabled) return false;
      folderId = folder.parentFolderId;
    }
    return true;
  }

  int recursiveRuleCount(String folderId) {
    final ids = {folderId, ..._descendants(folderId)};
    return ruleFolderIds.values.where(ids.contains).length;
  }

  Set<String> _descendants(String folderId) {
    final result = <String>{};
    var changed = true;
    while (changed) {
      changed = false;
      for (final folder in folders) {
        if (folder.parentFolderId != null &&
            (folder.parentFolderId == folderId || result.contains(folder.parentFolderId)) &&
            result.add(folder.folderId)) {
          changed = true;
        }
      }
    }
    return result;
  }

  RuleLibraryIndex _replace({
    List<RuleFolder>? folders,
    Map<String, String>? ruleFolderIds,
    Set<String>? expandedFolderIds,
  }) => RuleLibraryIndex(
    folders: List.unmodifiable(folders ?? this.folders),
    ruleFolderIds: Map.unmodifiable(ruleFolderIds ?? this.ruleFolderIds),
    expandedFolderIds: Set.unmodifiable(expandedFolderIds ?? this.expandedFolderIds),
    schemaVersion: schemaVersion,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'folders': folders.map((folder) => folder.toJson()).toList(),
    'ruleFolderIds': ruleFolderIds,
    'expandedFolderIds': expandedFolderIds.toList(),
  };

  factory RuleLibraryIndex.fromJson(Map<String, Object?> json) => RuleLibraryIndex(
    schemaVersion: json['schemaVersion'] as int? ?? 1,
    folders: (json['folders'] as List? ?? const [])
        .map((item) => RuleFolder.fromJson(Map<String, Object?>.from(item as Map)))
        .toList(),
    ruleFolderIds: Map<String, String>.from(json['ruleFolderIds'] as Map? ?? const {}),
    expandedFolderIds: Set<String>.from(json['expandedFolderIds'] as List? ?? const []),
  );
}
