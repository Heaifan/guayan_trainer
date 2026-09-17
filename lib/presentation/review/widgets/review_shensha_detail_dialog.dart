import 'package:flutter/material.dart';

import '../review_page_state.dart';

class ReviewShenShaDetailDialog extends StatefulWidget {
  const ReviewShenShaDetailDialog({super.key, required this.item, this.note});

  final ReviewShenShaItem item;
  final String? note;

  @override
  State<ReviewShenShaDetailDialog> createState() =>
      _ReviewShenShaDetailDialogState();
}

class _ReviewShenShaDetailDialogState extends State<ReviewShenShaDetailDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.note,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item.label),
    content: TextField(
      controller: _controller,
      autofocus: widget.note == null,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: '备注',
        hintText: '请输入备注',
        border: OutlineInputBorder(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text.trim()),
        child: const Text('保存'),
      ),
    ],
  );
}
