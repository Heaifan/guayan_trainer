class ExecutionRuleRef {
  const ExecutionRuleRef({
    required this.ruleId,
    required this.displayName,
    required this.order,
  });

  final String ruleId;
  final String displayName;
  final int order;
}
