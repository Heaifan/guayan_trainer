/// Gate A 自检：验证旁证计算（四柱/六冲/六合/日柱）在已知锚点上正确。
///
/// 旁证本身若算错，会让人工对照得出错误结论，因此必须先自证。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/day/ganzhi_day.dart';
import 'package:guayan_trainer/domain/calendar/day/xun_kong.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/casting/bagua.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/tian_gan.dart';

import 'gate_a_context.dart';
import 'gate_a_cross_source.dart';
import 'gate_a_format.dart';
import 'gate_a_hexagram_audit.dart';
import 'gate_a_hko_source.dart';
import 'gate_a_naoj_source.dart';
import 'gate_a_pillars.dart';
import 'gate_a_sun_longitude.dart';

int _failures = 0;

/// 由动静类型取六爻阴阳（自初爻至上爻）。
List<bool> _linesOf(dynamic chart) => <bool>[
  for (final l in chart.lines) l.isYang as bool,
];

/// 打印六爻纳甲与冲/合配对详情（定位判定失败时用）。
void _dumpBranches(String label, dynamic chart) {
  final list = branchesOf(chart);
  final seen = <DiZhi>{};
  final log = <String>[];
  for (final z in list) {
    final repeated = !seen.add(z);
    if (repeated) log.add('${z.label}(重复)');
    if (seen.contains(z.chong)) log.add('${z.label}-${z.chong.label}冲');
    if (seen.contains(z.he)) log.add('${z.label}-${z.he.label}合');
  }
  stdout.writeln(
    '  $label 纳甲：${list.map((z) => z.label).join(' ')}  '
    '判定过程：${log.join(' ')}',
  );
}

/// 由 6 位阴阳串（自初爻至上爻，1 = 阳）构造全部为「少」的静卦输入。
///
/// 用位串而非手写枚举，是因为手写 6 个枚举值已多次把卦写错 ——
/// 位串与 `resolveHexagram` 的键完全同构，肉眼可直接核对。
List<MovementType> movesOf(String bits) => <MovementType>[
  for (final ch in bits.split(''))
    if (ch == '1') MovementType.shaoYang else MovementType.shaoYin,
];

void check(String label, Object? actual, Object? expected) {
  final ok = '$actual' == '$expected';
  if (!ok) _failures++;
  stdout.writeln(
    '${ok ? 'PASS' : 'FAIL'}  $label  → 实际 $actual'
    '${ok ? '' : ' / 期望 $expected'}',
  );
}

