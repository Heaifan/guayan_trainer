import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/dsl/dsl_parser.dart';
import 'package:guayan_trainer/domain/dsl/dsl_formatter.dart';

void main() {
  test('R5-C2 FAST-TRACK: DSL Round Trip Equivalence', () {
    final source =
        '''
取 A = @line/2
取 B = A.changedLine
取 M = @calendar/month

若 A 六亲为父母
    或 B 纳音为天河水
    或
        A 月破
        且 A 日破
        且 A 为空
        且 A 有标签 shensha:shensha.custom.foo
        且 M 生 A
    或 A 在墓中
    或 非 B 旬空
    或 A 入墓于 B
    或 A 冲墓于 B
    或 A 出墓于 B 冲 M
则
    得 A state.fuMu_supported
    取象 A exam:document
    成局 some_pattern A,B
    记 event type=trigger
'''
            .trim();

    final parsed1 = GuayanDslParser.parse(source);
    final formatted1 = GuayanDslFormatter.format(
      bindings: parsed1.bindings,
      condition: parsed1.condition,
      actions: parsed1.actions,
    );

    expect(formatted1, equals(source));

    final parsed2 = GuayanDslParser.parse(formatted1);
    final formatted2 = GuayanDslFormatter.format(
      bindings: parsed2.bindings,
      condition: parsed2.condition,
      actions: parsed2.actions,
    );

    expect(formatted2, equals(formatted1));
  });
}
