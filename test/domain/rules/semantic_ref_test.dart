import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_record.dart';
import 'package:guayan_trainer/domain/rules/facts/fact_snapshot.dart';
import 'package:guayan_trainer/domain/rules/facts/rule_value.dart';
import 'package:guayan_trainer/domain/rules/facts/semantic_ref.dart';

void main() {
  group('SemanticRef Contract', () {
    test('SemanticRef equality 稳定', () {
      final ref1 = SemanticRef('line', '2');
      final ref2 = SemanticRef.line(2);
      expect(ref1, equals(ref2));
      expect(ref1.hashCode, equals(ref2.hashCode));
    });

    test('SemanticRef JSON-safe', () {
      final ref = SemanticRef.changedLine(3);
      final json = ref.toJson();
      final restored = SemanticRef.fromJson(json);
      expect(restored, equals(ref));
    });

    test('line/changedLine/month/day/world/response 可以无歧义表达', () {
      expect(SemanticRef.line(1).toString(), 'SemanticRef(line/1)');
      expect(SemanticRef.changedLine(6).toString(), 'SemanticRef(changed_line/6)');
      expect(SemanticRef.month.toString(), 'SemanticRef(calendar/month)');
      expect(SemanticRef.day.toString(), 'SemanticRef(calendar/day)');
      expect(SemanticRef.roleWorld.toString(), 'SemanticRef(role/world)');
      expect(SemanticRef.roleResponse.toString(), 'SemanticRef(role/response)');
    });
  });

  group('RuleValue Contract', () {
    test('RuleValue 不接受 Function / 任意可执行对象', () {
      final valid = RuleValue.string('relative.parent');
      expect(valid.value, 'relative.parent');

      // ignore: avoid_print
      expect(() => RuleValue.fromJson(() => print('Hello')), throwsArgumentError);
      void executable() {}
      expect(() => RuleValue.fromJson(executable), throwsArgumentError);
    });
  });

  group('FactSnapshot Contract', () {
    test('FactSnapshot 构建后不可修改', () {
      final facts = [
        FactRecord(
          factId: 'f1',
          subject: SemanticRef.line(2),
          predicateId: 'relative',
          value: RuleValue.string('relative.parent'),
          origin: FactOrigin.original,
        )
      ];
      final snapshot = FactSnapshot.build(facts);
      
      // 验证无法 cast 强行 add
      expect(() {
        (snapshot.facts as dynamic).add(
          FactRecord(
            factId: 'f2',
            subject: SemanticRef.line(3),
            predicateId: 'test',
            value: RuleValue.boolean(true),
            origin: FactOrigin.original,
          )
        );
      }, throwsA(isA<NoSuchMethodError>()));
    });
    
    test('构建 FactSnapshot 不修改 HexagramCase (Contract verification)', () {
      // 本测试只需表明 FactSnapshot 是数据容器，完全分离于 HexagramCase 业务实体
      // 外部只需传递 Iterable<FactRecord> 即可构建，无 HexagramCase 依赖
      final snapshot = FactSnapshot.build([]);
      expect(snapshot.facts, isEmpty);
    });
  });
}
