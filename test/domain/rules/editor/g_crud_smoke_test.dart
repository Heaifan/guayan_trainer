import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/editor/custom_rule_store.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_editor_draft.dart';
import 'package:guayan_trainer/domain/rules/editor/rule_version_bumper.dart';

RuleDefinition _makeDef(String id) => RuleDefinition(
  ruleId: RuleId(id),
  version: RuleVersion('1.0.0'),
  origin: RuleOrigin.CUSTOM,
  namespace: 'common',
  categoryId: 'common',
  stage: RuleStage.tag,
  title: 'Title',
  description: '',
  provenance: '',
  bindings: [],
  condition: const AllExpr([]),
  actions: [],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('R5-G Round 1: CRUD Smokes', () {
    test('Smoke A: Create CUSTOM -> Save -> Reload', () async {
      final store = CustomRuleStore();
      await store.load();
      await store.addOrUpdate(
        RuleEditorDraft.fromDefinition(_makeDef('test_1')).toDefinition(),
      );
      final store2 = CustomRuleStore();
      await store2.load();
      expect(store2.getAll().length, 1);
      expect(store2.getAll().first.ruleId.id, 'test_1');
    });

    test('Smoke B: Edit CUSTOM 1.0.0 -> Save -> 1.0.1', () async {
      final store = CustomRuleStore();
      await store.load();
      final draft = RuleEditorDraft.fromDefinition(_makeDef('test_2'));
      await store.addOrUpdate(draft.toDefinition());
      draft.version = RuleVersionBumper.bumpPatch(draft.version);
      await store.addOrUpdate(draft.toDefinition());
      final store2 = CustomRuleStore();
      await store2.load();
      expect(store2.getAll().first.version.toString(), '1.0.1');
    });

    test('Smoke C: Delete CUSTOM -> reload absent', () async {
      final store = CustomRuleStore();
      await store.load();
      await store.addOrUpdate(
        RuleEditorDraft.fromDefinition(_makeDef('test_3')).toDefinition(),
      );
      await store.delete(RuleId('test_3'));
      final store2 = CustomRuleStore();
      await store2.load();
      expect(store2.getAll().isEmpty, isTrue);
    });
  });
}
