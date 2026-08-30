import 'package:flutter/material.dart';

import '../../../domain/line_state.dart';
import '../casting_page_state.dart';
import '../casting_tokens.dart';
import 'yao_glyph.dart';

/// 六爻编辑弹层（任务书 §8 / §9）。
///
/// 四种输入语义：少阴（阴·静）/ 少阳（阳·静）/ 老阴（阴·动）/ 老阳（阳·动），
/// 每项以爻矢量图形 + 文案展示，选中项高亮；已录爻可清除。
class LineEditorSheet extends StatelessWidget {
  const LineEditorSheet({
    super.key,
    required this.position,
    this.current,
    this.onSelect,
    this.onClear,
  });

  final int position;
  final LineState? current;
  final ValueChanged<MovementType>? onSelect;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: const BoxDecoration(
          color: CastingTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${linePositionName(position)} · 选择爻象',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CastingTokens.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '少阴 = 阴 · 静    少阳 = 阳 · 静\n老阴 = 阴 · 动    老阳 = 阳 · 动',
                style: TextStyle(
                  fontSize: 10,
                  color: CastingTokens.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3.4,
                children: [
                  for (final type in MovementType.values)
                    _OptionTile(
                      type: type,
                      selected: current?.movementType == type,
                      onTap: () {
                        onSelect?.call(type);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
              if (onClear != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    key: const Key('line_clear'),
                    onPressed: () {
                      onClear!();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '清除此爻',
                      style: TextStyle(
                        fontSize: 12,
                        color: CastingTokens.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final MovementType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('line_opt_${type.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? CastingTokens.accentSurface
                : CastingTokens.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? CastingTokens.accentBorder : CastingTokens.border,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                height: 18,
                child: YaoGlyph(movementType: type),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CastingTokens.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      movementDisplay(type),
                      style: const TextStyle(
                        fontSize: 9,
                        color: CastingTokens.textMuted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
