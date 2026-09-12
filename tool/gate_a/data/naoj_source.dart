/// NAOJ「暦要項」二十四節気解析（**纯离线**，Shift_JIS 字节级解析）。
///
/// 为什么走字节级：NAOJ 页面声明 `encoding="Shift_JIS"`，而 `dart:convert`
/// 不内置 Shift_JIS。与其引入第三方编码表，不如**只依赖 ASCII 结构**：
/// 页面上每条节气形如 `<黄经度數>° <月>月<日>日 <時>時<分>分`，
/// 而黄经度数恰好是 15 的整数倍且按小寒(285°)起顺序出现，
/// 因此按「黄经度数」定位比按汉字名定位更稳。
library;

import 'dart:convert';
import 'dart:io';

/// 一条 NAOJ 节气记录（JST 挂钟时间）。
class NaojTerm {
  const NaojTerm({
    required this.longitude,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
  });

  /// 太阳黄经（度）。
  final int longitude;
  final int month;
  final int day;
  final int hour;
  final int minute;

  /// JST（UTC+9）→ HKT（UTC+8）：**减 1 小时**，可能跨日。
  DateTime get hktJstShifted =>
      DateTime.utc(2026, month, day, hour, minute)
          .subtract(const Duration(hours: 1));

  @override
  String toString() =>
      '黄经$longitude° $month月$day日 $hour:${minute.toString().padLeft(2, '0')}';
}

/// 二十四节气黄经，按公历年内顺序（自小寒 285° 起）。
const List<int> naojLongitudeOrder = <int>[
  285, 300, 315, 330, 345, 0, 15, 30,
  45, 60, 75, 90, 105, 120, 135, 150,
  165, 180, 195, 210, 225, 240, 255, 270,
];

/// 解析 NAOJ 页面字节。
///
/// 用 latin1 解码保持「一字节一字符」，于是所有 ASCII 数字与标点原样可得，
/// 汉字虽成乱码但不参与定位。
List<NaojTerm> parseNaojPageBytes(List<int> bytes) {
  final text = latin1.decode(bytes, allowInvalid: true);
  // 形如：class="center">285<度>< /td><td> 1<月>05<日>< /td> <td>17<時>23<分>
  // 汉字是 Shift_JIS 双字节，故各数字之间隔着 2～20 个非数字字符；
  // 用「非贪婪 + 有界」的间隔匹配，避免跨行吞掉别的数字。
  final pattern = RegExp(
    r'(\d{1,3})\D{2,20}?(\d{1,2})\D{2,10}?(\d{1,2})'
    r'\D{2,20}?(\d{1,2})\D{2,10}?(\d{1,2})',
  );

  final found = <int, NaojTerm>{};
  for (final m in pattern.allMatches(text)) {
    final longitude = int.parse(m.group(1)!);
    if (!naojLongitudeOrder.contains(longitude)) continue;
    final month = int.parse(m.group(2)!);
    final day = int.parse(m.group(3)!);
    final hour = int.parse(m.group(4)!);
    final minute = int.parse(m.group(5)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) continue;
    if (hour > 23 || minute > 59) continue;
    // 同一黄经只保留首次出现（页面里 285 等数字在别处也会出现）。
    found.putIfAbsent(
      longitude,
      () => NaojTerm(
        longitude: longitude,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
      ),
    );
  }
  return [for (final lon in naojLongitudeOrder) if (found[lon] != null) found[lon]!];
}

/// 从本地夹具读取（仓库内已缓存，保证离线可重复）。
List<NaojTerm> loadNaojFixture([String path = _fixturePath]) {
  final file = File(path);
  if (!file.existsSync()) {
    throw StateError('缺少 NAOJ 夹具：$path');
  }
  return parseNaojPageBytes(file.readAsBytesSync());
}

const String _fixturePath = 'tool/gate_a/data/fixtures/naoj/rekiyou262.2026.html';

/// 夹具路径（供报告展示来源）。
String get naojFixturePath => _fixturePath;
