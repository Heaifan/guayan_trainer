import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/nayin_id.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/nayin_catalog.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_registry.dart';
import 'package:guayan_trainer/domain/rules/vocabulary/condition_id.dart';

void main() {
  group('NaYin Canonical Vocabulary Tests', () {
    test('30 NaYin IDs exactly and all IDs/names unique', () {
      expect(NaYinId.values.length, 30);
      final idSet = <String>{};
      final nameSet = <String>{};
      for (final n in NaYinId.values) {
        expect(idSet.add(n.value), isTrue, reason: 'Duplicate ID: ');
      }
      for (final e in NaYinCatalog.all) {
        expect(nameSet.add(e.name), isTrue, reason: 'Duplicate Name: ');
      }
      expect(idSet.length, 30);
      expect(nameSet.length, 30);
    });

    test('60 JiaZi mappings exactly, 60 unique JiaZi, 30 unique NaYin', () {
      final jiaZiIndices = <int>{};
      final mappedNaYins = <String>{};
      
      for (int i = 0; i < 60; i++) {
        jiaZiIndices.add(i);
        final entry = NaYinCatalog.getByJiaZiIndex(i);
        mappedNaYins.add(entry.id.value);
      }
      
      expect(jiaZiIndices.length, 60);
      expect(mappedNaYins.length, 30);
    });

    test('Each NaYin maps exactly 2 JiaZi', () {
      final counts = <String, int>{};
      for (int i = 0; i < 60; i++) {
        final id = NaYinCatalog.getByJiaZiIndex(i).id.value;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      for (final count in counts.values) {
        expect(count, 2);
      }
    });

    test('60 JiaZi Anchor Truth Tests', () {
      expect(NaYinCatalog.getByJiaZiIndex(0).name, '海中金'); // 甲子
      expect(NaYinCatalog.getByJiaZiIndex(1).name, '海中金'); // 乙丑

      expect(NaYinCatalog.getByJiaZiIndex(8).name, '剑锋金'); // 壬申
      expect(NaYinCatalog.getByJiaZiIndex(9).name, '剑锋金'); // 癸酉

      expect(NaYinCatalog.getByJiaZiIndex(30).name, '沙中金'); // 甲午
      expect(NaYinCatalog.getByJiaZiIndex(31).name, '沙中金'); // 乙未

      expect(NaYinCatalog.getByJiaZiIndex(40).name, '佛灯火'); // 甲辰
      expect(NaYinCatalog.getByJiaZiIndex(41).name, '佛灯火'); // 乙巳

      expect(NaYinCatalog.getByJiaZiIndex(48).name, '桑柘木'); // 壬子
      expect(NaYinCatalog.getByJiaZiIndex(49).name, '桑柘木'); // 癸丑

      expect(NaYinCatalog.getByJiaZiIndex(56).name, '石榴木'); // 庚申
      expect(NaYinCatalog.getByJiaZiIndex(57).name, '石榴木'); // 辛酉

      expect(NaYinCatalog.getByJiaZiIndex(58).name, '大海水'); // 壬戌
      expect(NaYinCatalog.getByJiaZiIndex(59).name, '大海水'); // 癸亥
    });
  });

  group('Condition Registry Tests', () {
    test('Condition arity and presence', () {
      final xunKong = CanonicalConditionRegistry.getDefinition(ConditionId.xunKong)!;
      expect(xunKong.operandCount, 1);

      final ruMu = CanonicalConditionRegistry.getDefinition(ConditionId.ruMu)!;
      expect(ruMu.operandCount, 2);

      final chongMu = CanonicalConditionRegistry.getDefinition(ConditionId.chongMu)!;
      expect(chongMu.operandCount, 2);

      final chuMu = CanonicalConditionRegistry.getDefinition(ConditionId.chuMu)!;
      expect(chuMu.operandCount, 3);
      
      final nayinIs = CanonicalConditionRegistry.getDefinition(ConditionId.nayinIs)!;
      expect(nayinIs.operandCount, 2);
      
      final hasTag = CanonicalConditionRegistry.getDefinition(ConditionId.hasTag)!;
      expect(hasTag.operandCount, 3);
    });
  });
}
