/// 共享爻组件冻结规格测试（UI-CORRECTION-R2 UI-05/UI-06 组件级）。
///
/// YaoGlyph：阳/阴/空亡爻槽外部尺寸一律 24 × 6；
/// MovingMarker：老阴 ○ / 老阳 × 一律 12 × 12。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/presentation/shared/moving_marker.dart';
import 'package:guayan_trainer/presentation/shared/yao_glyph.dart';

void main() {
  group('YaoGlyph 统一 24×6', () {
    testWidgets('阳爻 = 24×6', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: YaoGlyph(kind: YaoKind.yang))),
      );
      final size = tester.getSize(find.byType(YaoGlyph));
      expect(size.width, 24);
      expect(size.height, 6);
    });

    testWidgets('阴爻 = 24×6', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: YaoGlyph(kind: YaoKind.yin))),
      );
      final size = tester.getSize(find.byType(YaoGlyph));
      expect(size.width, 24);
      expect(size.height, 6);
    });

    testWidgets('空亡爻 = 24×6', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: YaoGlyph.voidYao())),
      );
      final size = tester.getSize(find.byType(YaoGlyph));
      expect(size.width, 24);
      expect(size.height, 6);
    });

    test('便捷工厂 fromMovement：阴阳推导', () {
      expect(YaoGlyph.fromMovement(MovementType.shaoYang).kind, YaoKind.yang);
      expect(YaoGlyph.fromMovement(MovementType.laoYang).kind, YaoKind.yang);
      expect(YaoGlyph.fromMovement(MovementType.shaoYin).kind, YaoKind.yin);
      expect(YaoGlyph.fromMovement(MovementType.laoYin).kind, YaoKind.yin);
    });
  });

  group('MovingMarker 统一 12×12', () {
    testWidgets('老阴 ○ = 12×12', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MovingMarker.oldYin())),
      );
      final size = tester.getSize(find.byType(MovingMarker));
      expect(size.width, 12);
      expect(size.height, 12);
    });

    testWidgets('老阳 × = 12×12', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MovingMarker.oldYang())),
      );
      final size = tester.getSize(find.byType(MovingMarker));
      expect(size.width, 12);
      expect(size.height, 12);
    });

    test('便捷工厂 of：老阴/老阳推导', () {
      expect(MovingMarker.of(MovementType.laoYin).isYin, isTrue);
      expect(MovingMarker.of(MovementType.laoYang).isYin, isFalse);
    });
  });
}
