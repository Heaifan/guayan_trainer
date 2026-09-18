import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/engine/rule_trace.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_result.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

void main() {
  test('trace preserves status, tree, evidence, and resolved objects', () {
    const trace = RuleTrace(
      kind: RuleTraceKind.any,
      label: 'ANY',
      status: RuleTraceStatus.matched,
      children: [
        RuleTrace(
          kind: RuleTraceKind.predicate,
          label: '五爻 六神=玄武',
          status: RuleTraceStatus.matched,
          expected: '玄武',
          actual: '玄武',
        ),
      ],
      resolvedObjects: [SemanticRef('line', '5')],
    );

    expect(trace.children.single.actual, '玄武');
    expect(trace.resolvedObjects.single, const SemanticRef('line', '5'));
    expect(trace.toJson()['status'], 'MATCHED');
    expect(RuleTrace.fromJson(trace.toJson()), trace);
  });

  test('predicate result can carry trace and matched binding contexts', () {
    const result = PredicateResult(
      matched: true,
      trace: RuleTrace(
        kind: RuleTraceKind.predicate,
        label: '六亲=子孙',
        status: RuleTraceStatus.matched,
      ),
      matchedBindings: [
        {'A': SemanticRef('line', '2')},
      ],
    );

    expect(result.trace!.status, RuleTraceStatus.matched);
    expect(result.matchedBindings.single['A'], const SemanticRef('line', '2'));
  });
}
