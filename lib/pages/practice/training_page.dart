import 'package:flutter/material.dart';

import '../../models/training_question.dart';
import '../../models/training_result.dart';
import '../../services/mistake_store.dart';
import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../../widgets/wuxing_wheel.dart';
import 'result_page.dart';

class TrainingPage extends StatefulWidget {
  final String title;
  final TrainingMode mode;

  const TrainingPage({
    super.key,
    required this.title,
    required this.mode,
  });

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final QuestionGenerator _generator = QuestionGenerator();

  late final List<TrainingQuestion> _questions;
  final List<QuestionAnswerResult> _results = [];

  int _index = 0;
  DateTime _questionStartTime = DateTime.now();

  String? _selectedAnswer;
  bool _hasAnswered = false;

  TrainingQuestion get _current => _questions[_index];

  @override
  void initState() {
    super.initState();
    _questions = _generator.generateSession(
      mode: widget.mode,
      count: 10,
    );
    _questionStartTime = DateTime.now();
  }

  void _answer(String answer) {
    if (_hasAnswered) return;

    final used = DateTime.now().difference(_questionStartTime).inMilliseconds;
    final isCorrect = answer == _current.correctAnswer;

    final result = QuestionAnswerResult(
      question: _current,
      selectedAnswer: answer,
      isCorrect: isCorrect,
      milliseconds: used,
    );

    _results.add(result);

    if (!isCorrect) {
      MistakeStore.instance.markWrong(
        knowledgeKey: _current.knowledgeKey,
        explanation: _current.explanation,
      );
    } else if (used >= 4000) {
      MistakeStore.instance.markSlow(
        knowledgeKey: _current.knowledgeKey,
        explanation: _current.explanation,
      );
    }

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
    });
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultPage(
            result: TrainingSessionResult(_results),
          ),
        ),
      );
      return;
    }

    setState(() {
      _index += 1;
      _selectedAnswer = null;
      _hasAnswered = false;
      _questionStartTime = DateTime.now();
    });
  }

  Color? _optionBg(String option) {
    if (!_hasAnswered) {
      final wuxing = WuxingColors.mainColor.containsKey(option)
          ? option
          : WuxingColors.getWuxingByBranch(option);
      if (wuxing != null) {
        return WuxingColors.getSoftColor(wuxing);
      }
      return null;
    }

    if (option == _current.correctAnswer) return WuxingColors.getColor(option);
    if (option == _selectedAnswer) return const Color(0xFFC0392B);
    return null;
  }

  Color? _optionFg(String option) {
    if (!_hasAnswered) return null;
    if (option == _current.correctAnswer) return Colors.white;
    if (option == _selectedAnswer) return Colors.white;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final progress = '${_index + 1}/${_questions.length}';
    final useWheel = widget.mode == TrainingMode.wuxing ||
        widget.mode == TrainingMode.wuxingGenerate;
    final showArrow = widget.mode == TrainingMode.wuxingGenerate;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(progress),
            ),
            const SizedBox(height: 24),
            _questionCard(),
            const SizedBox(height: 20),
            if (useWheel)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: WuxingWheel(
                        selected: _selectedAnswer,
                        correctAnswer: _current.correctAnswer,
                        hasAnswered: _hasAnswered,
                        sourceElement: _current.sourceElement,
                        showArrow: showArrow,
                        showEffect: showArrow,
                        onTap: _answer,
                      ),
                    ),
                    if (!_hasAnswered)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          '根据五行关系，点击答案',
                          style: TextStyle(
                            color: Color(0xFF8A6A3A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _current.options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final option = _current.options[i];
                    return _answerButton(option);
                  },
                ),
              ),
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
          const Text(
            '请判断',
            style: TextStyle(color: Color(0xFF8A6A3A), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            _current.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3B2A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerButton(String option) {
    final bg = _optionBg(option);
    final fg = _optionFg(option);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _answer(option),
        child: Text(
          option,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _feedbackArea() {
    final isCorrect = _selectedAnswer == _current.correctAnswer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFE9F5EF) : const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? '正确' : '回炉',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isCorrect ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B),
            ),
          ),
          const SizedBox(height: 8),
          if (!isCorrect)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('你选了$_selectedAnswer。 正确是：${_current.correctAnswer}。',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          Text(
            _current.explanation,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _next,
              child: Text(_index >= _questions.length - 1 ? '查看结果' : '下一题'),
            ),
          ),
        ],
      ),
    );
  }
}
