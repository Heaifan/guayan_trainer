import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/fushen_engine.dart';
import 'package:guayan_trainer/domain/casting/six_relative.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/wu_xing.dart';

void main() {
  const yin = MovementType.shaoYin;
  const yang = MovementType.shaoYang;

  test('水火既济缺妻财，妻财戊午火伏在三爻', () {
    final chart = CastingEngine.cast(const [yang, yin, yang, yin, yang, yin]);

    final results = FushenEngine.calculate(chart);

    expect(results, hasLength(1));
    final result = results.single;
    expect(result.lineIndex, 3);
    expect(result.relative, SixRelative.qiCai);
    expect(result.stem.label, '戊');
    expect(result.branch.label, '午');
    expect(result.element, WuXing.huo);
    expect(result.sourcePalace.label, '坎');
    expect(result.sourceHexagramId, '坎为水');
    expect(result.flyingLineId, 'line-3');
    expect(result.reasonSnapshot, contains('主卦六爻无妻财'));
  });

  test('水雷屯缺妻财，单伏神仍落在三爻', () {
    final chart = CastingEngine.cast(const [yang, yin, yin, yin, yang, yin]);

    final results = FushenEngine.calculate(chart);

    expect(chart.original.name, '水雷屯');
    expect(results, hasLength(1));
    expect(results.single.lineIndex, 3);
    expect(results.single.label, '妻财戊午火');
  });

  test('风地观支持两个缺失六亲并分别伏在本宫对应爻位', () {
    final chart = CastingEngine.cast(const [yin, yin, yin, yin, yang, yang]);

    final results = FushenEngine.calculate(chart);

    expect(chart.original.name, '风地观');
    expect(chart.original.palace.label, '乾');
    expect(
      results.map((result) => result.relative),
      containsAll(<SixRelative>[SixRelative.ziSun, SixRelative.xiongDi]),
    );
    expect(results.map((result) => result.lineIndex), containsAll(<int>[1, 5]));
  });
}
