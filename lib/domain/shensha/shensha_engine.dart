/// R1 确认规则集的确定性神煞计算器。
library;

import '../di_zhi.dart';
import '../wu_xing.dart';
import 'shensha_models.dart';
import 'shensha_tables.dart';

class ShenShaEngine {
  const ShenShaEngine({
    this.ruleSetId = 'shensha.standard.v1',
    this.ruleVersion = 1,
  });

  final String ruleSetId;
  final int ruleVersion;

  List<ShenShaResult> calculate(ShenShaContext context) {
    final guaShen = _guaShen(context);
    final results = <ShenShaResult>[
      _result(
        'gua_shen',
        '卦身',
        [guaShen],
        '世爻位置/阴阳',
        '${context.shiPosition}/${context.shiIsYang ? '阳' : '阴'}',
      ),
      _result('xiang_gui', '香闺', _controlledBy(guaShen), '卦身五行', guaShen),
      _result('chuang_zhang', '床帐', _generatedBy(guaShen), '卦身五行', guaShen),
    ];
    for (final name in const [
      '驿马',
      '桃花',
      '华盖',
      '贵人',
      '天禄',
      '天喜',
      '天医',
      '文昌',
      '劫煞',
      '灾煞',
      '金舆',
      '亡神',
      '将星',
      '羊刃',
      '谋星',
      '往亡',
    ]) {
      results.add(
        _result(
          _id(name),
          name,
          _branchesFor(name, context),
          _basisType(name),
          _basisValue(name, context),
        ),
      );
    }
    return results;
  }

  ShenShaResult _result(
    String shortId,
    String name,
    List<String> branches,
    String basisType,
    String basisValue,
  ) => ShenShaResult(
    id: 'shensha.$shortId',
    displayName: name,
    branches: branches,
    basisType: basisType,
    basisValue: basisValue,
    ruleSetId: ruleSetId,
    ruleVersion: ruleVersion,
    reasonSnapshot: '$basisType=$basisValue → ${branches.join()}',
  );

  String _guaShen(ShenShaContext c) =>
      (c.shiIsYang ? '子丑寅卯辰巳' : '午未申酉戌亥')[c.shiPosition - 1];

  List<String> _branchesFor(String name, ShenShaContext c) {
    if (triadResults.containsKey(name)) {
      return _chars(triadResults[name]![_triad(c.dayBranch.label)]!);
    }
    if (ganResults.containsKey(name)) {
      return _chars(ganResults[name]![c.dayGan.label]!);
    }
    if (name == '天喜') {
      return _chars(_lookup(seasonResults, c.monthBranch.label));
    }
    if (name == '天医') {
      return [DiZhi.values[(c.monthBranch.index + 11) % 12].label];
    }
    if (name == '往亡') {
      return [_lookup(wangWangResults, c.monthBranch.label)];
    }
    throw StateError('未定义神煞：$name');
  }

  String _triad(String branch) =>
      triadBranches.keys.firstWhere((key) => key.contains(branch));

  List<String> _controlledBy(String branch) =>
      _byWuXing(branch, controls: true);
  List<String> _generatedBy(String branch) =>
      _byWuXing(branch, controls: false);

  List<String> _byWuXing(String branch, {required bool controls}) {
    final element = DiZhi.fromLabel(branch).wuXing;
    final labels = controls
        ? switch (element) {
            WuXing.shui => '巳午',
            WuXing.mu => '辰戌丑未',
            WuXing.huo => '申酉',
            WuXing.jin => '寅卯',
            WuXing.tu => '子亥',
          }
        : switch (element) {
            WuXing.shui => '寅卯',
            WuXing.mu => '巳午',
            WuXing.huo => '辰戌丑未',
            WuXing.jin => '子亥',
            WuXing.tu => '申酉',
          };
    return _chars(labels);
  }

  String _basisType(String name) => triadResults.containsKey(name)
      ? '日支三合局'
      : ganResults.containsKey(name)
      ? '日干'
      : '月支';

  String _basisValue(String name, ShenShaContext c) =>
      _basisType(name) == '日支三合局'
      ? _triad(c.dayBranch.label)
      : _basisType(name) == '日干'
      ? c.dayGan.label
      : c.monthBranch.label;

  String _id(String name) => const {
    '驿马': 'yi_ma',
    '桃花': 'tao_hua',
    '华盖': 'hua_gai',
    '贵人': 'gui_ren',
    '天禄': 'tian_lu',
    '天喜': 'tian_xi',
    '天医': 'tian_yi',
    '文昌': 'wen_chang',
    '劫煞': 'jie_sha',
    '灾煞': 'zai_sha',
    '金舆': 'jin_yu',
    '亡神': 'wang_shen',
    '将星': 'jiang_xing',
    '羊刃': 'yang_ren',
    '谋星': 'mou_xing',
    '往亡': 'wang_wang',
  }[name]!;

  String _lookup(Map<String, String> map, String branch) =>
      map.entries.firstWhere((e) => e.key.contains(branch)).value;

  List<String> _chars(String value) => [
    for (var i = 0; i < value.length; i++) value[i],
  ];
}
