import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../../../data/practice/wuxing_practice_question_generator.dart';
import '../../../models/mistake_item.dart';
import '../../../models/practice/practice_answer_record.dart';
import '../../../models/practice/practice_enums.dart';
import '../../../models/practice/practice_question.dart';
import '../../../services/mistake_store.dart';
import '../../../theme/wuxing_colors.dart';
import '../practice_result_page.dart';

/// 随机自由下落打飞模式。
class FallingBlockGamePage extends StatefulWidget {
  final PracticeTopic topic;
  final List<PracticeQuestion> questions;
  final String sessionTitle;
  final bool isInfinite;

  const FallingBlockGamePage({
    super.key,
    required this.topic,
    required this.questions,
    this.sessionTitle = '综合练习',
    this.isInfinite = false,
  });

  @override
  State<FallingBlockGamePage> createState() => _FallingBlockGamePageState();
}

enum _BlockState { falling, heartHit, breakHit, missed }

class _Block {
  final String source;
  final String answer;
  final PracticeQuestion question;
  final double x;
  final int fallMs;
  final HitEffectKind effectKind;
  final DateTime spawnedAt;
  _BlockState state = _BlockState.falling;
  DateTime? resolvedAt;

  _Block({
    required this.source,
    required this.answer,
    required this.question,
    required this.x,
    required this.fallMs,
    required this.effectKind,
    required this.spawnedAt,
  });
}

