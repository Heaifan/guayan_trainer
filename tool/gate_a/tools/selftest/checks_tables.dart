/// 全表与结构自检（自 `tools/selftest.dart` 拆出）。
///
/// 三块都是「拿**整张表**去核对」的检查，因此归在一起：
/// 1. 六冲权威全表（八纯卦 + 天雷无妄 + 雷天大壮，共 10 卦）；
/// 2. 八宫表完整性（64 组合一一对应、每宫 8 卦、世应相隔三位）；
/// 3. 八卦爻序（下卦在前）。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/casting/bagua.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';

import '../../core/audit/hexagram_audit.dart';
import 'suite.dart';

void checkTables() {
  // 与 gate_a_enumerate 输出的**权威全表**交叉核对：
  // 六冲必须是八纯卦（乾坎艮震巽离坤兑）加 天雷无妄、雷天大壮，共 10 个。
  final chongNames = <String>{
    for (final bits in const <String>[
      // 八纯卦
      '111111',
      '010010',
      '001001',
      '100100',
      '011011',
      '101101',
      '000000',
      '110110',
      // 另两个六冲卦
      '100111',
      '111001',
    ])
      resolveHexagram(linesOf(CastingEngine.cast(movesOf(bits)))).name,
  };
  check('六冲权威全表共 10 卦', chongNames.length, 10);
  check('六冲全表校验：乾为天在表内', chongNames.contains('乾为天'), true);
  check('六冲全表校验：水地比不在表内', chongNames.contains('水地比'), false);

  stdout.writeln('');
  stdout.writeln('== 八宫表完整性 ==');
  final problems = verifyPalaceTable();
  check('八宫表 64 组合无重复无缺失', problems.isEmpty, true);
  if (problems.isNotEmpty) stdout.writeln('  ${problems.join('\n  ')}');

  stdout.writeln('');
  stdout.writeln('== 八卦爻序自检（下卦在前）==');
  check(
    '泽山咸 = 兑上艮下',
    resolveHexagram(const [false, false, true, true, true, false]).name,
    '泽山咸',
  );
  check(
    '泽山咸 上下卦',
    '${resolveHexagram(const [false, false, true, true, true, false]).upper.label}'
        '${resolveHexagram(const [false, false, true, true, true, false]).lower.label}',
    '${Bagua.dui.label}${Bagua.gen.label}',
  );
}
