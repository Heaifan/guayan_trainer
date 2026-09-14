library;

import 'operator_impl.dart';
import 'structural_operators.dart';
import '../../vocabulary/condition_id.dart';

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
  }

  final Map<String, OperatorImpl> _operators = {};

  void register(OperatorImpl op) {
    _operators[op.operatorId] = op;
  }

  OperatorImpl? getOperator(String operatorId) => _operators[operatorId];
}
