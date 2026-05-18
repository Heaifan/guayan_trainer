import 'package:flutter/material.dart';

import '../../data/practice/wuxing_practice_question_generator.dart';
import '../../models/practice/practice_enums.dart';
import '../../theme/wuxing_colors.dart';
import '../../utils/practice_labels.dart';
import 'practice_session_page.dart';

class PracticeSetupPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final Set<PracticeTopic> initialTopics;
  final int initialQuestionCount;
  final String? recommendationText;
  final String? sessionTitle;

  const PracticeSetupPage({
    super.key,
    this.title = '综合练习',
    this.subtitle = '选择要训练的知识点，可单选或混合练习。',
    this.initialTopics = const {
      PracticeTopic.wuxingGenerate,
      PracticeTopic.wuxingControl,
    },
    this.initialQuestionCount = 12,
    this.recommendationText,
    this.sessionTitle,
  });

  @override
  State<PracticeSetupPage> createState() => _PracticeSetupPageState();
}

class _PracticeSetupPageState extends State<PracticeSetupPage> {
  late Set<PracticeTopic> _selected;
  late int _questionCount;

  static const _allTopics = PracticeTopic.values;
  static const _countOptions = [10, 12, 20];

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialTopics);
    _questionCount = widget.initialQuestionCount;
  }

  void _toggle(PracticeTopic topic) {
    setState(() {
      if (_selected.contains(topic)) {
        _selected.remove(topic);
      } else {
        _selected.add(topic);
      }
    });
  }

  void _start() {
    if (_selected.isEmpty) return;
    final questions = WuxingPracticeQuestionGenerator().generate(
      topics: _selected,
      count: _questionCount,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticeSessionPage(
          sessionTitle: widget.sessionTitle ?? widget.title,
          topics: _selected,
          questions: questions,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0C28A)),
            ),
            child: Text(widget.subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B4E2E))),
          ),
          if (widget.recommendationText != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F5EF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2F6F5E).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFF2F6F5E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.recommendationText!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2F6F5E))),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text('选择练习内容',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ..._allTopics.map((t) => CheckboxListTile(
                title: Text('${practiceTopicLabel(t)}（${practicePoolSize(t)}题）'),
                value: _selected.contains(t),
                onChanged: (_) => _toggle(t),
                activeColor: const Color(0xFF2F6F5E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _selected.contains(t) ? const Color(0xFF2F6F5E) : const Color(0xFFE0C28A),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              )),
          const SizedBox(height: 20),
          const Text('题数',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: _countOptions.map((n) {
              final sel = n == _questionCount;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text('$n 题'),
                  selected: sel,
                  onSelected: (_) => setState(() => _questionCount = n),
                  selectedColor: const Color(0xFF2F6F5E),
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selected.isEmpty ? null : _start,
              child: const Text('开始练习'),
            ),
          ),
        ],
      ),
    );
  }
}
