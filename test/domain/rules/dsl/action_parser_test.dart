import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/dsl/action_parser.dart';
import 'package:guayan_trainer/domain/rules/dsl/dsl_lexer.dart';
import 'package:guayan_trainer/domain/rules/ast/rule_action.dart';

void main() {
  group('ActionParser', () {
    test('parses DeriveAction', () {
      final tokens = DslLexer('则\n    得 A state.parent_supported').lex().value!;
      final result = ActionParser(tokens).parse();
      expect(result.isSuccess, isTrue);
      expect(result.value!.length, 1);
      final action = result.value![0] as DeriveAction;
      expect(action.targetBinding, 'A');
      expect(action.factKey, 'state.parent_supported');
    });

    test('parses TagAction', () {
      final tokens = DslLexer('则\n    取象 A exam:document').lex().value!;
      final result = ActionParser(tokens).parse();
      expect(result.isSuccess, isTrue);
      final action = result.value![0] as TagAction;
      expect(action.subjectBinding, 'A');
      expect(action.categoryId, 'exam');
      expect(action.tagId, 'document');
    });

    test('parses global TagAction', () {
      final tokens = DslLexer('则\n    取象 exam:document').lex().value!;
      final result = ActionParser(tokens).parse();
      expect(result.isSuccess, isTrue);
      final action = result.value![0] as TagAction;
      expect(action.subjectBinding, isNull);
      expect(action.categoryId, 'exam');
      expect(action.tagId, 'document');
    });

    test('parses StructureAction', () {
      final tokens = DslLexer(
        '则\n    成局 structure.san_he: A, B, C',
      ).lex().value!;
      final result = ActionParser(tokens).parse();
      expect(result.isSuccess, isTrue);
      final action = result.value![0] as StructureAction;
      expect(action.structureId, 'structure.san_he');
      expect(action.memberBindings, ['A', 'B', 'C']);
    });

    test('parses RecordAction', () {
      final tokens = DslLexer(
        '则\n    记 audit.note {"source":"manual"}',
      ).lex().value!;
      final result = ActionParser(tokens).parse();
      expect(result.isSuccess, isTrue);
      final action = result.value![0] as RecordAction;
      expect(action.recordType, 'audit.note');
      expect(action.content['source']?.value, 'manual');
    });
  });
}
