library;

/// Rule Codec 入口，占位用于后续完整编解码。
import '../../../domain/rules/core/rule_definition.dart';
import '../../../domain/rules/core/rule_id.dart';
import '../../../domain/rules/core/rule_origin.dart';
import '../../../domain/rules/core/rule_stage.dart';
import '../../../domain/rules/core/rule_version.dart';
import 'rule_ast_codec.dart';

class RuleCodec {
  const RuleCodec();
  
  Map<String, dynamic> encode(RuleDefinition rule) {
    return {
      'ruleId': rule.ruleId.toJson(),
      'version': rule.version.toJson(),
      'origin': rule.origin.name,
      'namespace': rule.namespace,
      'categoryId': rule.categoryId,
      'stage': rule.stage.name,
      'title': rule.title,
      'description': rule.description,
      'provenance': rule.provenance,
      'bindings': rule.bindings.map(RuleAstCodec.encodeBinding).toList(),
      'condition': RuleAstCodec.encodeExpr(rule.condition),
      'actions': rule.actions.map(RuleAstCodec.encodeAction).toList(),
      if (rule.overrideTarget != null) 'overrideTarget': rule.overrideTarget!.toJson(),
      'enabled': rule.enabled,
      'reviewState': rule.reviewState.name,
      'schemaVersion': rule.schemaVersion,
    };
  }

  RuleDefinition decode(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion == 'guayan-rule@0.1' || schemaVersion != 1) {
      throw FormatException('不支持的 schemaVersion: $schemaVersion');
    }
    
    return RuleDefinition(
      ruleId: RuleId.fromJson(json['ruleId'] as String),
      version: RuleVersion.fromJson(json['version'] as String),
      origin: RuleOrigin.values.byName(json['origin'] as String),
      namespace: json['namespace'] as String,
      categoryId: json['categoryId'] as String,
      stage: RuleStage.values.byName(json['stage'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      provenance: json['provenance'] as String,
      bindings: (json['bindings'] as List).map((e) => RuleAstCodec.decodeBinding(e)).toList(),
      condition: RuleAstCodec.decodeExpr(json['condition'] as Map<String, dynamic>),
      actions: (json['actions'] as List).map((e) => RuleAstCodec.decodeAction(e)).toList(),
      overrideTarget: json['overrideTarget'] != null ? RuleId.fromJson(json['overrideTarget'] as String) : null,
      enabled: json['enabled'] as bool? ?? true,
      reviewState: ReviewState.values.byName(json['reviewState'] as String),
      schemaVersion: 1,
    );
  }
}
