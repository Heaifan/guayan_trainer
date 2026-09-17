import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/library/rule_folder.dart';
import 'package:guayan_trainer/domain/rules/library/rule_library_index.dart';
import 'package:guayan_trainer/presentation/rules/widgets/rule_folder_tree.dart';

void main() {
  testWidgets('renders nested folders and recursive rule count', (tester) async {
    final index = RuleLibraryIndex.defaults().createFolder(
      '家宅',
      parentFolderId: RuleFolder.uncategorizedId,
    );
    final homeId = index.folders.firstWhere((folder) => folder.name == '家宅').folderId;
    final nested = index.createFolder('宅内取象', parentFolderId: homeId);
    final nestedId = nested.folders.firstWhere((folder) => folder.name == '宅内取象').folderId;
    final assigned = nested.assignRule('rule-a', folderId: nestedId);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RuleFolderTree(
          index: assigned,
          rules: [_rule('rule-a')],
          onFolderToggle: (folderId, enabled) {},
          onRuleToggle: (rule, enabled) {},
        ),
      ),
    ));

    expect(find.text('家宅'), findsOneWidget);
    expect(find.text('宅内取象'), findsOneWidget);
    expect(find.text('1 条规则'), findsNWidgets(3));
  });
}

RuleDefinition _rule(String id) => RuleDefinition(
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
);
