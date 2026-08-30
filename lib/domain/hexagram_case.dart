/// 一次真实占问 / 卦例的持久化根对象（本轮最小骨架）。
///
/// 只承载 Stable Relation Identity 需要的原始输入状态：
/// 卦例 id、问事、起卦时间、六爻状态、规则版本上下文。
/// 关系实例与笔记不落在此对象内 —— 关系每次从原始状态重算，
/// 笔记通过 (caseId + RelationKey) 另行绑定，从而证明「重算不失忆」。
/// category / favorite / outcome / rulePackSnapshot 等留待后续阶段。
library;

import 'line_state.dart';
import 'rule_execution_context.dart';

class HexagramCase {
  const HexagramCase._({
    required this.id,
    required this.question,
    required this.lines,
    required this.createdAt,
    required this.ruleContext,
  });

  /// 唯一构造入口：runtime 校验六爻不变量
  /// （恰好 6 爻、position 恰为 {1..6}、无重复），
  /// 坏数据无法进入关系计算器生成重复 RelationKey。
  factory HexagramCase({
    required String id,
    required String question,
    required List<LineState> lines,
    required DateTime createdAt,
    RuleExecutionContext ruleContext = const RuleExecutionContext.empty(),
  }) {
    _validateLines(lines);
    return HexagramCase._(
      id: id,
      question: question,
      lines: lines,
      createdAt: createdAt,
      ruleContext: ruleContext,
    );
  }

  /// 稳定卦例身份：调用方给定并在持久化时原样保存。
  /// 禁止用数据库自增 row id / UUID 承担此业务身份。
  final String id;

  /// 问事内容（可为空字符串）。
  final String question;

  /// 六爻状态，按 position 升序（1..6 = 初爻..上爻）。
  final List<LineState> lines;

  /// 起卦时间。
  final DateTime createdAt;

  /// 规则版本上下文：记录计算关系时各规则使用的版本，
  /// 重算旧卦例时据此复现历史 RelationKey（replay 契约）。
  final RuleExecutionContext ruleContext;

  LineState lineAt(int position) =>
      lines.firstWhere((l) => l.position == position);

  static void _validateLines(List<LineState> lines) {
    if (lines.length != 6) {
      throw ArgumentError.value(
        lines.length,
        'lines.length',
        '六爻卦必须恰好 6 爻',
      );
    }
    final positions = lines.map((l) => l.position).toSet();
    if (positions.length != 6) {
      throw ArgumentError('爻位重复或缺失：必须恰好为 {1,2,3,4,5,6}');
    }
    for (final p in positions) {
      if (p < 1 || p > 6) {
        throw ArgumentError.value(p, 'position', '爻位必须在 1..6');
      }
    }
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'question': question,
        'createdAt': createdAt.toIso8601String(),
        'lines': lines.map((l) => l.toJson()).toList(),
        'ruleContext': ruleContext.toJson(),
      };

  factory HexagramCase.fromJson(Map<String, Object?> json) => HexagramCase(
        id: json['id'] as String,
        question: json['question'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        lines: (json['lines'] as List<Object?>)
            .map((e) => LineState.fromJson(e as Map<String, Object?>))
            .toList(),
        ruleContext: json['ruleContext'] == null
            ? const RuleExecutionContext.empty()
            : RuleExecutionContext.fromJson(
                json['ruleContext'] as Map<String, Object?>),
      );

  @override
  String toString() => 'HexagramCase($id, ${lines.length} lines)';
}
