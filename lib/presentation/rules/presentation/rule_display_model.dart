import '../../../domain/rules/core/rule_origin.dart';

class RuleDisplayModel {
  const RuleDisplayModel({
    required this.title,
    required this.categoryLabel,
    required this.originLabel,
    required this.ruleId,
    required this.version,
    required this.description,
    required this.dsl,
    required this.origin,
  });

  final String title;
  final String categoryLabel;
  final String originLabel;
  final String ruleId;
  final String version;
  final String description;
  final String dsl;
  final RuleOrigin origin;

  bool get canCopyAsCustom => origin == RuleOrigin.SYSTEM;
}
