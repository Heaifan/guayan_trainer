import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/ast/binding_selector.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_binding.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_expr.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_operand.dart';
import 'package:guayan_trainer/domain/rules/core/rule_definition.dart';
import 'package:guayan_trainer/domain/rules/core/rule_id.dart';
import 'package:guayan_trainer/domain/rules/core/rule_origin.dart';
import 'package:guayan_trainer/domain/rules/core/rule_stage.dart';
import 'package:guayan_trainer/domain/rules/core/rule_version.dart';
import 'package:guayan_trainer/domain/rules/packs/rule_pack_id.dart';
import 'package:guayan_trainer/domain/rules/packs/rule_pack.dart';
import 'package:guayan_trainer/domain/rules/packs/rule_pack_scope.dart';
import 'package:guayan_trainer/domain/rules/evidence/evidence_id.dart';
import 'package:guayan_trainer/domain/rules/evidence/evidence_node.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/data/rules/codec/rule_codec.dart';

void main() {
  group('F1.6 RulePack', () {
    test('Scope vs TopicId validation', () {
      expect(() => RulePack(packId: RulePackId('p1'), version: RuleVersion('1.0.0'), origin: RuleOrigin.SYSTEM, scope: RulePackScope.COMMON, topicId: null, title: '', ruleIds: []), returnsNormally);
      expect(() => RulePack(packId: RulePackId('p1'), version: RuleVersion('1.0.0'), origin: RuleOrigin.SYSTEM, scope: RulePackScope.TOPIC, topicId: 'exam', title: '', ruleIds: []), returnsNormally);
      expect(() => RulePack(packId: RulePackId('p1'), version: RuleVersion('1.0.0'), origin: RuleOrigin.SYSTEM, scope: RulePackScope.TOPIC, topicId: null, title: '', ruleIds: []), throwsArgumentError);
      expect(() => RulePack(packId: RulePackId('p1'), version: RuleVersion('1.0.0'), origin: RuleOrigin.SYSTEM, scope: RulePackScope.COMMON, topicId: 'exam', title: '', ruleIds: []), throwsArgumentError);
    });
  });

  group('F1.7 TagIdentity (Q19)', () {
    test('TagIdentity deduplicates correctly without scores', () {
      final t1 = TagIdentity('exam', 'document');
      final t2 = TagIdentity('exam', 'document');
      expect(t1, equals(t2));
    });
  });

  group('F1.8 EvidenceIdentity', () {
    test('Canonicalization ignores order of bindings and supports', () {
      final id1 = EvidenceId.canonical(
        ruleId: 'r1', version: '1.0.0', conclusion: 'con',
        bindings: {'A': SemanticRef('line', '2'), 'M': SemanticRef('calendar', 'month')},
        supports: [EvidenceId('E1'), EvidenceId('E2')],
      );
      final id2 = EvidenceId.canonical(
        ruleId: 'r1', version: '1.0.0', conclusion: 'con',
        bindings: {'M': SemanticRef('calendar', 'month'), 'A': SemanticRef('line', '2')},
        supports: [EvidenceId('E2'), EvidenceId('E1')],
      );
      expect(id1, equals(id2));
    });

    test('Different semantic content produces different identities', () {
      final base = EvidenceId.canonical(
        ruleId: 'r1', version: '1.0.0', conclusion: 'con',
        bindings: {'A': SemanticRef('line', '2')},
        supports: [EvidenceId('E1')],
      );

      expect(EvidenceId.canonical(
        ruleId: 'r2', version: '1.0.0', conclusion: 'con',
        bindings: {'A': SemanticRef('line', '2')},
        supports: [EvidenceId('E1')],
      ), isNot(equals(base)));

      expect(EvidenceId.canonical(
        ruleId: 'r1', version: '2.0.0', conclusion: 'con',
        bindings: {'A': SemanticRef('line', '2')},
        supports: [EvidenceId('E1')],
      ), isNot(equals(base)));

      expect(EvidenceId.canonical(
        ruleId: 'r1', version: '1.0.0', conclusion: 'con2',
        bindings: {'A': SemanticRef('line', '2')},
        supports: [EvidenceId('E1')],
      ), isNot(equals(base)));

      expect(EvidenceId.canonical(
        ruleId: 'r1', version: '1.0.0', conclusion: 'con',
        bindings: {'A': SemanticRef('line', '3')},
        supports: [EvidenceId('E1')],
      ), isNot(equals(base)));

      expect(EvidenceId.canonical(
        ruleId: 'r1', version: '1.0.0', conclusion: 'con',
        bindings: {'A': SemanticRef('line', '2')},
        supports: [EvidenceId('E2')],
      ), isNot(equals(base)));
    });

    test('Collision resistance for delimiters', () {
      // JSON encoding prevents collisions like A="x,B=y" vs A="x", B="y"
      final id1 = EvidenceId.canonical(
        ruleId: 'r1', version: '1.0.0', conclusion: 'con',
        bindings: {'A': SemanticRef('line', 'x,B=y')},
        supports: [],
      );
      final id2 = EvidenceId.canonical(
        ruleId: 'r1', version: '1.0.0', conclusion: 'con',
        bindings: {'A': SemanticRef('line', 'x'), 'B': SemanticRef('line', 'y')},
        supports: [],
      );
      expect(id1, isNot(equals(id2)));
    });
  });

  group('F1.9 Codec Determinism', () {
    test('Encode and Decode loop is identical and deterministic', () {
      final rule = RuleDefinition(
        ruleId: RuleId('test.r'), version: RuleVersion('1.0.0'), origin: RuleOrigin.SYSTEM,
        namespace: 'core', categoryId: 'test', stage: RuleStage.derivedState, title: 'Title',
        description: 'Desc', provenance: 'Prov',
        bindings: [RuleBinding(name: 'A', selector: DirectSelector('line/2'))],
        condition: AllExpr([PredicateExpr(operatorId: 'rel', operands: [BindingRefOperand('A')])]),
        actions: [TagAction(categoryId: 'exam', tagId: 'doc', subjectBinding: 'A')],
      );
      final codec = RuleCodec();
      final json1 = codec.encode(rule);
      expect(jsonEncode(json1), equals(jsonEncode(codec.encode(codec.decode(json1)))));
    });
  });
}
