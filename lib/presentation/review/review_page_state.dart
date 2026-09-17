/// 审卦页状态模型（纯 Dart，无 Flutter 依赖）。
///
/// 提供任务书 §7 要求的全部字段：question / castingMethod / solarDateTime /
/// lunarDateTime / shenShaItems / 四柱 / xunKong / 主变卦名 / lines[6] /
/// focusedLine / focusedRelations / rulePackId / ruleVersion。
/// Domain 尚未提供的传统排盘字段一律显式 nullable，不偷偷猜测。
library;

import '../../domain/line_state.dart';
import '../../domain/casting/fushen.dart';
import '../../domain/casting/double_fucang.dart';
import '../../domain/casting/hexagram_palace_profile.dart';
import '../../domain/relation_endpoint.dart';
import '../../domain/relation_instance.dart';
import '../../domain/relation_type.dart';
import '../../domain/relations/relation_record.dart';

/// 神煞标签项（§8「名称：值」结构，如 卦身：申）。
class ReviewShenShaItem {
  const ReviewShenShaItem({
    required this.name,
    required this.value,
    this.id,
    this.basisType,
    this.basisValue,
    this.ruleSetId,
    this.ruleVersion,
    this.reasonSnapshot,
  });

  final String name;
  final String value;
  final String? id;
  final String? basisType;
  final String? basisValue;
  final String? ruleSetId;
  final int? ruleVersion;
  final String? reasonSnapshot;

  String get label => '$name：$value';
}

/// 变卦单爻展示信息（§7 changedLine）。
class ReviewChangedLine {
  const ReviewChangedLine({
    this.sixRelative,
    this.earthlyBranch,
    this.displayExtra,
    this.movementType,
    this.isVoid = false,
    this.identity,
  });

  final String? sixRelative;
  final String? earthlyBranch;

  /// 五行 / 纳音等附加文本（如 天河水）。
  final String? displayExtra;

  /// 变爻爻象（排盘引擎未落地时可为空）。
  final MovementType? movementType;

  /// 变卦侧空亡（旬空，UI 表现专用；由排盘引擎提供 isVoid，Widget 不计算）。
  final bool isVoid;

  /// 变卦纳甲身份的结构化展示事实。
  final ReviewLineIdentity? identity;

  bool get isYang =>
      movementType == MovementType.shaoYang ||
      movementType == MovementType.laoYang;

  String get primaryLabel {
    final base = sixRelative ?? earthlyBranch;
    if (base == null) return '—';
    return isVoid ? '$base□□' : base;
  }
}

/// 六亲与纳甲干支的结构化展示事实；五行由领域层提供。
class ReviewLineIdentity {
  const ReviewLineIdentity({
    required this.relative,
    required this.ganZhi,
    required this.element,
  });

  final String relative;
  final String ganZhi;
  final String element;
}

/// 审卦页单行爻展示模型（§7 每行至少能渲染的字段）。
class ReviewLineView {
  const ReviewLineView({
    required this.position,
    required this.movementType,
    this.branch,
    this.sixSpirit,
    this.hiddenSpirit1,
    this.hiddenSpirit2,
    this.hiddenSpiritFacts = const [],
    this.primaryHidden,
    this.oppositeHidden,
    this.identity,
    this.sixRelative,
    this.displayExtra,
    this.shiYing,
    this.changedShiYing,
    this.changed,
    this.isVoid = false,
  });

  /// 爻位：1 = 初爻 … 6 = 上爻（稳定身份）。
  final int position;

  final MovementType movementType;

  /// 所值地支（来自 LineState）。
  final String? branch;

  /// 六神（排盘引擎未落地前由演示档案提供，真实计算为空）。
  final String? sixSpirit;

  /// 伏神1（如 财丙寅；不含「伏：」前缀）。
  final String? hiddenSpirit1;

  /// 伏神2。
  final String? hiddenSpirit2;

  /// 由本宫伏神引擎生成的结构化伏神事实；兼容字段仍保留给旧档案。
  final List<FushenResult> hiddenSpiritFacts;

