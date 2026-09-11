/// HKO「二十四節氣」XML 解析（**官方原始发布件**，非数据包）。
///
/// 为什么单独解析：交叉核验要证明的是*官方两源一致*，
/// 不能用被本仓库修改过的 `assets/calendar/*.json` 当输入 ——
/// 那会把「数据包是否忠实转写官方值」和「官方两源是否一致」两件事混在一起。
library;

import 'dart:convert';
import 'dart:io';

/// 一条 HKO 节气记录（HKT 挂钟）。
class HkoTerm {
  const HkoTerm({
    required this.index,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
  });

  /// 在文件中的顺序（自小寒起，0..23）。
  final int index;
  final int month;
  final int day;
  final int hour;
  final int minute;

  /// HKT 挂钟。
  DateTime get hkt => DateTime.utc(2026, month, day, hour, minute);

  @override
  String toString() =>
      '$month月$day日 $hour:${minute.toString().padLeft(2, '0')} HKT';
}

/// 解析 HKO XML 字节。
///
/// 结构固定为 `<Data><M>月</M><D>日</D><hm>時:分</hm></Data>`，
/// 顺序即公历年内顺序（自小寒起）。
List<HkoTerm> parseHkoXmlBytes(List<int> bytes) {
  final text = utf8.decode(bytes, allowMalformed: true);
  final pattern = RegExp(
    r'<Data>\s*<M>(\d{1,2})</M>\s*<D>(\d{1,2})</D>\s*<hm>(\d{1,2}):(\d{2})</hm>',
  );
  final out = <HkoTerm>[];
  for (final m in pattern.allMatches(text)) {
    out.add(
      HkoTerm(
        index: out.length,
        month: int.parse(m.group(1)!),
        day: int.parse(m.group(2)!),
        hour: int.parse(m.group(3)!),
        minute: int.parse(m.group(4)!),
      ),
    );
  }
  return out;
}

/// 仓库内缓存的官方 XML 夹具路径。
const String hkoFixturePath = 'tool/gate_a/hko/24SolarTerms_2026.xml';

/// 从本地夹具读取（离线、可重复）。
List<HkoTerm> loadHkoFixture([String path = hkoFixturePath]) {
  final file = File(path);
  if (!file.existsSync()) {
    throw StateError('缺少 HKO 夹具：$path');
  }
  return parseHkoXmlBytes(file.readAsBytesSync());
}
