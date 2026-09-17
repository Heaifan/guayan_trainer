import 'package:flutter/material.dart';

import '../review_page_state.dart';

/// 时间卡（四柱，包含纳音，紧凑高度 50）。
///
/// 顺序固定：年 → 月 → 日 → 时 → 旬空（右对齐）。
class ReviewTimeCard extends StatelessWidget {
  const ReviewTimeCard({
    super.key,
    required this.state,
    this.anchorKeys = const {},
  });

  final ReviewPageState state;
  final Map<String, GlobalKey> anchorKeys;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillarText(
              key: anchorKeys['year'],
              text: state.yearPillar ?? '—',
              naYin: state.yearNaYin ?? '—',
              color: const Color(0xFF4F8A8B),
            ),
          ),
          Expanded(
            child: _PillarText(
              key: anchorKeys['month'],
              text: state.monthPillar ?? '—',
              naYin: state.monthNaYin ?? '—',
              color: const Color(0xFFA45E5E),
            ),
          ),
          Expanded(
            child: _PillarText(
              key: anchorKeys['day'],
              text: state.dayPillar ?? '—',
              naYin: state.dayNaYin ?? '—',
              color: const Color(0xFFA45E5E),
            ),
          ),
          Expanded(
            child: _PillarText(
              key: anchorKeys['hour'],
              text: state.hourPillar ?? '—',
              naYin: state.hourNaYin ?? '—',
              color: const Color(0xFF4F8A8B),
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.xunKong == null
                  ? ''
                  : '(${_xunKongLabel(state.xunKong!)})',
              naYin: '',
              color: const Color(0xFF4F8A8B),
            ),
          ),
        ],
      ),
    );
  }
}

String _xunKongLabel(String value) => value.endsWith('空') ? value : '$value空';

class _PillarText extends StatelessWidget {
  const _PillarText({
    super.key,
    required this.text,
    required this.naYin,
    required this.color,
  });

  final String text;
  final String naYin;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          naYin,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF71838B),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
