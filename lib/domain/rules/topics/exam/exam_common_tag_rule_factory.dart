library;

import '../../ast/binding_selector.dart';
import '../../ast/rule_action.dart';
import '../../ast/rule_binding.dart';
import '../../ast/rule_expr.dart';
import '../../ast/rule_operand.dart';
import '../../core/rule_definition.dart';
import '../../core/rule_id.dart';
import '../../core/rule_origin.dart';
import '../../core/rule_stage.dart';
import '../../core/rule_version.dart';
import '../../facts/rule_value.dart';

class ExamCommonTagRuleFactory {
  static List<RuleDefinition> buildCommonTagRules(int i) => [
    _state(i, 'fu_mu', 'xun_kong'),
    _relation(i, 'fu_mu', 'month_generate'),
  ];

  static RuleDefinition _state(int i, String role, String state) => _def(
    'state.${role}_$state',
    AllExpr([
      PredicateExpr(
        operatorId: 'relative',
        operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('fuMu')),
        ],
      ),
      PredicateExpr(
        operatorId: 'has_tag',
        operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('common')),
          LiteralOperand(RuleValue.string('state.$state')),
        ],
      ),
    ]),
    TagAction(
      categoryId: 'exam',
      tagId: 'state.${role}_$state',
      subjectBinding: 'A',
    ),
    i,
  );

  static RuleDefinition _relation(int i, String role, String rel) => _def(
    'relation.${role}_$rel',
    AllExpr([
      PredicateExpr(
        operatorId: 'relative',
        operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('fuMu')),
        ],
      ),
      PredicateExpr(
        operatorId: 'has_tag',
        operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string('common')),
          LiteralOperand(RuleValue.string('relation.$rel')),
        ],
      ),
    ]),
    TagAction(
      categoryId: 'exam',
      tagId: 'relation.${role}_$rel',
      subjectBinding: 'A',
    ),
    i,
  );

  static RuleDefinition _def(
    String idSuffix,
    RuleExpr cond,
    RuleAction action,
    int i,
  ) => RuleDefinition(
    ruleId: RuleId('exam.line.$i.$idSuffix'),
    version: RuleVersion('1.0.0'),
    origin: RuleOrigin.SYSTEM,
    namespace: 'topic.exam',
    categoryId: 'exam',
    stage: RuleStage.tag,
    title: 'Exam $idSuffix',
    description: 'Exam demo rule',
    provenance: 'builtin.topic.exam.v1',
    bindings: [RuleBinding(name: 'A', selector: DirectSelector('line/$i'))],
    condition: cond,
    actions: [action],
    enabled: true,
  );
}
