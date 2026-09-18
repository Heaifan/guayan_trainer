import 'package:flutter/material.dart';

import '../../../theme/wuxing_colors.dart';
import '../review_page_state.dart';

/// 统一渲染六亲与纳甲干支；六亲保持深色，干支五行按领域事实着色。
class LineIdentityText extends StatelessWidget {
  const LineIdentityText({
    super.key,
    required this.identity,
    this.compact = false,
    this.style = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF243744),
      height: 1.2,
    ),
  });

  final ReviewLineIdentity identity;
  final bool compact;
  final TextStyle style;

  static Text buildText(
    ReviewLineIdentity identity, {
    Key? key,
    bool compact = false,
    TextStyle style = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF243744),
      height: 1.2,
    ),
  }) => Text.rich(
    key: key,
    TextSpan(
      children: [
        TextSpan(
          text: compact ? _shortRelative(identity.relative) : identity.relative,
        ),
        TextSpan(
          text: '${identity.ganZhi}${identity.element}',
          style: style.copyWith(color: WuxingColors.getColor(identity.element)),
        ),
      ],
    ),
    maxLines: 1,
    overflow: TextOverflow.clip,
    style: style,
  );

  @override
  Widget build(BuildContext context) =>
      buildText(identity, compact: compact, style: style);

  static String _shortRelative(String relative) => switch (relative) {
    '父母' => '父',
    '兄弟' => '兄',
    '妻财' => '财',
    '官鬼' => '官',
    '子孙' => '孙',
    _ => relative,
  };
}
