import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 时间卡（四柱，包含纳音，高度 72）。
///
/// 顺序固定：年 → 月 → 日 → 时 → 旬空（右对齐）。
class ReviewTimeCard extends StatelessWidget {
  const ReviewTimeCard({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillarText(
              text: state.yearPillar ?? '—',
              naYin: state.yearNaYin ?? '—',
              color: const Color(0xFF4F8A8B),
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.monthPillar ?? '—',
              naYin: state.monthNaYin ?? '—',
              color: const Color(0xFFA45E5E),
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.dayPillar ?? '—',
              naYin: state.dayNaYin ?? '—',
              color: const Color(0xFFA45E5E),
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.hourPillar ?? '—',
              naYin: state.hourNaYin ?? '—',
              color: const Color(0xFF4F8A8B),
            ),
          ),
          Expanded(
            child: _PillarText(
              text: state.xunKong ?? '—',
              naYin: '旬空',
              color: const Color(0xFF4F8A8B),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarText extends StatelessWidget {
  const _PillarText({
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
        Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.2,
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
