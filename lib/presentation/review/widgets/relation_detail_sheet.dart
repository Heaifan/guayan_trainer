import 'package:flutter/material.dart';

import '../relation_display_model.dart';

class RelationDetailSheet extends StatefulWidget {
  const RelationDetailSheet({
    super.key,
    required this.model,
    this.initialNote = '',
    this.onSaveNote,
  });

  final RelationDisplayModel model;
  final String initialNote;
  final ValueChanged<String>? onSaveNote;

  @override
  State<RelationDetailSheet> createState() => _RelationDetailSheetState();
}

class _RelationDetailSheetState extends State<RelationDetailSheet> {
  late final TextEditingController _noteController = TextEditingController(
    text: widget.initialNote,
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.type.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(model.title, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              _MetaLine(label: '类型', value: model.category),
              _MetaLine(label: '状态', value: model.status),
              const SizedBox(height: 14),
              const Text(
                '派生证据',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              for (final evidence in model.evidence)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '· $evidence',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const SizedBox(height: 14),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '记录你的判断，不由系统自动断卦',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    widget.onSaveNote?.call(_noteController.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text('保存备注'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
