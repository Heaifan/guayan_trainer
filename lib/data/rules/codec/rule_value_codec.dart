library;

/// RuleValue 编解码器，用于处理基础值类型和特殊稳定 token 的 JSON 互转。
import '../../../domain/rules/facts/rule_value.dart';

class RuleValueCodec {
  static Object? encode(Object? value) {
    if (value is RuleValue) return value.toJson();
    return value;
  }

  static RuleValue decode(dynamic json) {
    if (json == null) return RuleValue.nullValue();
    if (json is String) return RuleValue.string(json);
    if (json is int) return RuleValue.integer(json);
    if (json is double) return RuleValue.number(json);
    if (json is bool) return RuleValue.boolean(json);
    throw ArgumentError('不支持的 RuleValue JSON');
  }
}
