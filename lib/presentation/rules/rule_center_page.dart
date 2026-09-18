import 'package:flutter/material.dart';
import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/core/rule_origin.dart';
import '../../domain/rules/editor/custom_rule_service.dart';
import 'rule_editor_page.dart';
import '../../domain/rules/editor/rule_editor_draft.dart';
import 'rule_list_item.dart';
import '../../domain/hexagram_case.dart';

class RuleCenterPage extends StatefulWidget {
  final CustomRuleService service;
  final List<RuleDefinition> systemRules;
  final HexagramCase? testCase;
  const RuleCenterPage({
    super.key,
    required this.service,
    required this.systemRules,
    this.testCase,
  });
  @override
  State<RuleCenterPage> createState() => _State();
}

class _State extends State<RuleCenterPage> {
  late List<RuleDefinition> _merged;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(() => _merged = widget.service.store.getAll());

  Future<void> _toggleEnable(RuleDefinition r, bool val) async {
    if (r.origin == RuleOrigin.SYSTEM) {
      await widget.service.governance.setSystemRuleEnabled(r.ruleId, val);
    } else {
      final updated = RuleEditorDraft.fromDefinition(r)..enabled = val;
      await widget.service.store.addOrUpdate(updated.toDefinition());
    }
    _refresh();
  }

  void _edit(RuleDefinition? r, bool isCopy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RuleEditorPage(
          service: widget.service,
          initialRule: r,
          isCopy: isCopy,
          testCase: widget.testCase,
        ),
      ),
    ).then((_) => _refresh());
  }

  Future<void> _delete(RuleDefinition r) async {
    final conf = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (conf == true) {
      await widget.service.store.delete(r.ruleId);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义规则')),
      body: _merged.isEmpty
          ? const Center(child: Text('还没有自定义规则'))
          : ListView.builder(
              itemCount: _merged.length,
              itemBuilder: (c, i) => RuleListItem(
                r: _merged[i],
                onToggle: (v) => _toggleEnable(_merged[i], v),
                onEdit: () => _edit(_merged[i], false),
                onCopy: () => _edit(_merged[i], true),
                onDelete: () => _delete(_merged[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(null, false),
        child: const Icon(Icons.add),
      ),
    );
  }
}
