library;

import '../ast/rule_expr.dart';
import 'template_invocation.dart';

abstract class TemplateCompiler {
  const TemplateCompiler();

  RuleExpr compile(TemplateInvocation invocation);
}
