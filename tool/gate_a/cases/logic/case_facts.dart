/// 卦例事实模型：一个卦例「有哪些事实」。
///
/// 自 `cases/derive.dart` 拆出：**模型**与**推导**是两件事 ——
/// 本文件只描述事实字段与派生取值，推导在 `derive.dart` 的
/// `computeCaseFacts` 里。分开后两边都能单独读完。
library;

import 'package:guayan_trainer/domain/calendar/calendar_context.dart';
import 'package:guayan_trainer/domain/casting/cast_chart.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';

import '../../core/audit/hexagram_audit.dart';
import '../logic/case_model.dart';

/// 一个卦例的全部对照事实。
class CaseFacts {
  const CaseFacts({
    required this.def,
    required this.local,
    required this.calendar,
    required this.chart,
    required this.beforeLiChun,
    required this.auditProblems,
  });

  final GateACase def;

  /// 起卦当地挂钟时间（已解析，供派生取值复用）。
  final DateTime local;

  final CalendarContext calendar;
  final CastChart chart;

  /// 该时刻是否尚未交立春（决定年柱/月干的「年」）。
  final bool beforeLiChun;

  /// 结构自检问题（案例锁定 + 纳甲组装顺序）。
  final List<String> auditProblems;

  /// 本卦。
  Hexagram get original => chart.original;

  /// 变卦；静卦为 null。
  Hexagram? get changed => chart.changed;

  /// 六爻地支自初爻至上爻。
  List<DiZhi> get branches => branchesOf(chart);

  /// 卦体特征标签。
  String get bodyLabelText => bodyLabel(original, branches);

  /// 动爻显示文本。
  String get movingText => def.movingText;

  /// 是否为六冲卦。
  bool get isLiuChong => isLiuChongBranches(branches);

  /// 是否为六合卦。
  bool get isLiuHe => isLiuHeBranches(branches);

  /// 变卦六爻地支；静卦为 null。
  List<DiZhi>? get changedBranches =>
      chart.changed == null ? null : changedBranchList;

  /// 变卦六爻地支（仅变卦存在时有意义）。
  List<DiZhi> get changedBranchList => [
    for (final l in chart.lines) l.changedBranch!,
  ];

  /// 变卦是否为六合卦 / 六冲卦（静卦为 false）。
  bool get isChangedLiuHe {
    final b = changedBranches;
    return b != null && isLiuHeBranches(b);
  }

  bool get isChangedLiuChong {
    final b = changedBranches;
    return b != null && isLiuChongBranches(b);
  }
}
