import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';

RuleDefinition buildRule(String id, RuleStage stage, List<RuleBinding> bindings, RuleExpr condition, List<RuleAction> actions) {
  return RuleDefinition(
    ruleId: RuleId(id), version: RuleVersion('1.0.0'), origin: RuleOrigin.SYSTEM,
    namespace: 'test', categoryId: 'test', title: 'test', description: 'test',
    provenance: 'test', stage: stage, bindings: bindings, condition: condition, actions: actions,
  );
}

FactSnapshot createInitialSnapshot() {
  return FactSnapshot.build([
    FactRecord(factId: 'f1', subject: const SemanticRef('line', '2'), predicateId: 'relative', value: RuleValue.string('parent'), origin: FactOrigin.baseRelation),
    FactRecord(factId: 'f3', subject: const SemanticRef('line', '2'), predicateId: 'nayin', value: RuleValue.string('nayin.tian_he_shui'), origin: FactOrigin.baseRelation),
  ], [RuntimeRelation(relationId: 'generate', subjects: const ['month/M', 'line/2'], evidenceId: 'e2')]);
}
