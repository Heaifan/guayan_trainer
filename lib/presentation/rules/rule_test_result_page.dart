import 'package:flutter/material.dart';

import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/engine/rule_test_runner.dart';
import '../../domain/rules/facts/fact_snapshot.dart';
import 'widgets/rule_trace_tree.dart';

class RuleTestResultPage extends StatelessWidget {
  const RuleTestResultPage({super.key, required this.rule, required this.snapshot});
  final RuleDefinition rule;
  final FactSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final run = const RuleTestRunner().run(rule, snapshot);
    return Scaffold(
      appBar: AppBar(title: Text('测试：${rule.title}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('测试规则（不会修改正式卦例或 RuleRun）',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          for (final trace in run.traces) RuleTraceTree(trace: trace),
          if (run.traces.isEmpty) const Text('规则未参与执行'),
        ],
      ),
    );
  }
}
