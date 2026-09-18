import '../ast/binding_selector.dart';
import '../facts/semantic_ref.dart';

String semanticRefLabel(SemanticRef ref) {
  if (ref.kind != 'line') return '${ref.kind}/${ref.key}';
  const names = {
    '1': '初爻',
    '2': '二爻',
    '3': '三爻',
    '4': '四爻',
    '5': '五爻',
    '6': '上爻',
  };
  return names[ref.key] ?? '爻${ref.key}';
}

String selectorLabel(BindingSelector selector) => switch (selector) {
      DirectSelector(:final target) => _directLabel(target),
      RelativeSelector(:final baseBinding, :final path) =>
        '$baseBinding · $path',
      DynamicBindingSelector(:final selectorId, :final parameters) =>
        _dynamicLabel(selectorId, parameters),
      _ => selector.runtimeType.toString(),
    };

String predicateLabel(
  String operatorId,
  List<SemanticRef> refs,
  List<Object?> literals,
  Object? actual,
) {
  if (operatorId == 'branch_clashes' && refs.length >= 2) {
    final left = _factValueLabel(refs[0], actual, 0);
    final right = _factValueLabel(refs[1], actual, 1);
    return '${semanticRefLabel(refs[0])}$left 冲 ${semanticRefLabel(refs[1])}$right';
  }
  if (operatorId == 'relative' && refs.isNotEmpty && literals.isNotEmpty) {
    return '${semanticRefLabel(refs.first)} 六亲为 ${_relativeLabel(literals.first)}';
  }
  if (operatorId == 'spirit' && refs.isNotEmpty && literals.isNotEmpty) {
    return '${semanticRefLabel(refs.first)} 六神为 ${_spiritLabel(literals.first)}';
  }
  return operatorId;
}

String _directLabel(String target) {
  final parts = target.split('/');
  if (parts.length == 2 && parts.first == 'line') {
    return semanticRefLabel(SemanticRef(parts.first, parts.last));
  }
  return target;
}

String _dynamicLabel(String selectorId, Map<String, String> parameters) =>
    switch (selectorId) {
      'dynamic.line.all' => '任一爻',
      'dynamic.line.by_spirit' =>
        '${_spiritLabel(parameters['spirit'])}所临之爻',
      'dynamic.line.shi' => '世爻',
      'dynamic.line.ying' => '应爻',
      'dynamic.line.moving' => '发动之爻',
      _ => selectorId,
    };

String _spiritLabel(Object? value) => switch (value) {
      'spirit.qing_long' || '青龙' => '青龙',
      'spirit.zhu_que' || '朱雀' => '朱雀',
      'spirit.gou_chen' || '勾陈' => '勾陈',
      'spirit.teng_she' || '螣蛇' || '腾蛇' => '螣蛇',
      'spirit.bai_hu' || '白虎' => '白虎',
      'spirit.xuan_wu' || '玄武' => '玄武',
      _ => value?.toString() ?? '未知六神',
    };

String _relativeLabel(Object? value) => switch (value) {
      'relative.sibling' || '兄弟' => '兄弟',
      'relative.child' || '子孙' => '子孙',
      'relative.spouse' || '妻财' => '妻财',
      'relative.parent' || '父母' => '父母',
      'relative.official' || '官鬼' => '官鬼',
      _ => value?.toString() ?? '未知六亲',
    };

String _factValueLabel(SemanticRef ref, Object? actual, int index) {
  if (actual is List && actual.length > index) {
    return '（${actual[index]}）';
  }
  return '';
}
