import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/dsl/guayan_dsl_parser.dart';
import 'package:guayan_trainer/domain/rules/dsl/guayan_dsl_formatter.dart';

void main() {
  group('Guayan DSL Round Trip', () {
    test('parses and formats successfully', () {
      final source =
          '''
取 A = @line/2
取 B = @changed_line/2
若
    A 六亲为 父母
    且 B 有标签 父母
则
    得 A state.parent_supported
    取象 exam:document
    成局 structure.san_he: A, B
    记 audit.note {"source":"manual"}
'''
              .trim();

      final parser = GuayanDslParser();
      final formatter = GuayanDslFormatter();

      final parse1 = parser.parse(source);
      expect(
        parse1.isSuccess,
        isTrue,
        reason: parse1.diagnostics.map((e) => e.message).join(', '),
      );

      final formatted1 = formatter.format(parse1.value!);

      final parse2 = parser.parse(formatted1);
      expect(parse2.isSuccess, isTrue);

      final formatted2 = formatter.format(parse2.value!);

      expect(formatted1, formatted2);
      // It should be identical to the original canonical source.
      expect(formatted1, source);
    });

    test('handles CRLF correctly', () {
      final crlfSource =
          '取 A = @line/2\r\n若\r\n    A 为空\r\n则\r\n    得 A state.supported';
      final parser = GuayanDslParser();
      final result = parser.parse(crlfSource);

      expect(result.isSuccess, isTrue);
      expect(result.value!.bindings.length, 1);
    });
  });
}
