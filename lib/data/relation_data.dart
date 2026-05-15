class RelationData {
  static const Map<String, String> sixChong = {
    '子': '午',
    '丑': '未',
    '寅': '申',
    '卯': '酉',
    '辰': '戌',
    '巳': '亥',
  };

  static const Map<String, String> sixHe = {
    '子': '丑',
    '寅': '亥',
    '卯': '戌',
    '辰': '酉',
    '巳': '申',
    '午': '未',
  };

  static String? getChongPartner(String branch) {
    if (sixChong.containsKey(branch)) return sixChong[branch];
    for (final entry in sixChong.entries) {
      if (entry.value == branch) return entry.key;
    }
    return null;
  }

  static String? getHePartner(String branch) {
    if (sixHe.containsKey(branch)) return sixHe[branch];
    for (final entry in sixHe.entries) {
      if (entry.value == branch) return entry.key;
    }
    return null;
  }

  static String getBranchRelation(String a, String b) {
    final chong = getChongPartner(a);
    final he = getHePartner(a);

    if (chong == b) return '六冲';
    if (he == b) return '六合';
    return '无特殊冲合';
  }
}
