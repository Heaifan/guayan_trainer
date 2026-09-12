/// 节气官方参照模型（自 `solar_term_report.dart` 拆出）。
///
/// 「官方」= 数据包（HKO，分钟精度）+ 可追溯的秒级公开值。
/// 自建天文尺子的输出**永远不得**进入这里（它已被判为 REJECTED AS ORACLE）。
library;

import 'package:guayan_trainer/domain/calendar/solar_term/solar_term_id.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

/// 可追溯的秒级公开值（来源必须写明；来源不明者**不得**收录）。
class SecondLevelReference {
  const SecondLevelReference({
    required this.term,
    required this.year,
    required this.hkt,
    required this.source,
    required this.note,
  });

  final SolarTermId term;
  final int year;

  /// 公布时刻（+08:00 挂钟）。
  final DateTime hkt;
  final String source;
  final String note;
}

/// 秒级哨兵表。
///
/// 只收录**能指明发布机构**的值。`04:01:51` 因无法确认来源，已被排除。
final List<SecondLevelReference> secondLevelReferences = <SecondLevelReference>[
  SecondLevelReference(
    term: SolarTermId.liChun,
    year: 2026,
    // 2026-02-04 04:02:08 (+08:00)
    hkt: DateTime.utc(2026, 2, 4, 4, 2, 8),
    source: '中国科学院紫金山天文台科普部公开值',
    note: '与 HKO 分钟值 04:02、NAOJ 换算值 04:02 同分钟一致',
  ),
];

/// 某年某节的官方参照（数据包 = HKO）。
class OfficialTermReference {
  const OfficialTermReference({
    required this.term,
    required this.year,
    required this.packHkt,
    required this.isSecondPrecise,
    this.secondLevel,
  });

  final SolarTermId term;
  final int year;

  /// 数据包（HKO，分钟精度）交节时刻（HKT）。
  final DateTime packHkt;

  /// 该瞬间在数据包中的记录精度是否为秒级。
  final bool isSecondPrecise;

  /// 可追溯秒级公开值（若存在）。
  final SecondLevelReference? secondLevel;

  /// 该节切换出去的旧月建。
  DiZhi get oldMonth => previousMonthBranch(term);

  /// 该节开入的新月建。
  DiZhi get newMonth => term.monthBranch!;
}

/// 该「节」所切换出去的月建。
DiZhi previousMonthBranch(SolarTermId id) => switch (id) {
  SolarTermId.xiaoHan => DiZhi.zi,
  SolarTermId.liChun => DiZhi.chou,
  SolarTermId.jingZhe => DiZhi.yin,
  SolarTermId.qingMing => DiZhi.mao,
  SolarTermId.liXia => DiZhi.chen,
  SolarTermId.mangZhong => DiZhi.si,
  SolarTermId.xiaoShu => DiZhi.wu,
  SolarTermId.liQiu => DiZhi.wei,
  SolarTermId.baiLu => DiZhi.shen,
  SolarTermId.hanLu => DiZhi.you,
  SolarTermId.liDong => DiZhi.xu,
  SolarTermId.daXue => DiZhi.hai,
  _ => throw ArgumentError.value(id, 'id', '不是十二「节」之一'),
};
