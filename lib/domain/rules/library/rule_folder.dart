class RuleFolder {
  const RuleFolder({
    required this.folderId,
    required this.name,
    this.parentFolderId,
    this.enabled = true,
    this.sortOrder = 0,
    this.reservedKind,
  });

  static const uncategorizedId = 'system:uncategorized';
  static const importedId = 'system:imported';

  final String folderId;
  final String name;
  final String? parentFolderId;
  final bool enabled;
  final int sortOrder;
  final String? reservedKind;

  bool get isUncategorized => folderId == uncategorizedId;

  RuleFolder copyWith({
    String? name,
    String? parentFolderId,
    bool clearParent = false,
    bool? enabled,
    int? sortOrder,
  }) => RuleFolder(
    folderId: folderId,
    name: name ?? this.name,
    parentFolderId: clearParent ? null : parentFolderId ?? this.parentFolderId,
    enabled: enabled ?? this.enabled,
    sortOrder: sortOrder ?? this.sortOrder,
    reservedKind: reservedKind,
  );

  Map<String, Object?> toJson() => {
    'folderId': folderId,
    'name': name,
    'parentFolderId': parentFolderId,
    'enabled': enabled,
    'sortOrder': sortOrder,
    'reservedKind': reservedKind,
  };

  factory RuleFolder.fromJson(Map<String, Object?> json) => RuleFolder(
    folderId: json['folderId'] as String,
    name: json['name'] as String,
    parentFolderId: json['parentFolderId'] as String?,
    enabled: json['enabled'] as bool? ?? true,
    sortOrder: json['sortOrder'] as int? ?? 0,
    reservedKind: json['reservedKind'] as String?,
  );
}
