import 'execution_rule_ref.dart';

class RuleVariant {
  const RuleVariant({
    required this.id,
    required this.knowledgeRuleId,
    required this.name,
    required this.origin,
    required this.version,
    required this.executionRules,
  });

  final String id;
  final String knowledgeRuleId;
  final String name;
  final String origin;
  final String version;
  final List<ExecutionRuleRef> executionRules;
}
