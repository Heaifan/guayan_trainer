/// Gate A 案例定义：普通卦例 / 经典卦体 / 节气边界 / 日界专项。
///
/// 案例一旦定稿即**不得为迎合结果而修改**：矩阵是验收基准，
/// 不是可调参数。任何调整都必须留在 Gate A 记录里并说明理由。
///
/// 六爻一律用**位串**声明（自初爻至上爻，1 = 阳），并与 [expectedOriginal]
/// 交叉锁定：位串与 `resolveHexagram` 的键完全同构，肉眼可直接核对。
/// 用枚举手写 6 个动静值在本轮已多次把卦写错，因此不再允许那种写法。
library;

import 'package:guayan_trainer/domain/calendar/day_boundary_rule.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/line_state.dart';

/// 一个六爻输入案例。
class GateACase {
  const GateACase({
    required this.id,
    required this.group,
    required this.localTime,
    required this.originalBits,
    this.movingPositions = const <int>[],
    required this.expectedOriginal,
    this.expectedChanged,
    required this.purpose,
  });

  /// 案例编号，如 `GA-01`。
  final String id;

  /// 所属分组：`GA-1` / `GA-2`。
  final String group;

  /// 当地挂钟时间文本 `YYYY-MM-DD HH:mm:ss`。
  final String localTime;

  /// 本卦六爻阴阳位串。
  ///
  /// 键约定与 `resolveHexagram` 的 `_key` **完全一致：index 0 = 初爻 … index 5 = 上爻**，
  /// 即前三位是**下卦（内卦）**、后三位是**上卦（外卦）**。
  /// 例：泽地萃 = 下坤 000 + 上兑 110 = `000110`。
  final String originalBits;

  /// 动爻下标（**0..5，与 [originalBits] 的字符下标严格一致**）；
  /// 空 = 静卦。展示时统一 +1 转成人读的 1..6 爻位。
  ///
  /// 之所以内部用 0 基：`originalBits[i]` 与 `movingPositions` 必须同坐标，
  /// 两者一个 0 基一个 1 基曾导致三例位串/动爻错配。
  final List<int> movingPositions;

  /// 本卦卦名（用于**锁定**案例，防止位串写错）。
  final String expectedOriginal;

  /// 变卦卦名；静卦为 null。
  final String? expectedChanged;

  /// 本例要覆盖的点。
  final String purpose;

  /// 六爻动静（自初爻至上爻）。
  List<MovementType> get movements {
    final out = <MovementType>[];
    for (var i = 0; i < 6; i++) {
      final yang = originalBits[i] == '1';
      final moving = movingPositions.contains(i);
      out.add(switch ((yang, moving)) {
        (true, false) => MovementType.shaoYang,
        (true, true) => MovementType.laoYang,
        (false, false) => MovementType.shaoYin,
        (false, true) => MovementType.laoYin,
      });
    }
    return out;
  }

  /// 变卦十进位值（变爻翻阴阳后）。
  int get changedValue {
    var v = 0;
    for (var i = 0; i < 6; i++) {
      var yang = originalBits[i] == '1';
      if (movingPositions.contains(i)) yang = !yang;
      if (yang) v += 1 << i;
    }
    return v;
  }

  /// 本卦十进位值（与 [bitsValue] 同构，便于交叉校验）。
  int get originalValue => bitsValue(originalBits);

  /// 六爻输入的可读文本，如 `7 8 9 8 7 6`。
  String get inputText =>
      movements.map((m) => movementDigit(m)).join(' ');

  /// 动爻显示文本（1 基爻位，人读）。
  String get movingText => movingPositions.isEmpty
      ? '静卦'
      : '${movingPositions.map((i) => i + 1).join('、')} 爻动';

  /// 动爻爻位（1..6，人读）。
  List<int> get movingLineNumbers =>
      [for (final i in movingPositions) i + 1];
}

/// 少阳 / 少阴 / 老阳 / 老阴 的惯用数字记法（7/8/9/6）。
int movementDigit(MovementType m) => switch (m) {
  MovementType.shaoYang => 7,
  MovementType.shaoYin => 8,
  MovementType.laoYang => 9,
  MovementType.laoYin => 6,
};

/// 位串 → 十进位值（与八卦表同构），供人工快速核对位串写成。
int bitsValue(String bits) {
  var v = 0;
  for (var i = 0; i < 6; i++) {
    if (bits[i] == '1') v += 1 << i;
  }
  return v;
}

