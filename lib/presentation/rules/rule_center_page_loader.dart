import 'package:flutter/material.dart';
import '../../domain/rules/corpus/common_rule_corpus.dart';
import '../../domain/rules/topics/exam/exam_rule_corpus.dart';
import '../../domain/rules/editor/custom_rule_service.dart';
import '../../domain/rules/editor/custom_rule_store.dart';
import '../../domain/rules/editor/user_governance_state.dart';
import 'rule_center_page.dart';
import 'system_rule_list_page.dart';

class RuleCenterPageLoader extends StatefulWidget {
  const RuleCenterPageLoader({super.key, this.openCustomRules = false});

  final bool openCustomRules;
  @override
  State<RuleCenterPageLoader> createState() => _State();
}

class _State extends State<RuleCenterPageLoader> {
  late CustomRuleService service;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    service = CustomRuleService(CustomRuleStore(), UserGovernanceState());
    _load();
  }

  Future<void> _load() async {
    await service.load();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final systemRules = [...CommonRuleCorpus.v1(), ...ExamRuleCorpus.v1()];
    if (widget.openCustomRules) {
      return RuleCenterPage(service: service, systemRules: systemRules);
    }
    return SystemRuleListPage(service: service, systemRules: systemRules);
  }
}
