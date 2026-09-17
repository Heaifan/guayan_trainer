library;

import 'operator_impl.dart';
import 'structural_operators.dart';
import '../../vocabulary/condition_id.dart';
import 'foundational_operators.dart';

/// 注册所有具体的条件运算符实现
class OperatorRegistry {
  OperatorRegistry() {
    register(const GenerateOperator());
    register(const EmptyOperator());
    register(const HasTagOperator());
    register(const RelativeOperator());
    register(const BinaryLiteralOperator(ConditionId.spirit, 'spirit'));
    register(const BinaryLiteralOperator(ConditionId.nayinIs, 'nayin'));
    register(const SimpleStateOperator(ConditionId.xunKong, 'xun_kong'));
    register(const SimpleStateOperator(ConditionId.yuePo, 'yue_po'));
    register(const SimpleStateOperator(ConditionId.riPo, 'ri_po'));
    register(const SimpleStateOperator(ConditionId.inTomb, 'in_tomb'));
    register(const SimpleRelationOperator(ConditionId.ruMu, 'ru_mu'));
    register(const SimpleRelationOperator(ConditionId.chongMu, 'chong_mu'));
    register(const ChuMuOperator());
    register(const FactValueOperator(ConditionId.stemIs, 'stem'));
    register(const FactValueOperator(ConditionId.branchIs, 'branch'));
    register(const FactValueOperator(ConditionId.elementIs, 'element'));
    register(const ElementControlsOperator(ConditionId.controls));
    register(
      const BranchRelationOperator(ConditionId.branchClashes, branchClashes),
    );
    register(
      const BranchRelationOperator(ConditionId.branchCombines, branchCombines),
    );
    register(
      const BranchRelationOperator(ConditionId.branchPunishes, branchPunishes),
    );
    register(
      const BranchRelationOperator(ConditionId.branchHarms, branchHarms),
    );
    register(
      const BranchRelationOperator(ConditionId.branchBreaks, branchBreaks),
    );
    register(const StructureFormedOperator());
  }

  final Map<String, OperatorImpl> _operators = {};

  void register(OperatorImpl op) {
    _operators[op.operatorId] = op;
  }

  OperatorImpl? getOperator(String operatorId) => _operators[operatorId];
}