/// GA-1 普通真实卦例：覆盖不同月份、不同干支日、不同八宫、
/// 有变/无变、单变/多变，以及六冲、六合、游魂、归魂。
const List<GateACase> normalCases = <GateACase>[
  GateACase(
    id: 'GA-01',
    group: 'GA-1',
    localTime: '2026-01-08 09:30:00',
    originalBits: '111111',
    expectedOriginal: '乾为天',
    purpose: '乾宫本宫卦·六冲·静卦·甲子旬（旬空申酉）·丑月',
  ),
  GateACase(
    id: 'GA-02',
    group: 'GA-1',
    localTime: '2026-02-12 20:15:00',
    originalBits: '000000',
    expectedOriginal: '坤为地',
    purpose: '坤宫本宫卦·六冲·静卦·子丑旬空·寅月（立春后）',
  ),
  GateACase(
    id: 'GA-03',
    group: 'GA-1',
    localTime: '2026-02-25 14:00:00',
    originalBits: '100000',
    movingPositions: <int>[0],
    expectedOriginal: '地雷复',
    expectedChanged: '坤为地',
    purpose: '坤宫六合卦·一世（世1应4）·初爻动·六神起例',
  ),
  GateACase(
    id: 'GA-04',
    group: 'GA-1',
    localTime: '2026-03-15 10:20:30',
    originalBits: '010000',
    movingPositions: <int>[1],
    expectedOriginal: '地水师',
    expectedChanged: '坤为地',
    purpose: '坎宫归魂（世3应6）·二爻动·秒级输入 10:20:30·卯月',
  ),
  GateACase(
    id: 'GA-05',
    group: 'GA-1',
    localTime: '2026-04-10 16:45:00',
    originalBits: '100100',
    movingPositions: <int>[3],
    expectedOriginal: '震为雷',
    expectedChanged: '地雷复',
    purpose: '震宫本宫卦·六冲·四爻动·辰月',
  ),
  GateACase(
    id: 'GA-06',
    group: 'GA-1',
    localTime: '2026-05-20 07:05:00',
    originalBits: '000000',
    expectedOriginal: '坤为地',
    purpose: '坤宫本宫卦·六冲·静卦（与 GA-02 不同干支日：甲午日）·巳月',
  ),
  GateACase(
    id: 'GA-07',
    group: 'GA-1',
    localTime: '2026-06-15 21:40:00',
    originalBits: '010000',
    movingPositions: <int>[1],
    expectedOriginal: '地水师',
    expectedChanged: '坤为地',
    purpose: '坎宫归魂·二爻动（与 GA-04 不同干支日：庚申日）·午月',
  ),
  GateACase(
    id: 'GA-08',
    group: 'GA-1',
    localTime: '2026-07-22 11:11:00',
    originalBits: '100100',
    movingPositions: <int>[3],
    expectedOriginal: '震为雷',
    expectedChanged: '地雷复',
    purpose: '震宫本宫卦·六冲·四爻动·六亲含土（辰戌丑未）·未月',
  ),
  GateACase(
    id: 'GA-09',
    group: 'GA-1',
    localTime: '2026-08-22 18:30:00',
    originalBits: '000110',
    movingPositions: <int>[0, 1, 3],
    expectedOriginal: '泽地萃',
    expectedChanged: '水泽节',
    purpose: '兑宫（金）二世·初、二、四三爻同动·**变卦为六合卦（水泽节）**·'
        '验证变卦六亲仍取本卦宫·申月',
  ),
  GateACase(
    id: 'GA-10',
    group: 'GA-1',
    localTime: '2026-09-07 23:20:00',
    originalBits: '101000',
    movingPositions: <int>[2],
    expectedOriginal: '地火明夷',
    expectedChanged: '地雷复',
    purpose: '坎宫游魂（世4应1）·三爻动·23 时后（日界敏感时刻）·酉月',
  ),
  GateACase(
    id: 'GA-11',
    group: 'GA-1',
    localTime: '2026-10-12 05:50:00',
    originalBits: '100000',
    movingPositions: <int>[0],
    expectedOriginal: '地雷复',
    expectedChanged: '坤为地',
    purpose: '坤宫六合卦·初爻动·戌月',
  ),
  GateACase(
    id: 'GA-12',
    group: 'GA-1',
    localTime: '2026-11-18 15:00:00',
    originalBits: '100001',
    movingPositions: <int>[3],
    expectedOriginal: '山雷颐',
    expectedChanged: '火雷噬嗑',
    purpose: '巽宫（木）游魂（世4应1）·四爻动·亥月',
  ),
  GateACase(
    id: 'GA-13',
    group: 'GA-1',
    localTime: '2026-12-10 08:20:00',
    originalBits: '100000',
    movingPositions: <int>[1, 2],
    expectedOriginal: '地雷复',
    expectedChanged: '地天泰',
    purpose: '坤宫六合卦·二、三两爻同动（**多变爻**）·'
        '变卦为本宫三世（地天泰，**亦为六合**）·子月',
  ),
];

