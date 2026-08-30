/// 审卦页状态模型（纯 Dart，无 Flutter 依赖）。
///
/// 提供任务书 §7 要求的全部字段：question / castingMethod / solarDateTime /
/// lunarDateTime / shenShaItems / 四柱 / xunKong / 主变卦名 / lines[6] /
/// focusedLine / focusedRelations / rulePackId / ruleVersion。
/// Domain 尚未提供的传统排盘字段一律显式 nullable，不偷偷猜测。
library;

import '../../domain/line_state.dart';
import '../../domain/relation_instance.dart';

/// 神煞标签项（§8「名称：值」结构，如 卦身：申）。
class ReviewShenShaItem {
  const ReviewShenShaItem({required this.name, required this.value});

  final String name;
  final String value;

  String get label => '$name：$value';
}

/// 变卦单爻展示信息（§7 changedLine）。
class ReviewChangedLine {
  const ReviewChangedLine({
    this.sixRelative,
    this.earthlyBranch,
    this.displayExtra,
    this.movementType,
  });

  final String? sixRelative;
  final String? earthlyBranch;

  /// 五行 / 纳音等附加文本（如 天河水）。
  final String? displayExtra;

  /// 变爻爻象（排盘引擎未落地时可为空）。
  final MovementType? movementType;

  bool get isYang => movementType == MovementType.shaoYang ||
      movementType == MovementType.laoYang;

  String get primaryLabel {
    final base = sixRelative ?? earthlyBranch;
    if (base == null) return '—';
    return displayExtra == null ? base : '$base（$displayExtra）';
  }
}

/// 审卦页单行爻展示模型（§7 每行至少能渲染的字段）。
class ReviewLineView {
  const ReviewLineView({
    required this.position,
    required this.movementType,
    this.branch,
    this.sixSpirit,
    this.hiddenSpirit,
    this.sixRelative,
    this.displayExtra,
    this.shiYing,
    this.changedShiYing,
    this.changed,
  });

  /// 爻位：1 = 初爻 … 6 = 上爻（稳定身份）。
  final int position;

  final MovementType movementType;

  /// 所值地支（来自 LineState）。
  final String? branch;

  /// 六神（排盘引擎未落地前由演示档案提供，真实计算为空）。
  final String? sixSpirit;

  /// 伏神文本（不含「伏：」前缀，如 财丙寅　父丁未）。
  final String? hiddenSpirit;

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

  bool get isYang => movementType == MovementType.shaoYang ||
      movementType == MovementType.laoYang;

  String get yinYangLabel => isYang ? '阳' : '阴';

  String get movementLabel => movementType.isMoving ? '动' : '静';

  /// 主卦区主文本（六亲地支优先，其次地支）。
  String get mainPrimary {
    final base = sixRelative ?? branch;
    if (base == null) return '—';
    return displayExtra == null ? base : '$base（$displayExtra）';
  }
}

/// 审卦页完整状态快照（§7 全部字段；未接入字段显式 nullable）。
class ReviewPageState {
  const ReviewPageState({
    required this.question,
    required this.lines,
    required this.focusedRelations,
    this.castingMethod,
    this.solarDateTime,
    this.lunarDateTime,
    this.shenShaItems = const [],
    this.yearPillar,
    this.monthPillar,
    this.dayPillar,
    this.hourPillar,
    this.xunKong,
    this.originalHexagramName,
    this.changedHexagramName,
    this.originalPalaceInfo,
    this.changedPalaceInfo,
    this.changedHexagramExtra,
    this.focusedLine,
    this.focusSummary,
    this.rulePackId,
    this.ruleVersion,
  });

  final String question;

  /// 起卦方式（铜钱手动等）；排盘引擎未接入时为空。
  final String? castingMethod;

  final DateTime? solarDateTime;

  /// 阴历文本（如 二零二六年七月十八日 酉时）。
  final String? lunarDateTime;

  final List<ReviewShenShaItem> shenShaItems;

  final String? yearPillar;
  final String? monthPillar;
  final String? dayPillar;
  final String? hourPillar;

  /// 旬空文本（如 申酉空）。
  final String? xunKong;

  final String? originalHexagramName;
  final String? changedHexagramName;

  /// 宫位信息（如 兑4）。
  final String? originalPalaceInfo;
  final String? changedPalaceInfo;

  /// 变卦附加说明（如 六合卦）。
  final String? changedHexagramExtra;

  /// 六爻视图：按 position 升序（1 初爻 .. 6 上爻）。
  final List<ReviewLineView> lines;

  /// 当前焦点爻位（1..6）；无动爻时可为空。
  final int? focusedLine;

  /// 与焦点相关的现有 RelationInstance（来自 Domain 计算，禁止字符串重算）。
  final List<RelationInstance> focusedRelations;

  /// 焦点区摘要文案（演示档案可覆盖定稿文案，真实数据由实例生成）。
  final String? focusSummary;

  /// 规则包 id 与版本（来自 HexagramCase.ruleContext）。
  final String? rulePackId;
  final int? ruleVersion;

  /// 展示顺序：上爻在最上、初爻在最下（§22 C）。
  List<ReviewLineView> get displayLines => lines.reversed.toList();

  ReviewLineView lineAt(int position) => lines[position - 1];

  String? get originalHexagramLabel {
    if (originalHexagramName == null && originalPalaceInfo == null) return null;
    final parts = [?originalPalaceInfo, originalHexagramName ?? '—'];
    return parts.join(' · ');
  }

  String? get changedHexagramLabel {
    if (changedHexagramName == null && changedPalaceInfo == null) return null;
    final parts = [?changedPalaceInfo, changedHexagramName ?? '—'];
    if (changedHexagramExtra != null) parts.add(changedHexagramExtra!);
    return parts.join(' · ');
  }
}

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