class _FallingBlockGamePageState extends State<FallingBlockGamePage>
    with SingleTickerProviderStateMixin {
  static const int blockSize = 70;
  static const _elements = ['木', '火', '土', '金', '水'];

  final math.Random _random = math.Random();
  final WuxingPracticeQuestionGenerator _generator = WuxingPracticeQuestionGenerator();
  final List<_Block> _blocks = [];
  final List<PracticeAnswerRecord> _records = [];

  int _nextQuestionIndex = 0;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _lives = 3;
  int _totalCorrect = 0;
  int _emptyHits = 0;

  late final DateTime _sessionStartedAt;
  Ticker? _ticker;
  DateTime _lastSpawnTime = DateTime.now();
  bool _gameRunning = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _sessionStartedAt = DateTime.now();
    _startGame();
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    super.dispose();
  }

  HitEffectKind get _effectKind => widget.topic == PracticeTopic.wuxingControl
      ? HitEffectKind.break_ : HitEffectKind.heart;

  bool get _isBreak => _effectKind == HitEffectKind.break_;

  String get _ruleText {
    switch (widget.topic) {
      case PracticeTopic.wuxingGenerate: return '相生 · 点它生的元素';
      case PracticeTopic.wuxingControl: return '相克 · 点它克的元素';
      default: return '';
    }
  }

  int get _level => _totalCorrect ~/ 8;

  int _currentFallMs() {
    final base = math.max(2300, 5200 - _level * 220);
    return base + _random.nextInt(500) - 250;
  }

  int _currentSpawnMs() => math.max(650, 1600 - _level * 90);

  int _currentMaxBlocks() => math.min(6, 3 + _level ~/ 3);

  // ──────────────── Game loop ────────────────

  void _startGame() {
    _gameRunning = true;
    _lastSpawnTime = DateTime.now();
    _spawnBlock();
    _ticker = createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration _) {
    if (!_gameRunning || _gameOver || !mounted) return;
    final now = DateTime.now();

    // — spawn —
    if (_canSpawnMore && now.difference(_lastSpawnTime).inMilliseconds >= _currentSpawnMs()) {
      _spawnBlock();
    }

    // — misses —
    for (final b in _blocks.where((b) => b.state == _BlockState.falling)) {
      if (now.difference(b.spawnedAt).inMilliseconds >= b.fallMs) {
        _missBlock(b, now);
      }
    }

    // — game over —
    if (_lives <= 0) { _endGame(); return; }
    if (!widget.isInfinite && _noMoreQuestions && _blocks.every((b) => b.state != _BlockState.falling)) {
      _endGame(); return;
    }

    if (_blocks.any((b) => b.state == _BlockState.falling)) {
      setState(() {});
    }
  }

  bool get _canSpawnMore {
    if (_gameOver || !_gameRunning) return false;
    final active = _blocks.where((b) => b.state == _BlockState.falling).length;
    if (active >= _currentMaxBlocks()) return false;
    if (widget.isInfinite) return true;
    return _nextQuestionIndex < widget.questions.length;
  }

  bool get _noMoreQuestions => !widget.isInfinite && _nextQuestionIndex >= widget.questions.length;

  PracticeQuestion _nextQuestion() {
    if (widget.isInfinite && _nextQuestionIndex >= widget.questions.length) {
      return _generator.generate(topics: {widget.topic}, count: 1).first;
    }
    return widget.questions[_nextQuestionIndex % widget.questions.length];
  }

  void _spawnBlock() {
    if (!_canSpawnMore) return;
    final q = _nextQuestion();
    _nextQuestionIndex++;
    _blocks.add(_Block(
      source: q.sourceElement ?? '',
      answer: q.correctAnswer,
      question: q,
      x: 0.08 + _random.nextDouble() * 0.84,
      fallMs: _currentFallMs(),
      effectKind: _effectKind,
      spawnedAt: DateTime.now(),
    ));
    _lastSpawnTime = DateTime.now();
  }

  // ──────────────── Input ────────────────

  void _tapAnswer(String answer) {
    if (_gameOver || !_gameRunning) return;

    // Find the closest-to-bottom block whose correct answer matches
    _Block? target;
    double maxProgress = -1;
    for (final b in _blocks.where((b) => b.state == _BlockState.falling && b.answer == answer)) {
      final p = DateTime.now().difference(b.spawnedAt).inMilliseconds / b.fallMs;
      if (p > maxProgress) { maxProgress = p; target = b; }
    }

    if (target == null) {
      // Empty hit — no matching block on screen
      _lives -= 1;
      _combo = 0;
      _emptyHits++;
      setState(() {});
      return;
    }

    // Hit!
    final now = DateTime.now();
    final ms = now.difference(target.spawnedAt).inMilliseconds;
    target.state = _effectKind == HitEffectKind.heart ? _BlockState.heartHit : _BlockState.breakHit;
    target.resolvedAt = now;

    _records.add(PracticeAnswerRecord(
      question: target.question,
      selectedAnswer: answer,
      isCorrect: true,
      isTimeout: false,
      isHesitant: ms >= 4000,
      reactionMs: ms,
      answeredAt: now,
    ));

    final gained = 10 + _combo;
    _score += gained;
    _combo += 1;
    _maxCombo = math.max(_maxCombo, _combo);
    _totalCorrect += 1;
    target.question; // keep ref

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _blocks.remove(target));
    });

    setState(() {});
  }

  void _missBlock(_Block b, DateTime now) {
    b.state = _BlockState.missed;
    b.resolvedAt = now;
    _lives -= 1;
    _combo = 0;

    _records.add(PracticeAnswerRecord(
      question: b.question,
      selectedAnswer: null,
      isCorrect: false,
      isTimeout: true,
      isHesitant: false,
      reactionMs: b.fallMs,
      answeredAt: now,
    ));

    MistakeStore.instance.addOrUpdateMistake(MistakeItem(
      id: b.question.id,
      module: b.question.domain.name,
      topic: b.question.topic.name,
      questionText: b.question.prompt,
      sourceElement: b.question.sourceElement ?? '',
      correctAnswer: b.question.correctAnswer,
      wrongAnswer: '未作答',
      relationText: b.question.relationText,
      practiceStyle: b.question.stage.name,
      wrongCount: 1,
      explanation: b.question.explanation,
      reactionMs: b.fallMs,
      isHesitant: false,
      createdAt: now,
      updatedAt: now,
    ));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _blocks.remove(b));
    });
  }

  void _endGame() {
    if (_gameOver) return;
    _gameOver = true;
    _gameRunning = false;
    _ticker?.stop();

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
          mode: PracticeMode.fallingBlock,
          emptyHits: _emptyHits,
        ),
      ),
    );
  }

  // ──────────────── Build ────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sessionTitle), centerTitle: true),
      body: Column(
        children: [
          _ruleBar(),
          _hud(),
          Expanded(child: _fallArea()),
          _answerBar(),
        ],
      ),
    );
  }

  Widget _ruleBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      color: _isBreak ? const Color(0xFFFFEFEA) : const Color(0xFFE9F5EF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_ruleText, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: _isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E),
          )),
          Text('Lv$_level', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: _isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E),
          )),
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
            color: _combo >= 5 ? const Color(0xFFC0392B) : null,
          )),
          Text(widget.isInfinite ? '∞' : '${_nextQuestionIndex}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B4E2E))),
        ],
      ),
    );
  }

  Widget _fallArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaH = constraints.maxHeight;
        final areaW = constraints.maxWidth;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF5E6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0C28A).withValues(alpha: 0.25)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                for (final b in _blocks)
                  Positioned(
                      left: b.x * (areaW - blockSize),
                      top: _blockTop(b, areaH),
                      child: _blockWidget(b),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _blockTop(_Block b, double areaH) {
    final elapsed = DateTime.now().difference(b.spawnedAt).inMilliseconds;
    final p = (elapsed / b.fallMs).clamp(0.0, 1.0);
    return lerpDouble(-blockSize.toDouble(), areaH, p)!;
  }

  Widget _blockWidget(_Block b) {
    if (b.state == _BlockState.heartHit) {
      return Container(
        width: blockSize.toDouble(), height: blockSize.toDouble(),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F5EF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2F6F5E), width: 2.5),
        ),
        child: const Center(child: Text('❤️', style: TextStyle(fontSize: 28))),
      );
    }
    if (b.state == _BlockState.breakHit) {
      return Container(
        width: blockSize.toDouble(), height: blockSize.toDouble(),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF9C3B2E), width: 2.5),
        ),
        child: const Center(child: Text('💥', style: TextStyle(fontSize: 28))),
      );
    }
    if (b.state == _BlockState.missed) {
      return Container(
        width: blockSize.toDouble(), height: blockSize.toDouble(),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEFEA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC0392B), width: 2),
        ),
        child: Center(child: Text(b.source, style: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFFC0392B),
        ))),
      );
    }
    return Container(
      width: blockSize.toDouble(), height: blockSize.toDouble(),
      decoration: BoxDecoration(
        color: WuxingColors.getSoftColor(b.source),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WuxingColors.getColor(b.source), width: 2),
        boxShadow: [
          BoxShadow(
            color: WuxingColors.getColor(b.source).withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: Text(b.source, style: TextStyle(
        fontSize: 26, fontWeight: FontWeight.w900, color: WuxingColors.getColor(b.source),
      ))),
    );
  }

  Widget _answerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        border: Border(top: BorderSide(
          color: (_isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E)).withValues(alpha: 0.3),
        )),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _elements.map((e) => GestureDetector(
          onTap: _gameOver ? null : () => _tapAnswer(e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: WuxingColors.getSoftColor(e),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: WuxingColors.getColor(e).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Center(child: Text(e, style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w900,
              color: WuxingColors.getColor(e),
            ))),
          ),
        )).toList(),
      ),
    );
  }
}
