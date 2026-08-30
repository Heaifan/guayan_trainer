import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../../../presentation/shared/yao_glyph.dart';
import '../casting_page_state.dart';
import '../casting_tokens.dart';
import 'casting_chip.dart';

/// 六爻录入单行（UI-CORRECTION-R2 §3：普通行 = 编辑行 = 52 DIP）。
///
/// 六个爻位必须同一行高、同一内容布局、同一爻槽尺寸。
/// 编辑态只允许变化：背景、边框、文字 Weight、编辑 Badge；
/// 不得变化行高 / 爻象尺寸 / 左右 padding / 文字基线。
/// 爻象统一使用共享 [YaoGlyph]（24×6 冻结槽位）。
class SixYaoInputRow extends StatelessWidget {
  const SixYaoInputRow({
    super.key,
    required this.position,
    required this.line,
    required this.editing,
    required this.onTap,
  });

  final int position;
  final LineState? line;
  final bool editing;
  final VoidCallback onTap;

  static const double _rowHeight = 52;
  static const double _labelWidth = 44;
  static const double _statusWidth = 56;
  static const double _trailingWidth = 42;

  @override
  Widget build(BuildContext context) {
    final label = linePositionName(position);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: _rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: editing ? CastingTokens.editSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: editing
                ? Border.all(color: CastingTokens.editBorder)
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: _labelWidth,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: editing ? 12 : 9,
                    fontWeight:
                        editing ? FontWeight.w700 : FontWeight.w400,
                    color: editing
                        ? CastingTokens.textPrimary
                        : CastingTokens.textMuted,
                    height: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: line == null
                      ? _PlaceholderChip(label: label)
                      : YaoGlyph.fromMovement(line!.movementType),
                ),
              ),
              SizedBox(
                width: _statusWidth,
                child: Text(
                  line == null ? '' : lineStatusText(line!),
                  key: Key('yao_status_$position'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        editing ? FontWeight.w700 : FontWeight.w400,
                    color: editing
                        ? CastingTokens.accent
                        : CastingTokens.textBody,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(
                width: _trailingWidth,
                child: editing
                    ? CastingChip(
                        key: Key('yao_edit_badge_$position'),
                        label: '编辑',
                        background: CastingTokens.accentSurface,
                        border: CastingTokens.accentBorder,
                        width: 42,
                        fontSize: 9,
                      )
                    : Text(
                        line == null ? '待录' : '已录',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 9,
                          color: CastingTokens.textMuted,
                          height: 1.2,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 待录占位 chip（任务书 SVG：rx 8 占位块「点击录入X爻」）。
class _PlaceholderChip extends StatelessWidget {
  const _PlaceholderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CastingTokens.chipSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CastingTokens.chipBorder),
      ),
      child: Text(
        '点击录入$label',
        style: const TextStyle(
          fontSize: 10,
          color: CastingTokens.textSecondary,
          height: 1.2,
        ),
      ),
    );
  }
}
