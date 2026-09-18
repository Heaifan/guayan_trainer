import 'package:flutter_test/flutter_test.dart';
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
import 'package:guayan_trainer/domain/rules/engine/rule_engine.dart';
import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_trace.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

FactSnapshot _snapshot({
  required String line2,
  required String line3,
  required String line5,
  String? whiteTigerBranch,
}) {
  final facts = <FactRecord>[
    for (final entry in {
      '1': '寅',
      '2': line2,
      '3': line3,
      '4': whiteTigerBranch ?? '卯',
      '5': line5,
      '6': '巳',
    }.entries)
      FactRecord(
        factId: 'branch-${entry.key}',
        subject: SemanticRef('line', entry.key),
        predicateId: 'branch',
        value: RuleValue.string(entry.value),
        origin: FactOrigin.baseRelation,
      ),
  ];
  if (whiteTigerBranch != null) {
    facts.add(FactRecord(
      factId: 'spirit-4',
      subject: const SemanticRef('line', '4'),
      predicateId: 'spirit',
      value: RuleValue.string('spirit.bai_hu'),
      origin: FactOrigin.baseRelation,
    ));
  }
  facts.add(FactRecord(
    factId: 'relative-2',
    subject: const SemanticRef('line', '2'),
    predicateId: 'relative',
    value: RuleValue.string('relative.child'),
    origin: FactOrigin.baseRelation,
  ));
  return FactSnapshot.build(facts);
}

RuleDefinition _roadRule() => RuleDefinition(
      ruleId: const RuleId('r5-road-clashes-home'),
      version: RuleVersion('1.0.0'),
      origin: RuleOrigin.CUSTOM,
      namespace: 'r5',
      categoryId: 'image',
      stage: RuleStage.tag,
      title: '有路冲家',
      description: '',
      provenance: 'R5 real rule corpus',
      bindings: const [
        RuleBinding(name: 'B', selector: DirectSelector('line/3')),
        RuleBinding(name: 'F', selector: DirectSelector('line/5')),
        RuleBinding(
          name: 'C',
          selector: DynamicBindingSelector(
            selectorId: 'dynamic.line.by_spirit',
            parameters: {'spirit': 'spirit.bai_hu'},
          ),
        ),
      ],
      condition: AnyExpr([
        QuantifiedExpr(
          bindingName: 'X',
          selector: DynamicBindingSelector(selectorId: 'dynamic.line.all'),
          kind: QuantifierKind.any,
          node: AllExpr([
            PredicateExpr(
              operatorId: 'relative',
              operands: [
                BindingRefOperand('X'),
                LiteralOperand(RuleValue.string('relative.child')),
              ],
            ),
            PredicateExpr(
              operatorId: 'branch_clashes',
              operands: [
                BindingRefOperand('X'),
                BindingRefOperand('B'),
              ],
            ),
          ]),
        ),
        PredicateExpr(
          operatorId: 'branch_clashes',
            operands: [
            BindingRefOperand('F'),
            BindingRefOperand('B'),
          ],
        ),
        PredicateExpr(
          operatorId: 'branch_clashes',
          operands: [
            BindingRefOperand('C'),
            BindingRefOperand('B'),
          ],
        ),
      ]),
      actions: const [
        TagAction(
          categoryId: 'image',
          tagId: '有路冲家',
          target: ActionTarget.conditionRelation(relationId: 'branch_clashes'),
        ),
      ],
    );

RuleTrace _runTrace(AnalysisRun run) =>
    run.traces.firstWhere((trace) => trace.label == '有路冲家');

Iterable<RuleTrace> _flatten(RuleTrace trace) sync* {
  yield trace;
  for (final child in trace.children) {
    yield* _flatten(child);
  }
}

void main() {
  test('CASE A: quantified child clash matches and produces 有路冲家', () {
    final run = RuleEngine().execute([
      _roadRule(),
    ], _snapshot(line2: '子', line3: '午', line5: '丑'));
    final trace = _runTrace(run);
    final all = _flatten(trace).toList();

    expect(run.tags, hasLength(1));
    expect(run.derivedEvidence, hasLength(1));
    expect(run.derivedEvidence.single.targetRefs, const [
      SemanticRef('line', '2'),
      SemanticRef('line', '3'),
    ]);
    expect(trace.status, RuleTraceStatus.matched);
    expect(all.where((item) => item.kind == RuleTraceKind.action).single.status,
        RuleTraceStatus.success);
    expect(all.any((item) => item.label.contains('二爻')), isTrue);
    expect(all.any((item) => item.label.contains('子') && item.label.contains('午')),
        isTrue);
    expect(all.any((item) => item.label == '任一爻 X · 6 个候选 · 1 个命中'), isTrue);
  });

  test('CASE B: five-clash branch matches', () {
    final run = RuleEngine().execute([
      _roadRule(),
    ], _snapshot(line2: '丑', line3: '午', line5: '子'));
    expect(_runTrace(run).status, RuleTraceStatus.matched);
    expect(run.tags, hasLength(1));
    expect(run.derivedEvidence.single.targetRefs, const [
      SemanticRef('line', '5'),
      SemanticRef('line', '3'),
    ]);
  });

  test('CASE C: white-tiger branch matches', () {
    final run = RuleEngine().execute([
      _roadRule(),
    ], _snapshot(line2: '丑', line3: '午', line5: '丑', whiteTigerBranch: '子'));
    expect(_runTrace(run).status, RuleTraceStatus.matched);
    expect(run.tags, hasLength(1));
    expect(run.derivedEvidence.single.targetRefs, const [
      SemanticRef('line', '4'),
      SemanticRef('line', '3'),
    ]);
  });

  test('CASE D: all branches are false', () {
    final run = RuleEngine().execute([
      _roadRule(),
    ], _snapshot(line2: '子', line3: '丑', line5: '子'));
    expect(_runTrace(run).status, RuleTraceStatus.notMatched);
    expect(run.tags, isEmpty);
    expect(run.derivedEvidence, isEmpty);
  });

  test('CASE E: missing white tiger remains NO_MATCH while five-clash matches', () {
    final run = RuleEngine().execute([
      _roadRule(),
    ], _snapshot(line2: '丑', line3: '午', line5: '子'));
    final all = _flatten(_runTrace(run)).toList();
    expect(_runTrace(run).status, RuleTraceStatus.matched);
    expect(all.any((item) => item.reason == 'NO_MATCH'), isTrue);
    expect(all.any((item) => item.label.contains('白虎所临之爻')), isTrue);
    expect(run.derivedEvidence.single.targetRefs, const [
      SemanticRef('line', '5'),
      SemanticRef('line', '3'),
    ]);
  });

  test('multiple ANY paths preserve two relation evidence records', () {
    final run = RuleEngine().execute([
      _roadRule(),
    ], _snapshot(line2: '子', line3: '午', line5: '子'));
    expect(run.derivedEvidence, hasLength(2));
    expect(
      run.derivedEvidence.map((item) => item.targetRefs),
      containsAll(<List<SemanticRef>>[
        const [SemanticRef('line', '2'), SemanticRef('line', '3')],
        const [SemanticRef('line', '5'), SemanticRef('line', '3')],
      ]),
    );
    expect(run.derivedEvidence.every((item) => item.supports.isNotEmpty), isTrue);
  });
}
