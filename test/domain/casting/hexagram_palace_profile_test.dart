import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/casting/bagua.dart';
import 'package:guayan_trainer/domain/casting/hexagram64.dart';
import 'package:guayan_trainer/domain/casting/hexagram_palace_profile.dart';
import 'package:guayan_trainer/domain/casting/palace.dart';

void main() {
  test('四个世应阶段 Golden', () {
    final cases = {
      '水地比': (Bagua.kun, EightPalaceStage.guiHun, 3, 6),
      '坎为水': (Bagua.kan, EightPalaceStage.benGong, 6, 3),
      '风地观': (Bagua.qian, EightPalaceStage.siShi, 4, 1),
      '火地晋': (Bagua.qian, EightPalaceStage.youHun, 4, 1),
    };

    for (final entry in cases.entries) {
      final hexagram = baGongTable
          .map((item) => resolveHexagram(item.lines))
          .firstWhere((item) => item.name == entry.key);
      final profile = HexagramPalaceProfile.fromHexagram(hexagram);
      expect(profile.palace, entry.value.$1);
      expect(profile.stage, entry.value.$2);
      expect(profile.shiLine, entry.value.$3);
      expect(profile.yingLine, entry.value.$4);
    }
  });

  test('八宫八阶段完整覆盖 64 卦且世应有效', () {
    expect(baGongTable, hasLength(64));
    for (final entry in baGongTable) {
      final profile = HexagramPalaceProfile.fromHexagram(
        resolveHexagram(entry.lines),
      );
      expect(profile.stage, isNotNull);
      expect(profile.shiLine, inInclusiveRange(1, 6));
      expect(profile.yingLine, inInclusiveRange(1, 6));
    }
  });
}
