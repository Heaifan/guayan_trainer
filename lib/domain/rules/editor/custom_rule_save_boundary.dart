library;

import '../core/rule_definition.dart';
import '../topics/topic_rule_boundary_validator.dart';

/// `CustomRuleService.save` 的 namespace 边界分发。
///
/// COMMON 与 TOPIC 走不同校验器；未知 namespace 一律拒绝。
class CustomRuleSaveBoundary {
  static const commonNamespace = 'common';
  static const topicPrefix = 'topic.';

  static void validate(RuleDefinition rule) {
    if (rule.namespace == commonNamespace) {
      CommonRuleBoundaryValidator.validate(rule);
      return;
    }
    if (rule.namespace.startsWith(topicPrefix)) {
      final expectedId = rule.namespace.substring(topicPrefix.length);
      TopicRuleBoundaryValidator.validate(rule, expectedId);
      return;
    }
    throw StateError('Unknown namespace: ${rule.namespace}');
  }
}

class CommonRuleBoundaryValidator {
  static void validate(RuleDefinition rule) {
    if (rule.namespace != CustomRuleSaveBoundary.commonNamespace) {
      throw StateError(
        'Boundary violation: Rule namespace must be "common"',
      );
    }
    if (rule.categoryId != CustomRuleSaveBoundary.commonNamespace) {
      throw StateError(
        'Boundary violation: Rule categoryId must be "common"',
      );
    }
  }
}
