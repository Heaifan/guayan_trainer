library;

import '../core/rule_definition.dart';
import '../core/rule_id.dart';
import '../core/rule_version.dart';
import '../core/rule_origin.dart';
import '../core/rule_stage.dart';
import '../ast/rule_binding.dart';
import '../ast/binding_selector.dart';
import 'rule_expr_codec.dart';
import 'rule_action_codec.dart';

class RuleDefinitionCodec {
  static Map<String, dynamic> toJson(RuleDefinition r) {
    return {
      'ruleId': r.ruleId.id,
      'version': r.version.toString(),
      'origin': r.origin.name,
      'namespace': r.namespace,
      'categoryId': r.categoryId,
      'stage': r.stage.name,
      'title': r.title,
      'description': r.description,
      'provenance': r.provenance,
      'bindings': r.bindings.map((b) {
        final sel = b.selector;
        if (sel is DirectSelector) {
          return {'name': b.name, 'type': 'dir', 'target': sel.target};
        }
        if (sel is RelativeSelector) {
          return {
            'name': b.name,
            'type': 'rel',
            'base': sel.baseBinding,
            'path': sel.path,
          };
        }
        if (sel is DynamicBindingSelector) {
          return {
            'name': b.name,
            'type': 'dyn',
            'selectorId': sel.selectorId,
            'parameters': sel.parameters,
          };
        }
        throw ArgumentError('Unknown selector');
      }).toList(),
      'condition': RuleExprCodec.toJson(r.condition),
      'actions': r.actions.map(RuleActionCodec.toJson).toList(),
      'overrideTarget': r.overrideTarget?.id,
      'enabled': r.enabled,
      'reviewState': r.reviewState.name,
      'schemaVersion': r.schemaVersion,
    };
  }

  static RuleDefinition fromJson(Map<String, dynamic> json) {
    return RuleDefinition(
      ruleId: RuleId(json['ruleId']),
      version: RuleVersion(json['version']),
      origin: RuleOrigin.values.firstWhere((e) => e.name == json['origin']),
      namespace: json['namespace'],
      categoryId: json['categoryId'],
      stage: RuleStage.values.firstWhere((e) => e.name == json['stage']),
      title: json['title'],
      description: json['description'],
      provenance: json['provenance'],
      bindings: (json['bindings'] as List).map<RuleBinding>((b) {
        BindingSelector sel;
        if (b['type'] == 'dir') {
          sel = DirectSelector(b['target']);
        } else if (b['type'] == 'rel') {
          sel = RelativeSelector(baseBinding: b['base'], path: b['path']);
        } else if (b['type'] == 'dyn') {
          sel = DynamicBindingSelector(
            selectorId: b['selectorId'],
            parameters: Map<String, String>.from(b['parameters'] ?? const {}),
          );
        } else {
          throw ArgumentError('Unknown binding selector type: ${b['type']}');
        }
        return RuleBinding(name: b['name'], selector: sel);
      }).toList(),
      condition: RuleExprCodec.fromJson(json['condition']),
      actions: (json['actions'] as List)
          .map((a) => RuleActionCodec.fromJson(a))
          .toList(),
      overrideTarget: json['overrideTarget'] != null
          ? RuleId(json['overrideTarget'])
          : null,
      enabled: json['enabled'] ?? true,
      reviewState: ReviewState.values.firstWhere(
        (e) => e.name == (json['reviewState'] ?? 'APPROVED'),
        orElse: () => ReviewState.APPROVED,
      ),
      schemaVersion: json['schemaVersion'] ?? 1,
    );
  }
}
