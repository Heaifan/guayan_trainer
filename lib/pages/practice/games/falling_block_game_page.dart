import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../models/mistake_item.dart';
import '../../../models/practice/practice_answer_record.dart';
import '../../../models/practice/practice_enums.dart';
import '../../../models/practice/practice_question.dart';
import '../../../services/mistake_store.dart';
import '../../../theme/wuxing_colors.dart';
import '../practice_result_page.dart';

/// 单方块速答游戏页面。
///
/// 题目方块从上往下掉，玩家点击底部正确答案。
/// 答对加分 + 连击，答错/漏掉扣生命 + 写入回炉。
class FallingBlockGamePage extends StatefulWidget {
  final Set<PracticeTopic> topics;
  final List<PracticeQuestion> questions;
  final String sessionTitle;

  const FallingBlockGamePage({
    super.key,
    required this.topics,
    required this.questions,
    this.sessionTitle = '综合练习',
  });

  @override
  State<FallingBlockGamePage> createState() => _FallingBlockGamePageState();
}

enum _BlockStatus { falling, feedback }

class _FallingBlockGamePageState extends State<FallingBlockGamePage>
    with SingleTickerProviderStateMixin {
  static const int baseFallMs = 4500;
  static const int minFallMs = 2200;
  static const int speedUpPerFiveComboMs = 250;

  late AnimationController _fallController;

  int _index = 0;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _lives = 3;

  _BlockStatus _status = _BlockStatus.falling;

  late final DateTime _sessionStartedAt;
  late DateTime _questionStartedAt;

  String? _selectedAnswer;
  bool _hasAnswered = false;
  int _lastGained = 0;

  final List<PracticeAnswerRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _sessionStartedAt = DateTime.now();
    _fallController = AnimationController(vsync: this);
    _fallController.addStatusListener(_onFallStatus);
    _startQuestion();
  }

  @override
  void dispose() {
    _fallController.dispose();
    super.dispose();
  }

  PracticeQuestion get _question => widget.questions[_index];

  int _currentFallMs() {
    final speedUp = (_combo ~/ 5) * speedUpPerFiveComboMs;
    return math.max(minFallMs, baseFallMs - speedUp);
  }

  void _onFallStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        _status == _BlockStatus.falling &&
        !_hasAnswered) {
      _timeoutQuestion();
    }
  }

  void _startQuestion() {
    if (_index >= widget.questions.length || _lives <= 0) {
      _finishGame();
      return;
    }
    _questionStartedAt = DateTime.now();
    _selectedAnswer = null;
    _hasAnswered = false;
    _lastGained = 0;
    _status = _BlockStatus.falling;
    _fallController
      ..duration = Duration(milliseconds: _currentFallMs())
      ..reset()
      ..forward();
    setState(() {});
  }

  void _answer(String answer) {
    if (_status != _BlockStatus.falling || _hasAnswered) return;
    _fallController.stop();

    final now = DateTime.now();
    final question = _question;
    final reactionMs = now.difference(_questionStartedAt).inMilliseconds;
    final isCorrect = answer == question.correctAnswer;
    final isHesitant = reactionMs >= 4000;

    final record = PracticeAnswerRecord(
      question: question,
      selectedAnswer: answer,
      isCorrect: isCorrect,
      isTimeout: false,
      isHesitant: isHesitant,
      reactionMs: reactionMs,
      answeredAt: now,
    );
    _records.add(record);

    if (isCorrect) {
      _lastGained = 10 + _combo;
      _score += _lastGained;
      _combo += 1;
      _maxCombo = math.max(_maxCombo, _combo);
    } else {
      _lives -= 1;
      _combo = 0;
      _writeWrong(record);
    }

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;
      _status = _BlockStatus.feedback;
    });

    Future.delayed(
      Duration(milliseconds: isCorrect ? 450 : 900),
      _nextQuestion,
    );
  }

  void _timeoutQuestion() {
    if (_hasAnswered || _status != _BlockStatus.falling) return;

    final question = _question;
    final fallMs = _currentFallMs();

    final record = PracticeAnswerRecord(
      question: question,
      selectedAnswer: null,
      isCorrect: false,
      isTimeout: true,
      isHesitant: false,
      reactionMs: fallMs,
      answeredAt: DateTime.now(),
    );
    _records.add(record);
    _lives -= 1;
    _combo = 0;
    _writeWrong(record);

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = null;
      _status = _BlockStatus.feedback;
    });

    Future.delayed(const Duration(milliseconds: 900), _nextQuestion);
  }

  Future<void> _writeWrong(PracticeAnswerRecord record) async {
    final q = record.question;
    await MistakeStore.instance.addOrUpdateMistake(
      MistakeItem(
        id: q.id,
        module: q.domain.name,
        topic: q.topic.name,
        questionText: q.prompt,
        sourceElement: q.sourceElement ?? '',
        correctAnswer: q.correctAnswer,
        wrongAnswer: record.selectedAnswer ?? '未作答',
        relationText: q.relationText,
        practiceStyle: q.stage.name,
        wrongCount: 1,
        explanation: q.explanation,
        reactionMs: record.reactionMs,
        isHesitant: record.isHesitant,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_lives <= 0 || _index >= widget.questions.length - 1) {
      _finishGame();
      return;
    }
    setState(() => _index += 1);
    _startQuestion();
  }

  void _finishGame() {
    _fallController.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeResultPage(
          sessionTitle: widget.sessionTitle,
          records: _records,
          startedAt: _sessionStartedAt,
          finishedAt: DateTime.now(),
          score: _score,
          maxCombo: _maxCombo,
          remainingLives: _lives,
          mode: PracticeMode.fallingBlock,
        ),
      ),
    );
  }

  // ──────────────── Build ────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('方块速答'), centerTitle: true),
      body: Column(
        children: [
          _hud(),
          Expanded(child: _fallArea()),
          _answerBar(),
        ],
      ),
    );
  }

  Widget _hud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFFFFF4DC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('❤️$_lives',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text('$_score',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text('$_combo',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _combo >= 5 ? const Color(0xFFC0392B) : null)),
          Text('${_index + 1}/${widget.questions.length}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B4E2E))),
        ],
      ),
    );
  }

  Widget _fallArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaHeight = constraints.maxHeight;
        const blockHeight = 82.0;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF5E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFFE0C28A).withValues(alpha: 0.3)),
              ),
            ),
            if (_index < widget.questions.length)
              AnimatedBuilder(
                animation: _fallController,
                builder: (_, __) {
                  final top = lerpDouble(
                    -blockHeight,
                    areaHeight - blockHeight,
                    _fallController.value,
                  )!;
                  return Positioned(
                    left: 24,
                    right: 24,
                    top: top,
                    child: _questionBlock(),
                  );
                },
              ),
            if (_hasAnswered) _feedbackOverlay(),
          ],
        );
      },
    );
  }

  Widget _questionBlock() {
    final question = _question;
    final displayText = question.prompt.replaceFirst('，', '\n');
    final isCorrect = _selectedAnswer == question.correctAnswer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _hasAnswered
              ? (isCorrect
                    ? const Color(0xFF2F6F5E)
                    : const Color(0xFFC0392B))
              : const Color(0xFFE0C28A),
          width: _hasAnswered ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B2A1A).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        displayText,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w900,
            color: Color(0xFF3B2A1A)),
      ),
    );
  }

  Widget _feedbackOverlay() {
    final question = _question;
    final isTimeout = _selectedAnswer == null;
    final isCorrect = !isTimeout && _selectedAnswer == question.correctAnswer;
    return Positioned(
      left: 40,
      right: 40,
      top: 0,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCorrect
              ? const Color(0xFFE9F5EF)
              : const Color(0xFFFFEFEA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCorrect
                ? const Color(0xFF2F6F5E)
                : const Color(0xFFC0392B),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCorrect
                  ? '+$_lastGained'
                  : (isTimeout ? '漏掉' : '回炉'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isCorrect
                    ? const Color(0xFF2F6F5E)
                    : const Color(0xFFC0392B),
              ),
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 4),
              Text('正确：${question.correctAnswer}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: Color(0xFF2F6F5E))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _answerBar() {
    if (_index >= widget.questions.length) return const SizedBox.shrink();
    final question = _question;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF4DC),
        border: Border(top: BorderSide(color: Color(0xFFE0C28A))),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: question.options.map((opt) => _answerButton(opt)).toList(),
      ),
    );
  }

  Widget _answerButton(String opt) {
    final question = _question;
    final isCorrect = opt == question.correctAnswer;
    final isSelected = opt == _selectedAnswer;
    Color? bg;
    Color? fg;
    if (_hasAnswered) {
      if (isCorrect) {
        bg = const Color(0xFF2F6F5E);
        fg = Colors.white;
      } else if (isSelected) {
        bg = const Color(0xFFC0392B);
        fg = Colors.white;
      }
    } else {
      final w = question.answerKind == AnswerKind.wuxingElement &&
              WuxingColors.mainColor.containsKey(opt)
          ? opt
          : null;
      if (w != null) {
        bg = WuxingColors.getSoftColor(w);
        fg = WuxingColors.getColor(w);
      }
    }
    return SizedBox(
      width: opt.length > 1 ? 80 : 64,
      height: 52,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: _hasAnswered && isCorrect
                ? const BorderSide(color: Color(0xFF2F6F5E), width: 2.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: _hasAnswered ? null : () => _answer(opt),
        child: Text(opt,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
