import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../casting_page_state.dart';
import '../casting_tokens.dart';
import 'casting_chip.dart';
import 'yao_glyph.dart';

/// 六爻录入单行（任务书 §5.5 / §8 / §9）。
///
/// - 已录：爻矢量图形 + 「阴阳 · 动静」文案 + 已录标记；
/// - 待录：占位 chip「点击录入X爻」+ 待录标记；
/// - 当前编辑爻（[editing]）：浅豆青选中背景 + 明显边框 + 编辑徽标。
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

  static const double _labelWidth = 44;
  static const double _statusWidth = 56;
  static const double _trailingWidth = 36;

  @override
  Widget build(BuildContext context) {
    final label = linePositionName(position);
    if (editing) {
      return _editingRow(
        position: position,
        label: label,
        line: line,
        onTap: onTap,
      );
    }
    return _normalRow(
      position: position,
      label: label,
      line: line,
      onTap: onTap,
    );
  }

  /// 普通行：高 44。
  Widget _normalRow({
    required int position,
    required String label,
    required LineState? line,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(width: 22),
              SizedBox(
                width: _labelWidth,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: CastingTokens.textMuted,
                    height: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: line == null
                      ? _PlaceholderChip(label: label)
                      : YaoGlyph(movementType: line.movementType),
                ),
              ),
              SizedBox(
                width: _statusWidth,
                child: Text(
                  line == null ? '' : lineStatusText(line),
                  key: Key('yao_status_$position'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CastingTokens.textBody,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(
                width: _trailingWidth,
                child: Text(
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

  /// 当前编辑行：高 56，浅豆青背景 + 更明显边框 + 编辑徽标。
  Widget _editingRow({
    required int position,
    required String label,
    required LineState? line,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: CastingTokens.editSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CastingTokens.editBorder),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: _labelWidth + 12,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CastingTokens.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: line == null
                        ? _PlaceholderChip(label: label)
                        : YaoGlyph(movementType: line.movementType),
                  ),
                ),
                SizedBox(
                  width: _statusWidth,
                  child: Text(
                    line == null ? '' : lineStatusText(line),
                    key: Key('yao_status_$position'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CastingTokens.accent,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                CastingChip(
                  key: Key('yao_edit_badge_$position'),
                  label: '编辑',
                  background: CastingTokens.accentSurface,
                  border: CastingTokens.accentBorder,
                  width: 42,
                  fontSize: 9,
                ),
              ],
            ),
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
