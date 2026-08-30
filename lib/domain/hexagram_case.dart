/// 一次真实占问 / 卦例的持久化根对象（本轮最小骨架）。
///
/// 只承载 Stable Relation Identity 需要的原始输入状态：
/// 卦例 id、问事、起卦时间、六爻状态。
/// 关系实例与笔记不落在此对象内 —— 关系每次从原始状态重算，
/// 笔记通过 (caseId + RelationKey) 另行绑定，从而证明「重算不失忆」。
/// category / favorite / outcome / rulePackSnapshot 等留待后续阶段。
library;

import 'line_state.dart';

class HexagramCase {
  const HexagramCase({
    required this.id,
    required this.question,
    required this.lines,
    required this.createdAt,
  });

  /// 稳定卦例身份：调用方给定并在持久化时原样保存。
  /// 禁止用数据库自增 row id / UUID 承担此业务身份。
  final String id;

  /// 问事内容（可为空字符串）。
  final String question;

  /// 六爻状态，按 position 升序（1..6 = 初爻..上爻）。
  final List<LineState> lines;

  /// 起卦时间。
  final DateTime createdAt;

  LineState lineAt(int position) =>
      lines.firstWhere((l) => l.position == position);

  Map<String, Object?> toJson() => {
        'id': id,
        'question': question,
        'createdAt': createdAt.toIso8601String(),
        'lines': lines.map((l) => l.toJson()).toList(),
      };

  factory HexagramCase.fromJson(Map<String, Object?> json) => HexagramCase(
        id: json['id'] as String,
        question: json['question'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        lines: (json['lines'] as List<Object?>)
            .map((e) => LineState.fromJson(e as Map<String, Object?>))
            .toList(),
      );

  @override
  String toString() => 'HexagramCase($id, ${lines.length} lines)';
}
