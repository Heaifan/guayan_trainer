/// 四柱（日柱锚点 / 五虎遁 / 五鼠遁 / 年柱）自检（自 `tools/selftest.dart` 拆出）。
///
/// 期望值一律由「锚点 + JDN 差」**经程序**推出，禁止手算 ——
/// 手算在本次 Gate A 中已三次出错，是自检本身最容易翻车的地方。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/day/ganzhi_day.dart';
import 'package:guayan_trainer/domain/calendar/day/xun_kong.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/tian_gan.dart';

import '../../core/pillars/pillars.dart';
import 'suite.dart';

void checkPillars() {
  stdout.writeln('');
  stdout.writeln('== 日柱锚点（外部独立来源已核）==');
  // 外部来源 1：zhanbuwang.com / ximizi.net
  // 「西历 1949 年 10 月 1 日 … 己丑年 癸酉月 甲子日」。这是 JDN 锚点。
  check('1949-10-01 = 甲子', ganzhiDayOfDate(1949, 10, 1).label, '甲子');
  // 外部来源 2（跨 76 年、独立黄历站）：huangli999.com
  // 「2026 年 2 月 4 日黄历_己酉日」。
  // 两个来源必须同时成立，否则「锚点整体偏移」这类系统性错误不会被发现。
  check('2026-02-04 = 己酉（外部黄历已核）', ganzhiDayOfDate(2026, 2, 4).label, '己酉');
  // 其余期望值一律由「锚点 + JDN 差」**经程序**推出，禁止手算。
  // [expectedDelta] 与 [expectedKong] 为独立写入的哨兵值：
  // 若 JDN 公式或旬空算法漂移，这里会立刻报错。
  void anchored(String ymd, int expectedDelta, String expectedKong) {
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
  check('甲年寅月 = 丙寅', monthPillar(TianGan.jia, DiZhi.yin), '丙寅');
  check('丙年寅月 = 庚寅', monthPillar(TianGan.bing, DiZhi.yin), '庚寅');
  check('丙年酉月 = 丁酉', monthPillar(TianGan.bing, DiZhi.you), '丁酉');
  check('乙年丑月 = 己丑', monthPillar(TianGan.yi, DiZhi.chou), '己丑');

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
}
