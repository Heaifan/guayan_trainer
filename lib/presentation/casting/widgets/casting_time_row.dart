import 'package:flutter/material.dart';

import '../casting_page_state.dart';
import '../casting_tokens.dart';
import 'casting_chip.dart';

/// 起卦时间 · 第一行（任务书 §5.3 + §11）。
///
/// 整行可点击进入时间编辑；未设置时显示占位并标记「待完善」。
class CastingTimeRow extends StatelessWidget {
  const CastingTimeRow({super.key, required this.castingTime, this.onTap});

  final DateTime? castingTime;
  final VoidCallback? onTap;

  String get _value {
    final t = castingTime;
    if (t == null) return '尚未选择起卦时间';
    final mm = t.month.toString().padLeft(2, '0');
    final dd = t.day.toString().padLeft(2, '0');
    return '${t.year}-$mm-$dd · ${shichenForHour(t.hour)}时';
  }

  @override
  Widget build(BuildContext context) {
    final set = castingTime != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('time_row'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: CastingTokens.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CastingTokens.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 5),
                    Text(
                      _value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: set
                            ? CastingTokens.textBody
                            : CastingTokens.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
        ),
      ),
    );
  }
}
