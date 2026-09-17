library;

import '../vocabulary/condition_id.dart';
import '../vocabulary/nayin_catalog.dart';

class DslVocabulary {
  static const Map<String, String> operatorMap = {
    '六亲为': ConditionId.relative,
    '六神为': ConditionId.spirit,
    '生': ConditionId.generate,
    '为空': ConditionId.empty,
    '纳音为': ConditionId.nayinIs,
    '旬空': ConditionId.xunKong,
    '月破': ConditionId.yuePo,
    '日破': ConditionId.riPo,
    '在库': ConditionId.inTomb,
    '入库于': ConditionId.ruMu,
    '冲库': ConditionId.chongMu,
    '出库': ConditionId.chuMu,
    '有标签': ConditionId.hasTag,
    '天干为': ConditionId.stemIs,
    '地支为': ConditionId.branchIs,
    '五行为': ConditionId.elementIs,
    '克': ConditionId.controls,
    '冲': ConditionId.branchClashes,
    '合': ConditionId.branchCombines,
    '刑': ConditionId.branchPunishes,
    '害': ConditionId.branchHarms,
    '破': ConditionId.branchBreaks,
  };

  static String mapValue(String chineseText) {
    if (_relations.containsKey(chineseText)) return _relations[chineseText]!;
    if (_spirits.containsKey(chineseText)) return _spirits[chineseText]!;
    for (final nayin in NaYinCatalog.all) {
      if (nayin.name == chineseText) return nayin.id.value;
    }
    return chineseText;
  }

  static String mapToChinese(String id) {
    if (operatorMap.containsValue(id)) {
      return operatorMap.entries.firstWhere((e) => e.value == id).key;
    }
    if (_relations.containsValue(id)) {
      return _relations.entries.firstWhere((e) => e.value == id).key;
    }
    if (_spirits.containsValue(id)) {
      return _spirits.entries.firstWhere((e) => e.value == id).key;
    }
    for (final nayin in NaYinCatalog.all) {
      if (nayin.id.value == id) return nayin.name;
    }
    return id;
  }

  static const _relations = {
    '父母': 'relative.parent',
    '兄弟': 'relative.brother',
    '子孙': 'relative.child',
    '妻财': 'relative.wife',
    '官鬼': 'relative.officer',
  };

  static const _spirits = {
    '青龙': 'spirit.qing_long',
    '朱雀': 'spirit.zhu_que',
    '勾陈': 'spirit.gou_chen',
    '腾蛇': 'spirit.teng_she',
    '白虎': 'spirit.bai_hu',
    '玄武': 'spirit.xuan_wu',
  };
}
