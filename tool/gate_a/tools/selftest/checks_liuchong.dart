/// 六冲 / 六合 判定自检（自 `tools/selftest.dart` 拆出）。
///
/// 六冲 / 六合 不是 R3 冻结范围，但它们决定 GA-1 的覆盖标签，
/// 因此必须有一组**可复现的判定**，而不是靠手感分类；
/// 三个已知陷阱（全少阴、001000、000100）是历史上真正写错过的地方。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/line_state.dart';

import '../../core/audit/hexagram_audit.dart';
import 'suite.dart';

void checkLiuChong() {
  stdout.writeln('');
  stdout.writeln('== 六冲 / 六合 判定 ==');
  final qian = CastingEngine.cast(
    List<MovementType>.filled(6, MovementType.shaoYang),
  );
  check('乾为天 = 六冲', isLiuChongBranches(branchesOf(qian)), true);
  final kun = CastingEngine.cast(
    List<MovementType>.filled(6, MovementType.shaoYin),
  );
  check('坤为地 = 六冲', isLiuChongBranches(branchesOf(kun)), true);

  // 泽山咸（静卦，艮下兑上）：纳甲 辰 午 申 亥 酉 未
  // → 合对 (辰,酉)(午,未)(申,巳?) 申的合为巳（不在卦中）→ 2 对，非六合。
  final xian = CastingEngine.cast(<MovementType>[
    MovementType.shaoYin,
    MovementType.shaoYin,
    MovementType.shaoYang,
    MovementType.shaoYang,
    MovementType.shaoYang,
    MovementType.shaoYin,
  ]);
  check('泽山咸 卦名', resolveHexagram([...linesOf(xian)]).name, '泽山咸');
  stdout.writeln('  泽山咸纳甲：${branchesOf(xian).map((z) => z.label).join(' ')}');

  // 水地比（坤宫归魂，坤下坎上 = `000010`）：
  // 纳甲 未 巳 卯 申 戌 子 —— 冲对只有 (申,寅?) 不成立、(卯,酉?) 不成立，
  // 实际冲对为 (卯…? 见 dump)。**它不是六冲**（六冲全表见 gate_a_enumerate）。
  final bi = CastingEngine.cast(movesOf('000010'));
  check('水地比 卦名', resolveHexagram([...linesOf(bi)]).name, '水地比');
  dumpBranches('水地比', bi);
  check(
    '水地比 = 非六冲（六冲全表已由 enumerate 核定）',
    isLiuChongBranches(branchesOf(bi)),
    false,
  );
  check('水地比 = 非六合', isLiuHeBranches(branchesOf(bi)), false);

  // 陷阱 1：全少阴 = 坤为地（坤上坤下），**不是** 地风升、也不是水地比。
  final allYin = CastingEngine.cast(
    List<MovementType>.filled(6, MovementType.shaoYin),
  );
  check(
    '全少阴 = 坤为地（非地风升、非水地比）',
    resolveHexagram([...linesOf(allYin)]).name,
    '坤为地',
  );

  // 陷阱 2：001000（三爻为阳）= 地山谦（坤上艮下），不是雷地豫。
  final qian2 = CastingEngine.cast(movesOf('001000'));
  check('001000 = 地山谦', resolveHexagram([...linesOf(qian2)]).name, '地山谦');

  // 陷阱 3：000100（四爻为阳）= 雷地豫（震上坤下），与水地比只差一爻。
  final yu = CastingEngine.cast(movesOf('000100'));
  check('000100 = 雷地豫（≠ 水地比）', resolveHexagram([...linesOf(yu)]).name, '雷地豫');

  // 地风升（震宫四世，巽下坤上 = `011000`）：纳甲 丑 亥 酉 丑 亥 酉
  // → 有重复支，**不是六冲**（六冲需六支互不相同且成 3 对冲对）。
  final sheng = CastingEngine.cast(movesOf('011000'));
  check('地风升 卦名', resolveHexagram([...linesOf(sheng)]).name, '地风升');
  dumpBranches('地风升', sheng);
  check('地风升 = 非六冲', isLiuChongBranches(branchesOf(sheng)), false);
  check('地风升 = 非六合', isLiuHeBranches(branchesOf(sheng)), false);
  check(
    '六冲与六合在本判定下互斥（无一卦同时成立）',
    [qian, kun, allYin, bi, xian, sheng].every(
      (c) =>
          !(isLiuChongBranches(branchesOf(c)) &&
              isLiuHeBranches(branchesOf(c))),
    ),
    true,
  );
}
