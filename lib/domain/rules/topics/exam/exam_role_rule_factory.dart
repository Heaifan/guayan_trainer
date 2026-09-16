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

class ExamRoleRuleFactory {
  static List<RuleDefinition> buildRoleRules(int i) {
    return [_role(i, 'fuMu', 'fu_mu'), _role(i, 'guanGui', 'guan_gui')];
  }

  static RuleDefinition _role(int i, String rel, String suffix) {
    return _def(
      'role.$suffix',
      PredicateExpr(
        operatorId: 'relative',
        operands: [
          BindingRefOperand('A'),
          LiteralOperand(RuleValue.string(rel)),
        ],
      ),
      TagAction(categoryId: 'exam', tagId: 'role.$suffix', subjectBinding: 'A'),
      i,
    );
  }

  static RuleDefinition _def(
    String idSuffix,
    RuleExpr cond,
    RuleAction action,
    int i,
  ) {
    return RuleDefinition(
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
}
