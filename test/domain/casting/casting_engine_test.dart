import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/casting/cast_chart.dart';
import 'package:guayan_trainer/domain/casting/casting_engine.dart';
import 'package:guayan_trainer/domain/casting/six_relative.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/tian_gan.dart';

/// R3 排盘引擎 · 引擎输出测试。
///
/// 对照基准为传统六爻排盘的经典结果（乾为天 / 坤为地 / 泽山咸），
/// 即专业排盘软件应给出的同一结果 —— Gate A 的离线等价物。
void main() {
  const shaoYang = MovementType.shaoYang;
  const shaoYin = MovementType.shaoYin;
  const laoYang = MovementType.laoYang;
  const laoYin = MovementType.laoYin;

  void expectLine(
    CastChart chart,
    int position, {
    required String ganZhi,
    required SixRelative relative,
    required bool isYang,
    bool isShi = false,
    bool isYing = false,
    String? changedGanZhi,
    SixRelative? changedRelative,
  }) {
    final line = chart.lineAt(position);
    expect(line.ganZhi, ganZhi, reason: '第 $position 爻纳甲');
    expect(line.relative, relative, reason: '第 $position 爻六亲');
    expect(line.isYang, isYang, reason: '第 $position 爻阴阳');
    expect(line.isShi, isShi, reason: '第 $position 爻世');
    expect(line.isYing, isYing, reason: '第 $position 爻应');
    if (changedGanZhi != null) {
      expect(line.changedGanZhi, changedGanZhi, reason: '第 $position 爻变卦纳甲');
    }
    if (changedRelative != null) {
      expect(
        line.changedRelative,
        changedRelative,
        reason: '第 $position 爻变卦六亲',
      );
    }
  }

  test('乾为天 静卦：纳甲 / 六亲 / 世应 全爻对照', () {
    final chart = CastingEngine.cast(const [
      shaoYang, shaoYang, shaoYang, shaoYang, shaoYang, shaoYang,
    ]);

    expect(chart.original.name, '乾为天');
    expect(chart.original.palace.label, '乾');
    expect(chart.isStatic, isTrue);
    expect(chart.changed, isNull, reason: '静卦不得生成变卦');

    expectLine(chart, 1, ganZhi: '甲子', relative: SixRelative.ziSun, isYang: true);
    expectLine(chart, 2, ganZhi: '甲寅', relative: SixRelative.qiCai, isYang: true);
    expectLine(chart, 3, ganZhi: '甲辰', relative: SixRelative.fuMu, isYang: true, isYing: true);
    expectLine(chart, 4, ganZhi: '壬午', relative: SixRelative.guanGui, isYang: true);
    expectLine(chart, 5, ganZhi: '壬申', relative: SixRelative.xiongDi, isYang: true);
    expectLine(chart, 6, ganZhi: '壬戌', relative: SixRelative.fuMu, isYang: true, isShi: true);
  });

  test('坤为地 静卦：纳甲 / 六亲 / 世应 全爻对照', () {
    final chart = CastingEngine.cast(const [
      shaoYin, shaoYin, shaoYin, shaoYin, shaoYin, shaoYin,
    ]);

    expect(chart.original.name, '坤为地');
    expect(chart.original.palace.label, '坤');

    expectLine(chart, 1, ganZhi: '乙未', relative: SixRelative.xiongDi, isYang: false);
    expectLine(chart, 2, ganZhi: '乙巳', relative: SixRelative.fuMu, isYang: false);
    expectLine(chart, 3, ganZhi: '乙卯', relative: SixRelative.guanGui, isYang: false, isYing: true);
    expectLine(chart, 4, ganZhi: '癸丑', relative: SixRelative.xiongDi, isYang: false);
    expectLine(chart, 5, ganZhi: '癸亥', relative: SixRelative.qiCai, isYang: false);
    expectLine(chart, 6, ganZhi: '癸酉', relative: SixRelative.ziSun, isYang: false, isShi: true);
  });

  test('泽山咸（兑宫三世）静卦对照', () {
    final chart = CastingEngine.cast(const [
      shaoYin, shaoYin, shaoYang, shaoYang, shaoYang, shaoYin,
    ]);

    expect(chart.original.name, '泽山咸');
    expect(chart.original.palace.label, '兑');
    expect(chart.original.shiPosition, 3);
    expect(chart.original.yingPosition, 6);

    expectLine(chart, 1, ganZhi: '丙辰', relative: SixRelative.fuMu, isYang: false);
    expectLine(chart, 2, ganZhi: '丙午', relative: SixRelative.guanGui, isYang: false);
    expectLine(chart, 3, ganZhi: '丙申', relative: SixRelative.xiongDi, isYang: true, isShi: true);
    expectLine(chart, 4, ganZhi: '丁亥', relative: SixRelative.ziSun, isYang: true);
    expectLine(chart, 5, ganZhi: '丁酉', relative: SixRelative.xiongDi, isYang: true);
    expectLine(chart, 6, ganZhi: '丁未', relative: SixRelative.fuMu, isYang: false, isYing: true);
  });

  test('老阳发动：初爻变阴 → 乾为天 变 天风姤', () {
    final chart = CastingEngine.cast(const [
      laoYang, shaoYang, shaoYang, shaoYang, shaoYang, shaoYang,
    ]);

    expect(chart.original.name, '乾为天');
    expect(chart.changed?.name, '天风姤');
    expect(chart.movingPositions, [1]);
    expect(chart.lineAt(1).isMoving, isTrue);

    // 变卦纳甲：下巽(辛丑亥酉) + 上乾(壬午申戌)。
    expectLine(chart, 1,
        ganZhi: '甲子',
        relative: SixRelative.ziSun,
        isYang: true,
        changedGanZhi: '辛丑',
        changedRelative: SixRelative.fuMu);
    expectLine(chart, 3,
        ganZhi: '甲辰',
        relative: SixRelative.fuMu,
        isYang: true,
        isYing: true,
        changedGanZhi: '辛酉',
        changedRelative: SixRelative.xiongDi);
    // 变卦六亲仍以本卦之宫（乾金）为「我」。
    expectLine(chart, 6,
        ganZhi: '壬戌',
        relative: SixRelative.fuMu,
        isYang: true,
        isShi: true,
        changedGanZhi: '壬戌',
        changedRelative: SixRelative.fuMu);
    expect(chart.lineAt(1).changedIsYang, isFalse, reason: '老阳变阴');
  });

  test('老阴发动：初爻变阳 → 坤为地 变 地雷复', () {
    final chart = CastingEngine.cast(const [
      laoYin, shaoYin, shaoYin, shaoYin, shaoYin, shaoYin,
    ]);

    expect(chart.original.name, '坤为地');
    expect(chart.changed?.name, '地雷复');
    expect(chart.lineAt(1).changedIsYang, isTrue, reason: '老阴变阳');
    expect(chart.movingPositions, [1]);
  });

  test('六神按日干接入：庚日初爻起白虎', () {
    final chart = CastingEngine.cast(
      const [shaoYang, shaoYang, shaoYang, shaoYang, shaoYang, shaoYang],
      dayGan: TianGan.geng,
    );
    expect(chart.dayGan, TianGan.geng);
    expect(chart.lines.map((l) => l.spirit?.label), [
      '白虎', '玄武', '青龙', '朱雀', '勾陈', '螣蛇',
    ]);
  });

  test('未提供日干时六神为 null，不猜默认值', () {
    final chart = CastingEngine.cast(const [
      shaoYang, shaoYang, shaoYang, shaoYang, shaoYang, shaoYang,
    ]);
    expect(chart.dayGan, isNull);
    expect(chart.lines.every((l) => l.spirit == null), isTrue);
  });

  test('非法输入被拒绝（爻数不为 6）', () {
    expect(
      () => CastingEngine.cast(const [shaoYang, shaoYang]),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('多动爻：动爻位置升序、变卦为对应翻转', () {
    // 乾为天六爻皆阳，故动爻只能是老阳（老阴要求本卦该爻为阴）。
    final chart = CastingEngine.cast(const [
      laoYang, shaoYang, shaoYang, shaoYang, laoYang, shaoYang,
    ]);
    expect(chart.original.name, '乾为天');
    expect(chart.movingPositions, [1, 5]);
    // 初爻阳→阴、五爻阳→阴：下卦 [f,t,t]=巽，上卦 [t,f,t]=离 → 火风鼎。
    expect(chart.changed?.name, '火风鼎');
    expect(chart.changed?.lower.label, '巽');
    expect(chart.changed?.upper.label, '离');
  });
}
