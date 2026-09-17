import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/casting/bagua.dart';
import 'package:guayan_trainer/domain/casting/double_fucang_engine.dart';

void main() {
  test('巽宫双伏藏与参考图逐爻一致', () {
    final result = DoubleFucangEngine.calculate(Bagua.xun);

    expect(result.primaryPalace, Bagua.xun);
    expect(result.oppositePalace, Bagua.zhen);
    expect(result.primary, hasLength(6));
    expect(result.opposite, hasLength(6));
    expect(
      result.primary.reversed.map(
        (line) => '${line.relative.shortLabel}${line.ganZhi}',
      ),
      ['兄辛卯', '孙辛巳', '财辛未', '官辛酉', '父辛亥', '财辛丑'],
    );
    expect(
      result.opposite.reversed.map(
        (line) => '${line.relative.shortLabel}${line.ganZhi}',
      ),
      ['财庚戌', '官庚申', '孙庚午', '财庚辰', '兄庚寅', '父庚子'],
    );
  });

  test('四组本宫对宫固定配对且始终生成 6 + 6', () {
    const pairs = [
      (Bagua.qian, Bagua.kun),
      (Bagua.kun, Bagua.qian),
      (Bagua.zhen, Bagua.xun),
      (Bagua.xun, Bagua.zhen),
      (Bagua.kan, Bagua.li),
      (Bagua.li, Bagua.kan),
      (Bagua.dui, Bagua.gen),
      (Bagua.gen, Bagua.dui),
    ];

    for (final (palace, opposite) in pairs) {
      final result = DoubleFucangEngine.calculate(palace);
      expect(result.oppositePalace, opposite);
      expect(result.primary.map((line) => line.lineIndex), [1, 2, 3, 4, 5, 6]);
      expect(result.opposite.map((line) => line.lineIndex), [1, 2, 3, 4, 5, 6]);
    }
  });
}