/// GA-2 经典卦体专项（人工确认，R3-A Golden Tests 之外的第二道）。
const List<GateACase> classicCases = <GateACase>[
  GateACase(
    id: 'GA-C-01',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '111111',
    expectedOriginal: '乾为天',
    purpose: '乾为天：本宫卦世6应3·纳甲甲子甲寅甲辰壬午壬申壬戌·六冲·静卦',
  ),
  GateACase(
    id: 'GA-C-02',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '000000',
    expectedOriginal: '坤为地',
    purpose: '坤为地：本宫卦世6应3·纳甲乙未乙巳乙卯癸丑癸亥癸酉·六冲·静卦',
  ),
  GateACase(
    id: 'GA-C-03',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '001110',
    expectedOriginal: '泽山咸',
    purpose: '泽山咸：兑宫三世（世3应6）·纳甲丙辰丙午丙申丁亥丁酉丁未',
  ),
  GateACase(
    id: 'GA-C-04',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '111101',
    expectedOriginal: '火天大有',
    purpose: '火天大有：乾宫**归魂**（世3应6）·'
        '纳甲己卯己丑己亥壬午壬申壬戌·宫位五行为金',
  ),
  GateACase(
    id: 'GA-C-05',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '100001',
    expectedOriginal: '山雷颐',
    purpose: '山雷颐：巽宫**游魂**（世4应1）·宫位五行为木（与他宫不同）',
  ),
  GateACase(
    id: 'GA-C-06',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '010000',
    movingPositions: <int>[1],
    expectedOriginal: '地水师',
    expectedChanged: '坤为地',
    purpose: '地水师：坎宫归魂（世3应6）·二爻动，专门验证'
        '**变卦六亲仍取本卦宫（坎水）为「我」**',
  ),
];

/// GA-3 节气边界：**序号编排说明**。
///
/// 实际测试点由 `gate_a_solar_term_report.dart` 从**官方发布值**（HKO 数据包，
/// 并由 NAOJ 交叉印证）逐节生成，覆盖 2026 年全部十二「节」；
/// 本常量只保留「节气 → 序号」的稳定编号约定（`GA-ST-<黄经序>`），
/// 不再承载测试点定义，避免矩阵与真值来源分家。
class SolarTermBoundaryCase {
  const SolarTermBoundaryCase({
    required this.id,
    required this.term,
    required this.year,
    required this.purpose,
  });

  /// 案例编号，如 `GA-ST-01`。
  final String id;

  /// 节气标识。
  final SolarTermId term;

  /// 取哪一年的该节气（**显式指定**，避免误取到相邻年份的同名节气）。
  final int year;

  /// 该例要覆盖的点。
  final String purpose;

  /// 完整标题，如 `立春 2026`。
  String get title => '${term.label} $year';
}

/// 日界专项：跨「子时」的连续时间轴。
///
/// 时间点**带完整日期归属**：子时横跨两个公历日
/// （23:00—23:59 属前一公历日 `d1`、00:00—00:59 属后一公历日 `d1+1`），
/// 若只写挂钟时刻会造成时间轴歧义。
class DayBoundaryCase {
  const DayBoundaryCase({
    required this.id,
    required this.date,
    required this.purpose,
  });

  final String id;

  /// 基准公历日期 `YYYY-MM-DD`（记作 `d1`）。
  final String date;

  final String purpose;
}

/// 时间轴偏移点（相对基准日 `d1 00:00:00` 的偏移 + 展示标签）。
class DayClockPoint {
  const DayClockPoint(this.label, this.offset);

  /// 展示标签，如 `d1 23:00:00`。
  final String label;

  /// 相对 `d1 00:00:00` 的偏移。
  final Duration offset;
}

/// 六个关键挂钟时刻（§13），带完整日期归属：
/// `d1 22:59:59` → `d1 23:00:00` → `d1 23:30:00` → `d1 23:59:59`
/// → `d1+1 00:00:00` → `d1+1 00:00:01`。
const List<DayClockPoint> dayBoundaryClockPoints = <DayClockPoint>[
  DayClockPoint('d1 22:59:59', Duration(hours: 22, minutes: 59, seconds: 59)),
  DayClockPoint('d1 23:00:00', Duration(hours: 23)),
  DayClockPoint('d1 23:30:00', Duration(hours: 23, minutes: 30)),
  DayClockPoint('d1 23:59:59', Duration(hours: 23, minutes: 59, seconds: 59)),
  DayClockPoint('d1+1 00:00:00', Duration(days: 1)),
  DayClockPoint('d1+1 00:00:01', Duration(days: 1, seconds: 1)),
];

/// GA-4 日界案例。
const List<DayBoundaryCase> dayBoundaryCases = <DayBoundaryCase>[
  DayBoundaryCase(
    id: 'GA-DAY-01',
    date: '2026-09-07',
    purpose: '普通日（白露当日 22:41 交节，可同时观察月建是否同为 22:41 切换）',
  ),
  DayBoundaryCase(
    id: 'GA-DAY-02',
    date: '2026-12-31',
    purpose: '跨公历年（23:00 在 ziHourStart 下进入 2027-01-01）',
  ),
  DayBoundaryCase(
    id: 'GA-DAY-03',
    date: '2026-01-31',
    purpose: '跨公历月（23:00 在 ziHourStart 下进入 2 月 1 日）',
  ),
];

/// 日界两种规则的展示顺序。
const List<DayBoundaryRule> dayBoundaryRules = <DayBoundaryRule>[
  DayBoundaryRule.midnight,
  DayBoundaryRule.ziHourStart,
];

/// 规则中文名。
String dayBoundaryRuleLabel(DayBoundaryRule rule) => switch (rule) {
  DayBoundaryRule.midnight => 'midnight（00:00 换日）',
  DayBoundaryRule.ziHourStart => 'ziHourStart（23:00 子初换日）',
};
