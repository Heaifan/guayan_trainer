import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/relations/widgets/relation_glyph.dart';

void main() {
  testWidgets('ledger glyph puts the Chinese action above its painted arrow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RelationGlyph(type: RelationType.ke)),
      ),
    );

    final label = tester.getTopLeft(find.text('克')).dy;
    final arrow = tester
        .getTopLeft(find.byKey(const Key('relation_glyph_arrow')))
        .dy;
    expect(label, lessThan(arrow));
    expect(find.byKey(const Key('relation_glyph_arrow')), findsOneWidget);
    expect(find.text('➡'), findsNothing);
    expect(find.text('↔️'), findsNothing);
  });

  testWidgets(
    'symmetric relations keep a glyph while directed relations do too',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RelationGlyph(type: RelationType.sheng),
                RelationGlyph(type: RelationType.liuHe),
              ],
            ),
          ),
        ),
      );
      expect(find.text('生'), findsOneWidget);
      expect(find.text('六合'), findsOneWidget);
      expect(find.byKey(const Key('relation_glyph_arrow')), findsNWidgets(2));
    },
  );
}
