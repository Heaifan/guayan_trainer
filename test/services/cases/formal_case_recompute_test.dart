import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/domain/cases/rule_run.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_trace.dart';
import 'package:guayan_trainer/domain/rules/engine/runtime_rule_set_assembler.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_service.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/user_governance_state.dart';
import 'package:guayan_trainer/domain/rules/packs/rule_pack.dart';
import 'package:guayan_trainer/domain/rules/packs/rule_pack_id.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';
import 'package:guayan_trainer/domain/calendar/day/ganzhi_day.dart';
import 'package:guayan_trainer/domain/rule_execution_context.dart';
import 'package:guayan_trainer/domain/cases/case_record.dart';
import 'package:guayan_trainer/domain/cases/casting_snapshot.dart';
import 'package:guayan_trainer/services/cases/formal_case_recompute_service.dart';
import 'package:guayan_trainer/services/cases/json_case_repository.dart';

Iterable<RuleTrace> _flatten(RuleTrace trace) sync* {
  yield trace;
  for (final child in trace.children) {
    yield* _flatten(child);
  }
}

RuleDefinition _roadRule() => RuleDefinition(
      ruleId: RuleId('custom.first-line-road'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM,
      namespace: 'common',
      categoryId: 'common',
      stage: RuleStage.tag,
      title: '初爻子孙临青龙测试',
      description: '',
      provenance: 'custom',
      bindings: const [
        RuleBinding(name: 'A', selector: DirectSelector('line/1')),
      ],
      condition: AllExpr([
        PredicateExpr(operatorId: ConditionId.relative, operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('relative.child')),
        ]),
        PredicateExpr(operatorId: ConditionId.spirit, operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('spirit.qing_long')),
        ]),
      ]),
      actions: const [
        TagAction(categoryId: 'image', tagId: 'road', subjectBinding: 'A'),
      ],
    );

List<MovementType> _roadMovements() {
  for (var mask = 0; mask < 64; mask++) {
    final movements = [
      for (var bit = 0; bit < 6; bit++)
        (mask & (1 << bit)) == 0
            ? MovementType.shaoYin
            : MovementType.shaoYang,
    ];
    if (CastingEngine.cast(movements).lineAt(1).relative.label == '子孙') {
      return movements;
    }
  }
  throw StateError('missing child-relative first line fixture');
}

DateTime _qingLongDate() {
  for (var day = 1; day <= 31; day++) {
    final date = DateTime(2026, 9, day);
    if (ganzhiDayOfDate(date.year, date.month, date.day).gan.index <= 1) {
      return date;
    }
  }
  throw StateError('missing qinglong date fixture');
}

CaseRecord _record(DateTime time) {
  final movements = _roadMovements();
  final chart = CastingEngine.cast(movements);
  return CaseRecord.create(
    id: 'formal-road',
    snapshot: CastingSnapshot(
      castingTime: time,
      subject: '正式规则冒烟',
      lines: [
        for (final line in chart.lines)
          LineState(
            position: line.position,
            movementType: movements[line.position - 1],
            branch: line.branch.label,
            changedBranch: line.changedBranch?.label,
          ),
      ],
      originalHexagramName: chart.original.name,
      movingPositions: chart.movingPositions,
    ),
    createdAt: time,
    originalRuleRun: RuleRun.original(
      executedAt: time,
      ruleContext: const RuleExecutionContext.empty(),
      result: const {},
      evidence: const [],
    ),
  );
}

void main() {
  test('formal recompute executes enabled custom road rule for the Case', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = await JsonCaseRepository.open();
    final date = _qingLongDate();
    final record = _record(date);
    await repository.create(record);

    final customStore = CustomRuleStore()..seedForTest([_roadRule()]);
    final customService = CustomRuleService(customStore, UserGovernanceState());
    final assembler = RuntimeRuleSetAssembler(
      customRuleService: customService,
      availableTopics: const <RulePack>[],
      topicRulesMap: const <RulePackId, List<RuleDefinition>>{},
    );

    final resolved = assembler.assemble(const []).activeRules;
    expect(resolved.map((rule) => rule.ruleId.id), contains('custom.first-line-road'));

    final updated = await FormalCaseRecomputeService(
      repository,
      clock: () => DateTime(2026, 9, 19),
    ).recompute(
      record: record,
      rules: resolved,
    );

    final run = updated.ruleRuns.last;
    expect(run.result['matched'], 1);
    expect(run.derivedEvidence, hasLength(1));
    expect(run.derivedEvidence.single.value, 'road');
    expect(run.derivedEvidence.single.targetKind, ActionTargetKind.object);
    expect(run.derivedEvidence.single.ruleOrigin, RuleOrigin.CUSTOM);
    expect(
      run.traces.where((trace) => trace.label == '初爻子孙临青龙测试'),
      hasLength(1),
    );
    final smokeTrace = run.traces.singleWhere(
      (trace) => trace.label == '初爻子孙临青龙测试',
    );
    final relativeTrace = _flatten(smokeTrace).singleWhere(
      (trace) => trace.operatorId == ConditionId.relative,
    );
    expect(relativeTrace.actual, '子孙');
    expect(
      _flatten(smokeTrace).any((trace) => trace.label == '取象「道路」'),
      isTrue,
    );
  });
}
