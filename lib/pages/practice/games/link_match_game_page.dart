import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../data/wuxing_data.dart';
import '../../../models/mistake_item.dart';
import '../../../models/practice/practice_answer_record.dart';
import '../../../models/practice/practice_enums.dart';
import '../../../models/practice/practice_question.dart';
import '../../../services/mistake_store.dart';
import '../../../theme/wuxing_colors.dart';
import '../practice_result_page.dart';

/// 关系连连看 — 25 组配对 / 50 张卡牌消除版。
class LinkMatchGamePage extends StatefulWidget {
  final PracticeTopic topic;
  final List<PracticeQuestion> questions;
  final String sessionTitle;

  const LinkMatchGamePage({
    super.key,
    required this.topic,
    required this.questions,
    this.sessionTitle = '关系连连看',
  });

  @override
  State<LinkMatchGamePage> createState() => _LinkMatchGamePageState();
}

class _CardData {
  final int id;
  final String element;
  bool matched = false;

  _CardData({required this.id, required this.element});
}

class _LinkMatchGamePageState extends State<LinkMatchGamePage> {
  static const int lifeCount = 5;

  late final List<_CardData> _sources;
  late final List<_CardData> _answers;

  int? _selectedId;
  bool _feedbackVisible = false;
  String _feedbackText = '';
  bool _feedbackCorrect = false;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _lives = lifeCount;
  final List<PracticeAnswerRecord> _records = [];

  late final DateTime _sessionStartedAt;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _sessionStartedAt = DateTime.now();

    _sources = List.generate(
      widget.questions.length,
      (i) => _CardData(id: i, element: widget.questions[i].sourceElement ?? ''),
    )..shuffle();

