import 'package:flutter/material.dart';

import '../casting_tokens.dart';

/// 问事信息编辑弹层（任务书 §12）。
///
/// 支持主题 / 问事正文 / 对象 / 背景备注四项；
/// 首页摘要只显示标题 + 一行摘要，完整文本在此维护。
class QuestionEditorSheet extends StatefulWidget {
  const QuestionEditorSheet({
    super.key,
    required this.initialTitle,
    required this.initialBody,
    required this.initialObject,
    required this.initialNote,
    required this.onSave,
  });

  final String initialTitle;
  final String initialBody;
  final String initialObject;
  final String initialNote;

  /// 参数顺序：主题 / 正文 / 对象 / 备注。
  final void Function(String, String, String, String) onSave;

  @override
  State<QuestionEditorSheet> createState() => _QuestionEditorSheetState();
}

class _QuestionEditorSheetState extends State<QuestionEditorSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.initialTitle);
  late final TextEditingController _body =
      TextEditingController(text: widget.initialBody);
  late final TextEditingController _object =
      TextEditingController(text: widget.initialObject);
  late final TextEditingController _note =
      TextEditingController(text: widget.initialNote);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _object.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(
      _title.text.trim(),
      _body.text.trim(),
      _object.text.trim(),
      _note.text.trim(),
    );
    Navigator.of(context).pop();
  }

  void _clear() {
    widget.onSave('', '', '', '');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
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
                  '问事信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CastingTokens.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '主题 / 正文 / 对象 / 背景',
                  style: TextStyle(
                    fontSize: 10,
                    color: CastingTokens.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _title,
                  fieldKey: const Key('q_title'),
                  label: '主题',
                  hint: '如：事业发展',
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _body,
                  fieldKey: const Key('q_body'),
                  label: '问事正文',
                  hint: '如：项目推进是否顺利？',
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _object,
                  fieldKey: const Key('q_object'),
                  label: '对象',
                  hint: '如：项目组（可选）',
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _note,
                  fieldKey: const Key('q_note'),
                  label: '背景 / 备注',
                  hint: '补充背景与说明（可选）',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      key: const Key('question_clear'),
                      onPressed: _clear,
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
                      key: const Key('question_save'),
                      label: '保存',
                      onTap: _save,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.fieldKey,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final Key fieldKey;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: CastingTokens.textSecondary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          key: fieldKey,
          controller: controller,
          style: const TextStyle(
            fontSize: 12,
            color: CastingTokens.textPrimary,
            height: 1.2,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 10,
              color: CastingTokens.textMuted,
              height: 1.2,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: CastingTokens.surfaceSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CastingTokens.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CastingTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CastingTokens.borderActive),
            ),
          ),
        ),
      ],
    );
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
