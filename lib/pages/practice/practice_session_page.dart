import 'package:flutter/material.dart';

import '../../data/wuxing_self_center_data.dart';
import '../../models/mistake_item.dart';
import '../../models/practice/practice_answer_record.dart';
import '../../models/practice/practice_enums.dart';
import '../../models/practice/practice_question.dart';
import '../../services/mistake_store.dart';
import '../../theme/wuxing_colors.dart';
import 'practice_result_page.dart';

class PracticeSessionPage extends StatefulWidget {
  final Set<PracticeTopic> topics;
  final List<PracticeQuestion> questions;

  const PracticeSessionPage({
    super.key,
    required this.topics,
    required this.questions,
  });

  @override
  State<PracticeSessionPage> createState() => _PracticeSessionPageState();
}

class _PracticeSessionPageState extends State<PracticeSessionPage> {
  int _index = 0;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  DateTime _startedAt = DateTime.now();
  final List<PracticeAnswerRecord> _records = [];

  PracticeQuestion get _current => widget.questions[_index];

  Future<void> _answer(String answer) async {
    if (_hasAnswered) return;
    final now = DateTime.now();
    final ms = now.difference(_startedAt).inMilliseconds;
    final correct = answer == _current.correctAnswer;

    _records.add(PracticeAnswerRecord(
      question: _current,
      selectedAnswer: answer,
      isCorrect: correct,
      isTimeout: ms >= 4000,
      reactionMs: ms,
      answeredAt: now,
    ));

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
    });

    if (!correct) {
      await MistakeStore.instance.addOrUpdateMistake(
        MistakeItem(
          id: _current.id,
          module: _current.domain.name,
          topic: _current.topic.name,
          questionText: _current.prompt,
          sourceElement: _current.sourceElement ?? '',
          correctAnswer: _current.correctAnswer,
          wrongAnswer: answer,
          relationText: _current.relationText,
          practiceStyle: _current.stage.name,
          wrongCount: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  void _next() {
    if (_index >= widget.questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PracticeResultPage(
            records: _records,
            startedAt: _startedAt,
            finishedAt: DateTime.now(),
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _selectedAnswer = null;
      _hasAnswered = false;
      _startedAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = '${_index + 1}/${widget.questions.length}';

    return Scaffold(
      appBar: AppBar(title: const Text('综合练习'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / widget.questions.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight, child: Text(progress)),
            const SizedBox(height: 20),
            _questionCard(),
            const SizedBox(height: 20),
            Expanded(child: _optionsArea()),
            if (_hasAnswered) _feedbackArea(),
          ],
        ),
      ),
    );
  }

  Widget _questionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        children: [
          Text(practiceTopicLabel(_current.topic),
              style: const TextStyle(color: Color(0xFF8A6A3A), fontSize: 13)),
          const SizedBox(height: 10),
          Text(_current.prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF3B2A1A))),
        ],
      ),
    );
  }

  Widget _optionsArea() {
    final opts = _current.options;
    return Center(
      child: Wrap(
        spacing: 12, runSpacing: 14,
        alignment: WrapAlignment.center,
        children: opts.map((opt) {
          final correct = opt == _current.correctAnswer;
          final selected = opt == _selectedAnswer;
          Color? bg;
          Color? fg;
          if (_hasAnswered) {
            if (correct) { bg = const Color(0xFF2F6F5E); fg = Colors.white; }
            else if (selected) { bg = const Color(0xFFC0392B); fg = Colors.white; }
          } else {
            final w = _current.answerKind == AnswerKind.wuxingElement && WuxingColors.mainColor.containsKey(opt)
                ? opt : null;
            if (w != null) { bg = WuxingColors.getSoftColor(w); fg = WuxingColors.getColor(w); }
          }
          return SizedBox(
            width: 64, height: 70,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                  side: _hasAnswered && correct
                      ? const BorderSide(color: Color(0xFF2F6F5E), width: 2.5)
                      : BorderSide.none,
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _answer(opt),
              child: Text(opt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _feedbackArea() {
    final correct = _selectedAnswer == _current.correctAnswer;
    final ms = _records.last.reactionMs;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFE9F5EF) : const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: correct ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(correct ? '正确' : '回炉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: correct ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B))),
          const SizedBox(height: 6),
          if (!correct) ...[
            Text('你选了：$_selectedAnswer', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Text('正确是：${_current.correctAnswer}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2F6F5E))),
          ],
          Text(_current.relationText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          Text(_current.explanation, style: const TextStyle(fontSize: 14, height: 1.4)),
          const SizedBox(height: 4),
          Text('耗时：${(ms / 1000).toStringAsFixed(1)} 秒${ms >= 4000 ? ' ｜ 迟疑' : ''}',
              style: TextStyle(fontSize: 13, color: ms >= 4000 ? const Color(0xFFC0392B) : const Color(0xFF8A6A3A))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _next,
                child: Text(_index >= widget.questions.length - 1 ? '查看结果' : '下一题')),
          ),
        ],
      ),
    );
  }
}