  /// 全宫双伏藏的主伏与旁伏，按当前爻位各占一个固定子列。
  final HiddenPalaceLine? primaryHidden;
  final HiddenPalaceLine? oppositeHidden;

  /// 本卦六亲与纳甲的结构化展示事实。
  final ReviewLineIdentity? identity;

  /// 六亲 + 地支（如 父母丁未土）。
  final String? sixRelative;

  /// 五行 / 纳音附加文本（如 天河水）。
  final String? displayExtra;

  /// 本卦侧世应标记（'世' | '应' | null）。
  final String? shiYing;

  /// 变卦侧世应标记（SVG 定稿中部分世应落在变卦侧）。
  final String? changedShiYing;

  /// 变卦信息。
  final ReviewChangedLine? changed;

  /// 主卦侧空亡（旬空，UI 表现专用；由排盘引擎提供 isVoid，Widget 不计算）。
  final bool isVoid;

  bool get isYang =>
      movementType == MovementType.shaoYang ||
      movementType == MovementType.laoYang;

  String get yinYangLabel => isYang ? '阳' : '阴';

  String get movementLabel => movementType.isMoving ? '动' : '静';

  /// 主卦区主文本（六亲地支优先，其次地支）。
  String get mainPrimary {
    final base = sixRelative ?? branch;
    if (base == null) return '—';
    return isVoid ? '$base□□' : base;
  }
}

/// 审卦页完整状态快照（§7 全部字段；未接入字段显式 nullable）。
class ReviewPageState {
  const ReviewPageState({
    required this.question,
    this.category,
    required this.lines,
    required this.focusedRelations,
    required this.allRelations,
    this.relationRecords = const [],
    this.castingMethod,
    this.solarDateTime,
    this.lunarDateTime,
    this.shenShaItems = const [],
    this.yearPillar,
    this.yearNaYin,
    this.monthPillar,
    this.monthNaYin,
    this.dayPillar,
    this.dayNaYin,
    this.hourPillar,
    this.hourNaYin,
    this.xunKong,
    this.originalHexagramName,
    this.changedHexagramName,
    this.originalPalaceInfo,
    this.changedPalaceInfo,
    this.originalPalaceProfile,
    this.changedPalaceProfile,
    this.changedHexagramExtra,
    this.focusedLine,
    this.focusSummary,
    this.rulePackId,
    this.ruleVersion,
    this.caseId,
  });

  final String question;

  /// 主题分类（如事业、财运），不替代具体问事正文。
  final String? category;

  /// 备注作用域；同一卦例内复用，换卦自动隔离。
  final String? caseId;

  /// 起卦方式（铜钱手动等）；排盘引擎未接入时为空。
  final String? castingMethod;

  final DateTime? solarDateTime;

  /// 阴历文本（如 二零二六年七月十八日 酉时）。
  final String? lunarDateTime;

  final List<ReviewShenShaItem> shenShaItems;

  final String? yearPillar;
  final String? yearNaYin;
  final String? monthPillar;
  final String? monthNaYin;
  final String? dayPillar;
  final String? dayNaYin;
  final String? hourPillar;
  final String? hourNaYin;

  /// 旬空文本（如 申酉空）。
  final String? xunKong;

  final String? originalHexagramName;
  final String? changedHexagramName;

  /// 宫位信息（如 兑4）。
  final String? originalPalaceInfo;
  final String? changedPalaceInfo;

  final HexagramPalaceProfile? originalPalaceProfile;
  final HexagramPalaceProfile? changedPalaceProfile;

  /// 变卦附加说明（如 六合卦）。
  final String? changedHexagramExtra;

  /// 六爻视图：按 position 升序（1 初爻 .. 6 上爻）。
  final List<ReviewLineView> lines;

  /// 当前焦点爻位（1..6）；无动爻时可为空。
  final int? focusedLine;

  /// 与焦点相关的现有 RelationInstance（来自 Domain 计算，禁止字符串重算）。
  final List<RelationInstance> focusedRelations;

  /// 本卦全部关系实例（点爻弹层按爻过滤用，同样来自 Domain 计算）。
  final List<RelationInstance> allRelations;

