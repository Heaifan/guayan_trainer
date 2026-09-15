import 'package:guayan_trainer/domain/rules/engine/operators/operator_registry.dart';
import 'package:guayan_trainer/domain/rules/engine/operators/operator_impl.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/engine/binding_resolver.dart';
import 'package:guayan_trainer/domain/rules/engine/predicate_result.dart';
import 'package:guayan_trainer/domain/rules/engine/engine_types.dart';

const refA = SemanticRef('line', 'A');
const refM = SemanticRef('month', 'M');
const refD = SemanticRef('day', 'D');
const refT = SemanticRef('tomb', 'T');

FactSnapshot createOperatorTestSnapshot() {
  return FactSnapshot.build([
    FactRecord(factId: 'f1', subject: refA, predicateId: 'relative', value: RuleValue.string('parent'), origin: FactOrigin.baseRelation),
    FactRecord(factId: 'f2', subject: refA, predicateId: 'spirit', value: RuleValue.string('azureDragon'), origin: FactOrigin.baseRelation),
    FactRecord(factId: 'f3', subject: refA, predicateId: 'nayin', value: RuleValue.string('nayin.tian_he_shui'), origin: FactOrigin.baseRelation),
    FactRecord(factId: 'f4', subject: refA, predicateId: 'state', value: RuleValue.string('xun_kong'), origin: FactOrigin.baseRelation),
    FactRecord(factId: 'f5', subject: refA, predicateId: 'state', value: RuleValue.string('yue_po'), origin: FactOrigin.baseRelation),
    FactRecord(factId: 'f6', subject: refA, predicateId: 'state', value: RuleValue.string('ri_po'), origin: FactOrigin.baseRelation),
    FactRecord(factId: 'f7', subject: refA, predicateId: 'state', value: RuleValue.string('in_tomb'), origin: FactOrigin.baseRelation),
    FactRecord(factId: 'f12', subject: refA, predicateId: 'has_tag_shensha', value: RuleValue.string('shensha.custom.foo'), origin: FactOrigin.derived),
    FactRecord(factId: 'f13', subject: refA, predicateId: 'state', value: RuleValue.string('kong_wang'), origin: FactOrigin.baseRelation),
  ], [
    RuntimeRelation(relationId: 'generate', subjects: const ['month/M', 'line/A'], evidenceId: 'f8'),
    RuntimeRelation(relationId: 'ru_mu', subjects: const ['line/A', 'tomb/T'], evidenceId: 'f9'),
    RuntimeRelation(relationId: 'chong_mu', subjects: const ['day/D', 'tomb/T'], evidenceId: 'f10'),
    RuntimeRelation(relationId: 'chu_mu', subjects: const ['line/A', 'tomb/T', 'day/D'], evidenceId: 'f11'),
  ]);
}

PredicateResult evalOp(OperatorRegistry registry, FactSnapshot snapshot, String opId, List<ResolvedOperand> operands) {
  final op = registry.getOperator(opId);
  return op!.evaluate(operands, OperatorContext(snapshot: snapshot, bindingContext: BindingContext()));
}
