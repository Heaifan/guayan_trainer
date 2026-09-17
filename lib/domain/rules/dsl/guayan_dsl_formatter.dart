library;

import '../ast/binding_selector.dart';
import 'guayan_rule_body.dart';
import 'condition_formatter.dart';
import 'action_formatter.dart';

class GuayanDslFormatter {
  const GuayanDslFormatter();

  String format(GuayanRuleBody body) {
    final buffer = StringBuffer();

    // Bindings
    for (final binding in body.bindings) {
      buffer.writeln(
        '取 ${binding.name} = ${_formatSelector(binding.selector)}',
      );
    }

    // Condition
    buffer.writeln('若');
    const ConditionFormatter().format(body.condition, 1, buffer);

    // Actions
    buffer.writeln('则');
    for (final action in body.actions) {
      const ActionFormatter().format(action, 1, buffer);
    }

    return buffer.toString().trim();
  }

  String _formatSelector(BindingSelector selector) {
    if (selector is RelativeSelector) {
      return '${selector.baseBinding}.${selector.path}';
    } else if (selector is DirectSelector) {
      final t = selector.target;
      if (t.contains('/') || RegExp(r'^[a-z]').hasMatch(t)) {
        return '@$t';
      }
      return t;
    }
    return '';
  }
}