    _answers = List.generate(
      widget.questions.length,
      (i) => _CardData(id: i, element: widget.questions[i].correctAnswer),
    )..shuffle();
  }

  bool get _isBreak => widget.topic == PracticeTopic.wuxingControl;

  String _correctAnswerFor(String el) {
    if (widget.topic == PracticeTopic.wuxingGenerate) return WuxingData.generates[el]!;
    return WuxingData.controls[el]!;
  }

  int get _matchedCount => _sources.where((c) => c.matched).length;
  int get _totalPairs => widget.questions.length;

  // ──────────────── 交互 ────────────────

  void _selectSource(int id) {
    if (_gameOver || _sources[id].matched) return;
    setState(() => _selectedId = id);
  }

  void _selectAnswer(int answerId) {
    if (_gameOver || _selectedId == null) return;
    final source = _sources[_selectedId!];
    final answer = _answers[answerId];
    if (source.matched || answer.matched) return;

    final sourceEl = source.element;
    final answerEl = answer.element;
    final correct = answerEl == _correctAnswerFor(sourceEl);

    final now = DateTime.now();
    _records.add(PracticeAnswerRecord(
      question: PracticeQuestion(
        id: 'linkmatch_${source.id}_$answerId',
        domain: PracticeDomain.wuxing,
        topic: widget.topic,
        stage: PracticeStage.linkMatch,
        answerKind: AnswerKind.wuxingElement,
        prompt: '$sourceEl ${_isBreak ? "克" : "生"}谁？',
        options: List.from(WuxingData.elements),
        correctAnswer: _correctAnswerFor(sourceEl),
        sourceElement: sourceEl,
        relationText: _isBreak ? '$sourceEl克$answerEl' : '$sourceEl生$answerEl',
        explanation: _isBreak ? '$sourceEl 克 ${_correctAnswerFor(sourceEl)}。' : '$sourceEl 生 ${_correctAnswerFor(sourceEl)}。',
      ),
      selectedAnswer: answerEl,
      isCorrect: correct,
      isTimeout: false,
      isHesitant: false,
      reactionMs: 0,
      answeredAt: now,
    ));

    if (correct) {
      source.matched = true;
      answer.matched = true;
      _score += 10 + _combo;
      _combo += 1;
      _maxCombo = math.max(_maxCombo, _combo);

      setState(() {
        _selectedId = null;
        _feedbackText = _isBreak ? '$sourceEl克$answerEl' : '$sourceEl生$answerEl';
        _feedbackCorrect = true;
        _feedbackVisible = true;
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _feedbackVisible = false);
      });

      if (_matchedCount >= _totalPairs) {
        Future.delayed(const Duration(milliseconds: 700), _finishGame);
      }
    } else {
      _lives -= 1;
      _combo = 0;

      final correctAns = _correctAnswerFor(sourceEl);
      MistakeStore.instance.addOrUpdateMistake(MistakeItem(
        id: 'linkmatch_${source.id}_$answerId',
        module: PracticeDomain.wuxing.name,
        topic: widget.topic.name,
        questionText: '$sourceEl ${_isBreak ? "克" : "生"}谁？',
        sourceElement: sourceEl,
        correctAnswer: correctAns,
        wrongAnswer: answerEl,
        relationText: _isBreak ? '$sourceEl克$correctAns' : '$sourceEl生$correctAns',
        practiceStyle: PracticeMode.linkMatch.name,
        wrongCount: 1,
        explanation: '',
        reactionMs: 0,
        isHesitant: false,
        createdAt: now,
        updatedAt: now,
      ));

      setState(() {
        _selectedId = null;
        _feedbackText = '正确：$correctAns    ${_isBreak ? "$sourceEl克$correctAns" : "$sourceEl生$correctAns"}';
        _feedbackCorrect = false;
        _feedbackVisible = true;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _feedbackVisible = false);
        if (_lives <= 0) _finishGame();
      });
    }
  }

  void _finishGame() {
    if (_gameOver) return;
    _gameOver = true;
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
          remainingLives: math.max(0, _lives),
          matchedCount: _matchedCount,
          totalPairs: _totalPairs,
          mode: PracticeMode.linkMatch,
        ),
      ),
    );
  }

  // ──────────────── 构建 ────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关系连连看'), centerTitle: true),
      body: Column(
        children: [
          _hud(),
          _ruleBar(),
          Expanded(child: _gameArea()),
        ],
      ),
    );
  }

  Widget _hud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      color: const Color(0xFFFFF4DC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('❤️$_lives', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          Text('$_score', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          Text('🔥$_combo', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: _combo >= 3 ? const Color(0xFFC0392B) : null,
          )),
          Text('$_matchedCount/$_totalPairs',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B4E2E))),
        ],
      ),
    );
  }

  Widget _ruleBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: _isBreak ? const Color(0xFFFFEFEA) : const Color(0xFFE9F5EF),
      child: Text(
        _isBreak ? '五行相克：点击源牌，再点击它所克的牌。' : '五行相生：点击源牌，再点击它所生的牌。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: _isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E),
        ),
      ),
    );
  }

  Widget _gameArea() {
    return Column(
      children: [
        _sectionLabel('源牌 — 点击一张'),
        Expanded(flex: 4, child: _cardList(_sources, isSource: true)),
        _feedbackBar(),
        _sectionLabel('目标牌 — 点击配对的'),
        Expanded(flex: 4, child: _cardList(_answers, isSource: false)),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B4E2E))),
    );
  }

  Widget _cardList(List<_CardData> cards, {required bool isSource}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 6, runSpacing: 6,
        alignment: WrapAlignment.center,
        children: cards.map((c) {
          if (c.matched) return const SizedBox(width: 44, height: 44);
          return _card(c, isSource: isSource);
        }).toList(),
      ),
    );
  }

  Widget _card(_CardData card, {required bool isSource}) {
    final isSelected = isSource && _selectedId == card.id;
    final elColor = WuxingColors.getColor(card.element);

    return GestureDetector(
      onTap: _gameOver ? null : () {
        if (isSource) _selectSource(card.id);
        else _selectAnswer(card.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? elColor.withValues(alpha: 0.3)
              : WuxingColors.getSoftColor(card.element),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? elColor : elColor.withValues(alpha: 0.3),
            width: isSelected ? 2.5 : 1.2,
          ),
        ),
        child: Center(
          child: Text(card.element, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900,
            color: isSelected ? elColor : elColor.withValues(alpha: 0.7),
          )),
        ),
      ),
    );
  }

  Widget _feedbackBar() {
    const height = 36.0;
    if (!_feedbackVisible && _selectedId == null) {
      return SizedBox(height: height,
        child: Center(child: Text('点击上方源牌开始配对',
            style: TextStyle(fontSize: 12, color: Color(0xFFB8A98A)))),
      );
    }
    if (!_feedbackVisible && _selectedId != null) {
      final el = _sources[_selectedId!].element;
      return SizedBox(
        height: height,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: WuxingColors.getColor(el).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('已选 $el',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: WuxingColors.getColor(el))),
              ),
              const SizedBox(width: 6),
              const Text('→ 点下方目标',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B4E2E))),
            ],
          ),
        ),
      );
    }
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _feedbackCorrect
            ? (_isBreak ? const Color(0xFFFFF0E8) : const Color(0xFFE9F5EF))
            : const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _feedbackCorrect
              ? (_isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E))
              : const Color(0xFFC0392B),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_feedbackCorrect) Text(_isBreak ? '⚡' : '❤️', style: const TextStyle(fontSize: 16)),
          if (!_feedbackCorrect) const Text('✗ ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFC0392B))),
          const SizedBox(width: 4),
          Flexible(
            child: Text(_feedbackText,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: _feedbackCorrect
                      ? (_isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E))
                      : const Color(0xFFC0392B),
                ),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
