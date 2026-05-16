import 'package:flutter/material.dart';

import '../../models/mistake_item.dart';
import '../../services/mistake_store.dart';
import '../../theme/wuxing_colors.dart';

/// 回炉重做练习页。
///
/// 所有题目统一使用无色单选（方案 B），答对移出错题库，答错保留。
class ReviewTrainingPage extends StatefulWidget {
  final List<MistakeItem> mistakes;
  final bool isBulk;

  const ReviewTrainingPage({
    super.key,
    required this.mistakes,
    this.isBulk = false,
  });

  @override
  State<ReviewTrainingPage> createState() => _ReviewTrainingPageState();
}

class _ReviewTrainingPageState extends State<ReviewTrainingPage> {
  int _index = 0;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  int _correctCount = 0;
  int _wrongCount = 0;

  static const _allOptions = ['木', '火', '土', '金', '水'];

  MistakeItem get _current => widget.mistakes[_index];

  Future<void> _answer(String answer) async {
    if (_hasAnswered) return;
    final isCorrect = answer == _current.correctAnswer;

    if (isCorrect) {
      await MistakeStore.instance.removeMistake(_current.id);
      _correctCount++;
    } else {
      await MistakeStore.instance.addOrUpdateMistake(
        _current.copyWith(
          wrongAnswer: answer,
          wrongCount: _current.wrongCount + 1,
          practiceStyle: 'textChoice',
          updatedAt: DateTime.now(),
        ),
      );
      _wrongCount++;
    }

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
    });
  }

  void _next() {
    if (_index >= widget.mistakes.length - 1) {
      _showResult();
      return;
    }
    setState(() {
      _index += 1;
      _selectedAnswer = null;
      _hasAnswered = false;
    });
  }

  void _showResult() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isBulk
              ? '回炉完成：对了 $_correctCount 题，错了 $_wrongCount 题'
              : '回炉完成',
        ),
        backgroundColor: _wrongCount == 0
            ? const Color(0xFF2F6F5E)
            : const Color(0xFFB9770E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index >= widget.mistakes.length - 1;
    final progress =
        '${_index + 1}/${widget.mistakes.length}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('回炉重做'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.isBulk) ...[
              LinearProgressIndicator(
                value: (_index + 1) / widget.mistakes.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(99),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(progress),
              ),
              const SizedBox(height: 16),
            ],
            _questionCard(),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: _allOptions.map((opt) {
                    final isSelected = _selectedAnswer == opt;
                    final isCorrect = opt == _current.correctAnswer;

                    Color? bg;
                    Color? fg;
                    Color borderColor = const Color(0xFFE0C28A);
                    double borderWidth = 1.5;

                    if (_hasAnswered) {
                      if (isCorrect) {
                        bg = const Color(0xFF2F6F5E);
                        fg = Colors.white;
                        borderColor = const Color(0xFF2F6F5E);
                        borderWidth = 2.5;
                      } else if (isSelected) {
                        bg = const Color(0xFFC0392B);
                        fg = Colors.white;
                      }
                    }

                    return SizedBox(
                      width: 64,
                      height: 80,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: bg,
                          foregroundColor: fg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: borderColor, width: borderWidth),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => _answer(opt),
                        child: Text(opt,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (_hasAnswered) _feedbackArea(isLast),
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
          const Text('请判断',
              style: TextStyle(color: Color(0xFF8A6A3A), fontSize: 14)),
          const SizedBox(height: 12),
          Text(
            _current.questionText,
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

  Widget _feedbackArea(bool isLast) {
    final isCorrect = _selectedAnswer == _current.correctAnswer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFFE9F5EF)
            : const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? '正确' : '仍需回炉',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isCorrect
                  ? const Color(0xFF2F6F5E)
                  : const Color(0xFFC0392B),
            ),
          ),
          const SizedBox(height: 6),
          if (!isCorrect) ...[
            Text('你选了：$_selectedAnswer',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            Text('正确是：${_current.correctAnswer}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F6F5E))),
            const SizedBox(height: 4),
          ],
          Text(
            isCorrect ? '已移出回炉。' : '${_current.relationText}。',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLast ? _showResult : _next,
              child: Text(isLast && widget.isBulk ? '查看结果' : '下一题'),
            ),
          ),
        ],
      ),
    );
  }
}
