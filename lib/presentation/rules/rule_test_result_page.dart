import 'package:flutter/material.dart';

import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/engine/rule_test_runner.dart';
import '../../domain/rules/facts/fact_snapshot.dart';
import '../../domain/hexagram_case.dart';
import '../../domain/casting/casting_engine.dart';
import 'widgets/rule_trace_tree.dart';

class RuleTestResultPage extends StatelessWidget {
  const RuleTestResultPage({super.key, required this.rule, required this.snapshot, required this.testCase});
  final RuleDefinition rule;
  final FactSnapshot snapshot;
  final HexagramCase testCase;

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
          Text('测试卦例：${_hexagramName(testCase)} · ${testCase.createdAt.toLocal().toString().split('.').first}'),
          const SizedBox(height: 12),
          for (final trace in run.traces) RuleTraceTree(trace: trace),
          if (run.traces.isEmpty) const Text('规则未参与执行'),
        ],
      ),
    );
  }

  String _hexagramName(HexagramCase value) => CastingEngine.cast([
        for (final line in value.lines) line.movementType,
      ]).original.name;
}
