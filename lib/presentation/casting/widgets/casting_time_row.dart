import 'package:flutter/material.dart';

import '../casting_page_state.dart';
import '../casting_tokens.dart';
import 'casting_chip.dart';

/// 起卦时间 · 第一行（UI-CORRECTION-R2 §2 SVG：402×88）。
///
/// 同时显示公历与农历；农历为 presentation mock（[lunarPlaceholder]，GAP
/// 标注，不做真实换算算法）。未设置时显示占位并标记「待完善」。
class CastingTimeRow extends StatelessWidget {
  const CastingTimeRow({super.key, required this.castingTime, this.onTap});

  final DateTime? castingTime;
  final VoidCallback? onTap;

  String get _solar {
    final t = castingTime;
    if (t == null) return '公历：—';
    final mm = t.month.toString().padLeft(2, '0');
    final dd = t.day.toString().padLeft(2, '0');
    final hh = t.hour.toString().padLeft(2, '0');
    final mi = t.minute.toString().padLeft(2, '0');
    return '公历：${t.year}-$mm-$dd $hh:$mi';
  }

  String get _lunar =>
      castingTime == null ? '农历：—' : lunarPlaceholder(castingTime!);

  @override
  Widget build(BuildContext context) {
    final set = castingTime != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('time_row'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: CastingTokens.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CastingTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    '起卦时间',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CastingTokens.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  if (set)
                    const CastingChip(
                      key: Key('time_status_chip'),
                      label: '已完成',
                      background: CastingTokens.completeSurface,
                      border: CastingTokens.completeBorder,
                      width: 62,
                    )
                  else
                    const CastingChip(
                      key: Key('time_status_chip'),
                      label: '待完善',
                      background: CastingTokens.lockedSurface,
                      border: CastingTokens.lockedBorder,
                      width: 62,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _solar,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: set
                      ? CastingTokens.textBody
                      : CastingTokens.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _lunar,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: set
                      ? CastingTokens.textBody
                      : CastingTokens.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
