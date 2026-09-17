import 'package:flutter_test/flutter_test.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_type.dart';
import 'package:guayan_trainer/presentation/relations/relation_endpoint_presenter.dart';
import 'package:guayan_trainer/presentation/review/review_page_state.dart';

void main() {
  test('presents yao and calendar endpoints in Chinese', () {
    final state = ReviewPageState(
      question: '测试',
      lines: [
        for (var i = 1; i <= 6; i++)
          ReviewLineView(
            position: i,
            movementType: MovementType.shaoYang,
            sixRelative: i == 1 ? '子孙乙卯木' : null,
          ),
      ],
      focusedRelations: const [],
      allRelations: const [],
    );
    final presenter = RelationEndpointPresenter(state);

    expect(
      presenter.present(YaoEndpoint(LineScope.original, 1)).fullName,
      '初爻 · 子孙乙卯木',
    );
    expect(presenter.present(const MonthEndpoint()).position, '月建');
    expect(presenter.present(const DayEndpoint()).position, '日辰');
  });

  test('maps rule names without exposing rule ids', () {
    final presenter = RelationEndpointPresenter(null);
    expect(presenter.ruleName(RelationType.ke, 'sys.ke'), '五行相克');
    expect(presenter.sourceName(), '排盘事实');
  });
}
