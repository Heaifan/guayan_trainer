import 'package:flutter/material.dart';

import '../casting_page_state.dart';
import '../casting_tokens.dart';

/// 起卦时间编辑弹层（任务书 §11）。
///
/// 本轮实现「日期 + 时间」选择（系统选择器）与时辰自动换算；
/// 完整干支历法引擎不在本轮范围（GAP：年月日干支 / 旬空 / 纳甲）。
class TimeEditorSheet extends StatefulWidget {
  const TimeEditorSheet({
    super.key,
    this.initial,
    this.onSave,
    this.onClear,
  });

  final DateTime? initial;
  final ValueChanged<DateTime>? onSave;
  final VoidCallback? onClear;

  @override
  State<TimeEditorSheet> createState() => _TimeEditorSheetState();
}

class _TimeEditorSheetState extends State<TimeEditorSheet> {
  late DateTime _selected = widget.initial ?? DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selected = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selected.hour,
        _selected.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selected),
    );
    if (picked == null) return;
    setState(() {
      _selected = DateTime(
        _selected.year,
        _selected.month,
        _selected.day,
        picked.hour,
        picked.minute,
      );
    });
  }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '起卦时间',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CastingTokens.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '选择日期与时间，自动换算时辰',
              style: TextStyle(
                fontSize: 10,
                color: CastingTokens.textSecondary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            _SheetRow(
              label: '日期',
              value: _formatDate(_selected),
              onTap: _pickDate,
            ),
            _SheetRow(
              label: '时间',
              value: _formatTime(_selected),
              onTap: _pickTime,
            ),
            _SheetRow(
              label: '时辰',
              value: '${shichenForHour(_selected.hour)}时',
              note: '自动换算',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.onClear != null)
                  TextButton(
                    key: const Key('time_clear'),
                    onPressed: () {
                      widget.onClear!();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '清除',
                      style: TextStyle(
                        fontSize: 12,
                        color: CastingTokens.textSecondary,
                      ),
                    ),
                  ),
                const Spacer(),
                _SaveButton(
                  key: const Key('time_save'),
                  label: '保存',
                  onTap: () {
                    widget.onSave?.call(_selected);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime t) {
    final mm = t.month.toString().padLeft(2, '0');
    final dd = t.day.toString().padLeft(2, '0');
    return '${t.year}-$mm-$dd';
  }

  String _formatTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mi = t.minute.toString().padLeft(2, '0');
    return '$hh:$mi';
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.value,
    this.note,
    this.onTap,
  });

  final String label;
  final String value;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      height: 46,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CastingTokens.divider)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CastingTokens.textSecondary,
              height: 1.2,
            ),
          ),
          const Spacer(),
          if (note != null) ...[
            Text(
              note!,
              style: const TextStyle(
                fontSize: 9,
                color: CastingTokens.textMuted,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CastingTokens.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// XYUI 胶囊保存按钮（浅豆青 Action，非 Material 大按钮）。
class _SaveButton extends StatelessWidget {
  const _SaveButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
          decoration: BoxDecoration(
            color: CastingTokens.accentSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CastingTokens.accentBorder),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CastingTokens.accent,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
