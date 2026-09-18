import 'package:flutter/material.dart';

import '../../../domain/rules/engine/rule_trace.dart';

class RuleTraceTree extends StatelessWidget {
  const RuleTraceTree({super.key, required this.trace, this.depth = 0});
  final RuleTrace trace;
  final int depth;

  Color get _color => switch (trace.status) {
        RuleTraceStatus.matched || RuleTraceStatus.success => Colors.green,
        RuleTraceStatus.skipped => Colors.grey,
        RuleTraceStatus.error || RuleTraceStatus.failed => Colors.red,
        RuleTraceStatus.notMatched => Colors.orange,
      };

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: depth * 18.0, top: 4, bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Icon(trace.status == RuleTraceStatus.matched ||
                  trace.status == RuleTraceStatus.success
              ? Icons.check_circle
              : Icons.circle, size: 16, color: _color),
          const SizedBox(width: 6),
          Expanded(child: Text(trace.label)),
          Text(_statusLabel(trace.status), style: TextStyle(color: _color)),
        ]),
        if (trace.expected != null)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text('期望：${trace.expected}  实际：${trace.actual ?? '未知'}'),
          ),
        if (trace.reason != null)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text(_reasonLabel(trace.reason!), style: TextStyle(color: _color)),
          ),
        for (final child in trace.children)
          RuleTraceTree(trace: child, depth: depth + 1),
      ],
    ),
  );

  String _statusLabel(RuleTraceStatus status) => switch (status) {
        RuleTraceStatus.matched => '已命中',
        RuleTraceStatus.notMatched => '未命中',
        RuleTraceStatus.skipped => '跳过',
        RuleTraceStatus.error => '错误',
        RuleTraceStatus.success => '成功',
        RuleTraceStatus.failed => '失败',
      };

  String _reasonLabel(String reason) => switch (reason) {
        'NO_MATCH' => '未找到对象',
        _ => reason,
      };
}
