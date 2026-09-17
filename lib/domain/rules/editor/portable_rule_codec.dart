import 'dart:convert';

import '../core/rule_definition.dart';
import 'rule_definition_codec.dart';

class PortableRuleCodec {
  static Map<String, dynamic> encode(RuleDefinition rule) => {
    'schemaVersion': '1.0.0',
    'rule': RuleDefinitionCodec.toJson(rule),
  };

  static String encodeText(RuleDefinition rule) =>
      const JsonEncoder.withIndent('  ').convert(encode(rule));

  static RuleDefinition decode(Map<String, dynamic> json) {
    final schema = json['schemaVersion'];
    if (schema != '1.0.0') {
      throw FormatException('Unsupported portable rule schema: $schema');
    }
    final raw = json['rule'];
    if (raw is! Map) {
      throw const FormatException('Missing rule object');
    }
    return RuleDefinitionCodec.fromJson(Map<String, dynamic>.from(raw));
  }

  static RuleDefinition fromJson(Map<String, dynamic> json) => decode(json);

  static RuleDefinition decodeText(String source) {
    final value = jsonDecode(source);
    if (value is! Map) {
      throw const FormatException('JSON root must be an object');
    }
    return decode(Map<String, dynamic>.from(value));
  }
}
