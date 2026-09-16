import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/core/rule_origin.dart';
import '../../domain/rules/core/rule_id.dart';
import '../../domain/rules/core/rule_version.dart';
import '../../domain/rules/core/rule_stage.dart';
import '../../domain/rules/editor/custom_rule_service.dart';
import '../../domain/rules/editor/rule_editor_draft.dart';
import '../../domain/rules/editor/rule_version_bumper.dart';
import '../../domain/rules/topics/topic_rule_boundary_validator.dart';
import '../../domain/rules/ast/rule_expr.dart';
import 'rule_editor_form.dart';

class RuleEditorPage extends StatefulWidget {
  final CustomRuleService service;
  final RuleDefinition? initialRule;
  final bool isCopy;
  const RuleEditorPage({
    super.key,
    required this.service,
    this.initialRule,
    this.isCopy = false,
  });
  @override
  State<RuleEditorPage> createState() => _State();
}

class _State extends State<RuleEditorPage> {
  late RuleEditorDraft _draft;
  @override
  void initState() {
    super.initState();
    if (widget.initialRule != null) {
      _draft = RuleEditorDraft.fromDefinition(widget.initialRule!);
      if (widget.isCopy) {
        _draft.ruleId = RuleId('custom_${const Uuid().v4().substring(0, 8)}');
        _draft.origin = RuleOrigin.CUSTOM;
        _draft.version = RuleVersion('1.0.0');
        _draft.overrideTarget = null;
      }
    } else {
      _draft = RuleEditorDraft.fromDefinition(
        RuleDefinition(
          ruleId: RuleId('custom_${const Uuid().v4().substring(0, 8)}'),
          version: RuleVersion('1.0.0'),
          origin: RuleOrigin.CUSTOM,
          namespace: 'common',
          categoryId: 'common',
          stage: RuleStage.tag,
          title: '新规则',
          description: '',
          provenance: 'user',
          bindings: [],
          condition: const AllExpr([]),
          actions: [],
        ),
      );
    }
  }

  void _save() async {
    try {
      if (widget.initialRule != null && !widget.isCopy)
        _draft.version = RuleVersionBumper.bumpPatch(_draft.version);
      final def = _draft.toDefinition();
      final expectedId = def.namespace.startsWith('topic.')
          ? def.namespace.substring(6)
          : 'common';
      TopicRuleBoundaryValidator.validate(def, expectedId);
      await widget.service.store.addOrUpdate(def);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑规则'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: RuleEditorForm(draft: _draft, onChange: () => setState(() {})),
    );
  }
}