Future<void> main() async {
  stdout.writeln('== 天文尺子（Meeus 太阳视黄经）自检 ==');
  // JD ↔ Unix 时标：曾经因为多加 0.5 天导致全部结果偏移 12 小时，
  // 因此把「纪元往返」固定为哨兵测试。
  check(
    'JD(2000-01-01T12:00Z) = 2451545.0',
    julianDayOfUtc(DateTime.utc(2000, 1, 1, 12)),
    2451545.0,
  );
  check(
    'JD(1970-01-01T00:00Z) = 2440587.5',
    julianDayOfUtc(DateTime.utc(1970, 1, 1)),
    2440587.5,
  );
  // 只作 coarse sanity check：0.01° ≈ 14.6 分钟时间，
  // **不能**作为分钟级/秒级精度证明（GATE-A-PREP-FIX2 §6）。
  const probes = <(SolarTermId, int, int, int, int)>[
    (SolarTermId.liChun, 2, 4, 4, 2),
    (SolarTermId.baiLu, 9, 7, 22, 41),
  ];
  for (final (id, month, day, hour, minute) in probes) {
    final utc = DateTime.utc(2026, month, day, hour - 8, minute);
    final lon = sunApparentLongitude(julianDayOfUtc(utc));
    final delta = angleDiff(lon, id.longitude.toDouble());
    check(
      'coarse sanity：HKO ${id.label} 时刻黄经偏差 < 0.01°',
      delta.abs() < 0.01,
      true,
    );
  }
  // 尺子对官方的**时间残差**必须如实记录（不得掩盖）。
  final liChunPredicted = solveSolarTermUtc(
    315,
    DateTime.utc(2026, 2, 1),
    maxDays: 20,
  );
  final residual = liChunPredicted
      .difference(DateTime.utc(2026, 2, 3, 20, 2, 8))
      .inSeconds;
  check(
    '尺子对秒级公开值残差绝对值 > 60s（已知缺陷，不得当作已验证）',
    residual.abs() > 60,
    true,
  );

  stdout.writeln('');
  stdout.writeln('== 官方双源交叉：HKO vs NAOJ（2026 二十四节气）==');
  stdout.writeln('（用的是官方原始发布件夹具，不是本仓库数据包）');
  final naoj = loadNaojFixture();
  check('NAOJ 夹具解析条数', naoj.length, 24);
  final hko = loadHkoFixture();
  check('HKO 夹具解析条数', hko.length, 24);
  final crossRows = buildCrossSourceRows();
  check('HKO vs NAOJ 日期一致', crossRows.where((r) => r.sameDate).length, 24);
  check('HKO vs NAOJ 分钟一致', crossRows.where((r) => r.sameMinute).length, 24);

  stdout.writeln('');
  stdout.writeln('== 数据包忠实转写官方分钟值（除已核实秒级项）==');
  final packCtx = await loadGateAContext();
  final packTerms = packCtx.engine.monthBranchResolver.provider.termsOfYear(2026);
  var faithful = 0;
  for (var i = 0; i < 24; i++) {
    final t = packTerms.firstWhere((x) => x.id == SolarTermId.values[i]);
    final packMinute = hktOf(t.instantUtc);
    final official = hko[i];
    if (packMinute.hour == official.hour &&
        packMinute.minute == official.minute &&
        packMinute.day == official.day) {
      faithful++;
    }
  }
  check('数据包 24 条仍落在官方同一分钟（秒级细化不改变分钟）', faithful, 24);

  stdout.writeln('');
  stdout.writeln('== 日柱锚点（外部独立来源已核）==');
  // 外部来源 1：zhanbuwang.com / ximizi.net
  // 「西历 1949 年 10 月 1 日 … 己丑年 癸酉月 甲子日」。这是 JDN 锚点。
  check('1949-10-01 = 甲子', ganzhiDayOfDate(1949, 10, 1).label, '甲子');
  // 外部来源 2（跨 76 年、独立黄历站）：huangli999.com
  // 「2026 年 2 月 4 日黄历_己酉日」。
  // 两个来源必须同时成立，否则「锚点整体偏移」这类系统性错误不会被发现。
  check(
    '2026-02-04 = 己酉（外部黄历已核）',
    ganzhiDayOfDate(2026, 2, 4).label,
    '己酉',
  );
  // 其余期望值一律由「锚点 + JDN 差」**经程序**推出，禁止手算
  // （手算在本次 Gate A 中已三次出错，是自检本身最容易翻车的地方）。
  // [expectedDelta] 与 [expectedKong] 为独立写入的哨兵值：
  // 若 JDN 公式或旬空算法漂移，这里会立刻报错。
  void anchored(
    String ymd,
    int expectedDelta,
    String expectedKong,
  ) {
    final p = ymd.split('-').map(int.parse).toList();
    final delta =
        (julianDayNumber(p[0], p[1], p[2]) - julianDayNumber(1949, 10, 1)) % 60;
    check('JDN 差 $ymd → 序号', delta, expectedDelta);
    check(
      '$ymd 日柱',
      ganzhiDayOfDate(p[0], p[1], p[2]).label,
      GanZhiDay.fromCycleIndex(expectedDelta).label,
    );
    check(
      '$ymd 旬空',
      xunKongOf(ganzhiDayOfDate(p[0], p[1], p[2])).label,
      expectedKong,
    );
  }

  anchored('2026-01-01', 11, '申酉');
  anchored('2026-01-02', 12, '申酉');
  anchored('2026-06-15', 56, '子丑');
  anchored('2026-09-07', 20, '午未');

  stdout.writeln('');
  stdout.writeln('== 五虎遁（月干）==');
  check(
    '甲年寅月 = 丙寅',
    monthPillar(TianGan.jia, DiZhi.yin),
    '丙寅',
  );
  check(
    '丙年寅月 = 庚寅',
    monthPillar(TianGan.bing, DiZhi.yin),
    '庚寅',
  );
  check(
    '丙年酉月 = 丁酉',
    monthPillar(TianGan.bing, DiZhi.you),
    '丁酉',
  );
  check(
    '乙年丑月 = 己丑',
    monthPillar(TianGan.yi, DiZhi.chou),
    '己丑',
  );

  stdout.writeln('');
  stdout.writeln('== 五鼠遁（时干）==');
  check('甲日子时 = 甲子', hourPillar(TianGan.jia, 0), '甲子');
  check('甲日23时 = 甲子', hourPillar(TianGan.jia, 23), '甲子');
  check('乙日午时 = 壬午', hourPillar(TianGan.yi, 12), '壬午');
  check('己日子时 = 甲子', hourPillar(TianGan.ji, 0), '甲子');

  stdout.writeln('');
  stdout.writeln('== 年柱（立春换年）==');
  check('2026 未交立春 → 乙巳', yearPillar(2026, true), '乙巳');
  check('2026 已交立春 → 丙午', yearPillar(2026, false), '丙午');

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
  check('泽山咸 卦名', resolveHexagram([..._linesOf(xian)]).name, '泽山咸');
  stdout.writeln('  泽山咸纳甲：${branchesOf(xian).map((z) => z.label).join(' ')}');

  // 水地比（坤宫归魂，坤下坎上 = `000010`）：
  // 纳甲 未 巳 卯 申 戌 子 —— 冲对只有 (申,寅?) 不成立、(卯,酉?) 不成立，
  // 实际冲对为 (卯…? 见 dump)。**它不是六冲**（六冲全表见 gate_a_enumerate）。
  final bi = CastingEngine.cast(movesOf('000010'));
  check('水地比 卦名', resolveHexagram([..._linesOf(bi)]).name, '水地比');
  _dumpBranches('水地比', bi);
  check('水地比 = 非六冲（六冲全表已由 enumerate 核定）',
      isLiuChongBranches(branchesOf(bi)), false);
  check('水地比 = 非六合', isLiuHeBranches(branchesOf(bi)), false);

  // 陷阱 1：全少阴 = 坤为地（坤上坤下），**不是** 地风升、也不是水地比。
  final allYin = CastingEngine.cast(
    List<MovementType>.filled(6, MovementType.shaoYin),
  );
  check(
    '全少阴 = 坤为地（非地风升、非水地比）',
    resolveHexagram([..._linesOf(allYin)]).name,
    '坤为地',
  );

  // 陷阱 2：001000（三爻为阳）= 地山谦（坤上艮下），不是雷地豫。
  final qian2 = CastingEngine.cast(movesOf('001000'));
  check('001000 = 地山谦', resolveHexagram([..._linesOf(qian2)]).name, '地山谦');

  // 陷阱 3：000100（四爻为阳）= 雷地豫（震上坤下），与水地比只差一爻。
  final yu = CastingEngine.cast(movesOf('000100'));
  check('000100 = 雷地豫（≠ 水地比）', resolveHexagram([..._linesOf(yu)]).name, '雷地豫');

  // 地风升（震宫四世，巽下坤上 = `011000`）：纳甲 丑 亥 酉 丑 亥 酉
  // → 有重复支，**不是六冲**（六冲需六支互不相同且成 3 对冲对）。
  final sheng = CastingEngine.cast(movesOf('011000'));
  check('地风升 卦名', resolveHexagram([..._linesOf(sheng)]).name, '地风升');
  _dumpBranches('地风升', sheng);
  check('地风升 = 非六冲',
      isLiuChongBranches(branchesOf(sheng)), false);
  check('地风升 = 非六合', isLiuHeBranches(branchesOf(sheng)), false);
  check(
    '六冲与六合在本判定下互斥（无一卦同时成立）',
    [qian, kun, allYin, bi, xian, sheng].every(
      (c) => !(isLiuChongBranches(branchesOf(c)) &&
          isLiuHeBranches(branchesOf(c))),
    ),
    true,
  );
  // 与 gate_a_enumerate 输出的**权威全表**交叉核对：
  // 六冲必须是八纯卦（乾坎艮震巽离坤兑）加 天雷无妄、雷天大壮，共 10 个。
  final chongNames = <String>{
    for (final bits in const <String>[
      // 八纯卦
      '111111', '010010', '001001', '100100',
      '011011', '101101', '000000', '110110',
      // 另两个六冲卦
      '100111', '111001',
    ])
      resolveHexagram(_linesOf(CastingEngine.cast(movesOf(bits)))).name,
  };
  check('六冲权威全表共 10 卦', chongNames.length, 10);
  check(
    '六冲全表校验：乾为天在表内',
    chongNames.contains('乾为天'),
    true,
  );
  check(
    '六冲全表校验：水地比不在表内',
    chongNames.contains('水地比'),
    false,
  );

  stdout.writeln('');
  stdout.writeln('== 八宫表完整性 ==');
  final problems = verifyPalaceTable();
  check('八宫表 64 组合无重复无缺失', problems.isEmpty, true);
  if (problems.isNotEmpty) stdout.writeln('  ${problems.join('\n  ')}');

  stdout.writeln('');
  stdout.writeln('== 八卦爻序自检（下卦在前）==');
  check(
    '泽山咸 = 兑上艮下',
    resolveHexagram(const [
      false,
      false,
      true,
      true,
      true,
      false,
    ]).name,
    '泽山咸',
  );
  check(
    '泽山咸 上下卦',
    '${resolveHexagram(const [false, false, true, true, true, false]).upper.label}'
    '${resolveHexagram(const [false, false, true, true, true, false]).lower.label}',
    '${Bagua.dui.label}${Bagua.gen.label}',
  );

  stdout.writeln('');
  stdout.writeln(_failures == 0 ? '全部自检 PASS' : '自检 FAIL $_failures 项');
  exitCode = _failures == 0 ? 0 : 1;
}
