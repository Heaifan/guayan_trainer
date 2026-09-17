import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/rules/library/effective_rule_selector.dart';
import 'package:guayan_trainer/domain/rules/library/rule_folder.dart';
import 'package:guayan_trainer/domain/rules/library/rule_library_index.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';

void main() {
  test('folder state filters runtime rules without changing their own enabled state', () {
    final rules = [
      _rule('rule-a', enabled: true),
      _rule('rule-b', enabled: false),
    ];
    final index = RuleLibraryIndex.defaults()
        .assignRule('rule-a')
        .assignRule('rule-b');

    expect(selectEffectiveRules(rules, index).map((rule) => rule.ruleId.id), ['rule-a']);
    expect(rules.last.enabled, isFalse);
    expect(index.setFolderEnabled(RuleFolder.uncategorizedId, false)
        .let((next) => selectEffectiveRules(rules, next)), isEmpty);
  });
}

RuleDefinition _rule(String id, {required bool enabled}) => RuleDefinition(
  ruleId: RuleId(id),
  version: RuleVersion('1.0.0'),
  origin: RuleOrigin.CUSTOM,
  namespace: 'common',
  categoryId: 'custom',
  stage: RuleStage.baseRelation,
  title: id,
  description: '',
  provenance: 'test',
  bindings: const [],
  condition: const AllExpr([]),
  actions: const [],
  enabled: enabled,
);

extension<T> on T {
  R let<R>(R Function(T value) transform) => transform(this);
}
