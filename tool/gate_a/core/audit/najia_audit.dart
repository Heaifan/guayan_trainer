/// 纳甲组装顺序复核（自 `hexagram_audit.dart` 拆出）。
///
/// 只判一件事：本卦六爻支是否等于「下卦内三支 + 上卦外三支」。
/// 顺序写反是纳甲最容易出的错，因此单独成文件、单独报错。
library;

import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/casting/najia.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

/// 纳甲组装顺序复核：本卦六爻支必须等于「下卦内三支 + 上卦外三支」。
List<String> verifyNajiaAssembly(Hexagram h, List<DiZhi> branches) {
  final expected = <DiZhi>[
    ...najiaByBagua[h.lower]!.sublist(0, 3),
    ...najiaByBagua[h.upper]!.sublist(3, 6),
  ];
  for (var i = 0; i < 6; i++) {
    if (expected[i] != branches[i]) {
      return [
        '纳甲组装顺序错误：第 ${i + 1} 爻 期望 ${expected[i].label} '
            '实际 ${branches[i].label}',
      ];
    }
  }
  return const <String>[];
}
