import 'package:flutter/material.dart';

import '../../../domain/rules/engine/rule_trace.dart';
import '../review_page_state.dart';

class ReviewRuleRunsCard extends StatelessWidget {
  const ReviewRuleRunsCard({super.key, required this.state, this.onOpen});

  final ReviewPageState state;
  final ValueChanged<RuleTrace>? onOpen;

  @override
  Widget build(BuildContext context) {
    final traces = [
      for (final run in state.ruleRuns) ...run.traces,
    ];
    final rules = traces.where((trace) => trace.kind == RuleTraceKind.rule).toList();
    final matched = rules.where((trace) => trace.status == RuleTraceStatus.matched).length;
    return Card(
      key: const Key('review_rule_runs_card'),
      child: ExpansionTile(
        title: Text('规则运行    $matched / ${rules.length}'),
        children: [
          if (rules.isEmpty)
            const ListTile(title: Text('暂无规则运行记录'))
          else
            for (final trace in rules)
              ListTile(
                dense: true,
                leading: Text(_icon(trace.status)),
                title: Text(trace.label),
                subtitle: Text(_status(trace.status)),
                onTap: onOpen == null ? null : () => onOpen!(trace),
              ),
        ],
      ),
    );
  }

  String _icon(RuleTraceStatus status) => switch (status) {
        RuleTraceStatus.matched || RuleTraceStatus.success => '✓',
        RuleTraceStatus.notMatched => '○',
        RuleTraceStatus.skipped => '—',
        RuleTraceStatus.error || RuleTraceStatus.failed => '!',
      };

  String _status(RuleTraceStatus status) => switch (status) {
        RuleTraceStatus.matched => '已命中',
        RuleTraceStatus.notMatched => '未命中',
        RuleTraceStatus.skipped => '未参与',
        RuleTraceStatus.error => '执行错误',
        RuleTraceStatus.success => '成功',
        RuleTraceStatus.failed => '失败',
      };
}