  /// Ledger/Overlay 共享的统一投影记录。
  final List<RelationRecord> relationRecords;

  List<RelationRecord> get focusedRelationRecords => [
    for (final record in relationRecords)
      if (focusedLine == null ||
          record.participants.any(
            (endpoint) =>
                endpoint is YaoEndpoint && endpoint.position == focusedLine,
          ))
        record,
  ];

  List<RelationRecord> relationRecordsInvolving(int position) => [
    for (final record in relationRecords)
      if (record.kind == RelationKind.relation && record.participants.any(
        (endpoint) => endpoint is YaoEndpoint && endpoint.position == position,
      )) record,
  ];

  /// 焦点区摘要文案（演示档案可覆盖定稿文案，真实数据由实例生成）。
  final String? focusSummary;

  /// 规则包 id 与版本（来自 HexagramCase.ruleContext）。
  final String? rulePackId;
  final int? ruleVersion;

  /// 展示顺序：上爻在最上、初爻在最下（§22 C）。
  List<ReviewLineView> get displayLines => lines.reversed.toList();

  ReviewLineView lineAt(int position) => lines[position - 1];

  /// 某爻相关的全部关系实例（点爻弹层使用；数据来自 Domain，非字符串重算）。
  ///
  /// 月建 / 日辰端点不是爻，因此不会被「点某爻」命中。
  List<RelationInstance> relationsInvolving(int position) => [
    for (final r in allRelations)
      if (_isLine(r.source, position) || _isLine(r.target, position)) r,
  ];

  static bool _isLine(RelationEndpoint endpoint, int position) =>
      endpoint is YaoEndpoint && endpoint.position == position;

  String? get originalHexagramLabel {
    if (originalHexagramName == null && originalPalaceInfo == null) return null;
    final palace = originalPalaceInfo ?? originalPalaceProfile?.palace.label;
    final stage = originalPalaceProfile?.compactStage;
    final parts = [?palace, originalHexagramName ?? '—', ?stage];
    return parts.join(' · ');
  }

  String? get changedHexagramLabel {
    if (changedHexagramName == null && changedPalaceInfo == null) return null;
    final palace = changedPalaceInfo ?? changedPalaceProfile?.palace.label;
    final stage = changedPalaceProfile?.compactStage;
    final parts = [?palace, changedHexagramName ?? '—', ?stage];
    if (changedHexagramExtra != null) parts.add(changedHexagramExtra!);
    return parts.join(' · ');
  }
}

/// 关系筛选的纯数据入口；UI 只负责选择 [filter]，不重算关系。
List<RelationInstance> filterReviewRelations(
  ReviewPageState state,
  String filter,
) {
  if (filter == '全部') return state.allRelations;
  if (filter == '重点') return state.focusedRelations;
  return [
    for (final relation in state.allRelations)
      if (_matchesReviewFilter(relation, filter)) relation,
  ];
}

bool _matchesReviewFilter(RelationInstance relation, String filter) =>
    switch (filter) {
      '生克' =>
        relation.type == RelationType.sheng ||
            relation.type == RelationType.ke ||
            relation.type == RelationType.huiTouSheng ||
            relation.type == RelationType.huiTouKe,
      '冲合' =>
        relation.type == RelationType.liuChong ||
            relation.type == RelationType.liuHe,
      '月日' =>
        relation.source is MonthEndpoint ||
            relation.source is DayEndpoint ||
            relation.target is MonthEndpoint ||
            relation.target is DayEndpoint,
      '动变' =>
        relation.type == RelationType.dongBian ||
            relation.type == RelationType.huiTouSheng ||
            relation.type == RelationType.huiTouKe,
      '库' => false,
      _ => true,
    };

/// 阳历展示（如 2026-08-30 17:59）。
String formatSolar(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)} '
      '${two(time.hour)}:${two(time.minute)}';
}

/// 爻位展示名（1 初爻 .. 6 上爻）。
String reviewLinePositionName(int position) {
  const names = {1: '初爻', 2: '二爻', 3: '三爻', 4: '四爻', 5: '五爻', 6: '上爻'};
  return names[position] ?? '爻';
}
