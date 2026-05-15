class DizhiInfo {
  final String name;
  final String wuxing;
  final String yinyang;
  final String direction;
  final String month;

  const DizhiInfo({
    required this.name,
    required this.wuxing,
    required this.yinyang,
    required this.direction,
    required this.month,
  });
}

class DizhiData {
  static const List<DizhiInfo> branches = [
    DizhiInfo(name: '子', wuxing: '水', yinyang: '阳', direction: '北', month: '十一月'),
    DizhiInfo(name: '丑', wuxing: '土', yinyang: '阴', direction: '东北', month: '十二月'),
    DizhiInfo(name: '寅', wuxing: '木', yinyang: '阳', direction: '东北', month: '正月'),
    DizhiInfo(name: '卯', wuxing: '木', yinyang: '阴', direction: '东', month: '二月'),
    DizhiInfo(name: '辰', wuxing: '土', yinyang: '阳', direction: '东南', month: '三月'),
    DizhiInfo(name: '巳', wuxing: '火', yinyang: '阴', direction: '东南', month: '四月'),
    DizhiInfo(name: '午', wuxing: '火', yinyang: '阳', direction: '南', month: '五月'),
    DizhiInfo(name: '未', wuxing: '土', yinyang: '阴', direction: '西南', month: '六月'),
    DizhiInfo(name: '申', wuxing: '金', yinyang: '阳', direction: '西南', month: '七月'),
    DizhiInfo(name: '酉', wuxing: '金', yinyang: '阴', direction: '西', month: '八月'),
    DizhiInfo(name: '戌', wuxing: '土', yinyang: '阳', direction: '西北', month: '九月'),
    DizhiInfo(name: '亥', wuxing: '水', yinyang: '阴', direction: '西北', month: '十月'),
  ];

  static List<String> get names => branches.map((e) => e.name).toList();

  static DizhiInfo byName(String name) {
    return branches.firstWhere((e) => e.name == name);
  }
}
